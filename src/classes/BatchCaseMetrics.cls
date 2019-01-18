global class BatchCaseMetrics implements Database.Batchable<sObject>, Database.Stateful
{
	Date runDate = Date.today();	
	integer daysInMonth = Date.daysInMonth(runDate.year(),runDate.month());	
	Date metricDate = Date.parse(String.valueOf(runDate.month())+'/'+daysInMonth+'/'+runDate.year());
	Map<String,CMMetric__c> keyMap = new Map<String, CMMetric__c>();
	String monthYear = '';
	String runDateMonthYear = String.valueOf(runDate.month()+'/'+runDate.year());
	integer currentMonth = runDate.month();
	integer currentYear = runDate.year();
	Map<String,Id> rtIdMap = new Map<String,Id>();
	global BatchCaseMetrics()
	{
		for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType='CMMetric__c'])
			rtIdMap.put(rt.DeveloperName,rt.Id);
	}
	global Database.Querylocator start(Database.Batchablecontext BC)
    {    	
    	return Database.getQueryLocator([Select Id,AreaNumber__c,OwnerId,OwnerAtCaseClose__c,Owner.Username,Owner.Type,IsClosed,ClosedDate FROM Case WHERE Status in ('Open','Re-Opened','Closed')]);
    }
    global void execute(Database.Batchablecontext BC, list<SObject> scope)
    {
    	try{
    	String areaKey;
    	String userKey;
    	Set<Id> ownerId = new Set<Id>();
    	for(Sobject so : scope)
    	{
    		Case c = (Case)so;
    		if(c.IsClosed)
    		{
    			if(c.OwnerAtCaseClose__c==null ||(c.ClosedDate.month()!=currentMonth && c.ClosedDate.year()!=currentYear))
    				continue;
    			else
    				ownerId.add(c.OwnerAtCaseClose__c);
    		}
    	}
    	Map<Id,User> userMap = new Map<Id,User>([SELECT Id,UserName FROM User WHERE Id in :ownerId]);
    	for(Sobject so : scope)
    	{
    		areaKey = null;
    		userKey = null;
    		Case c = (Case)so;    		
    		SFDC_Employee__c emp = new SFDC_Employee__c();
    		if(c.IsClosed)
    		{
    			if(c.OwnerAtCaseClose__c==null || (c.ClosedDate.month()!=currentMonth || c.ClosedDate.year()!=currentYear) || !userMap.containsKey(c.OwnerAtCaseClose__c))
    				continue;
    			monthYear = String.valueOf(c.ClosedDate.month()+'/'+c.ClosedDate.year());
    			if(c.AreaNumber__c!=null&&c.AreaNumber__c!='')
    				areaKey = c.AreaNumber__c+':'+c.OwnerAtCaseClose__c+':'+monthYear;
    			userKey = c.OwnerAtCaseClose__c+':'+monthYear;
    			    			    				
    			emp.SF_Username__c = userMap.get(c.OwnerAtCaseClose__c).UserName;
    			
    			if(areaKey!=null)
    			{
    				if(!keyMap.containsKey(areaKey))
    					keyMap.put(areaKey, new CMMetric__c(ExternalId__c=areaKey,OpenCases__c=0,ClosedCases__c=0,Employee__r=emp, Area__c=c.AreaNumber__c, MetricDate__c=metricDate,RecordTypeId=rtIdMap.get('AreaMetric')));
    				keyMap.get(areaKey).ClosedCases__c+=1;
    			}
    			if(!keyMap.containsKey(userKey))
    				keyMap.put(userKey, new CMMetric__c(ExternalId__c=userKey,OpenCases__c=0,ClosedCases__c=0,Employee__r=emp,MetricDate__c=metricDate,RecordTypeId=rtIdMap.get('UserMetric')));
    			keyMap.get(userKey).ClosedCases__c+=1;
    		}
    		else
    		{
    			if(c.Owner.Type!='User')
    				continue;
    			monthYear=runDateMonthYear;
    			if(c.AreaNumber__c!=null&&c.AreaNumber__c!='')
    				areaKey = c.AreaNumber__c+':'+c.OwnerId+':'+monthYear;
    			userKey = c.OwnerId+':'+monthYear;   			
    			emp.SF_Username__c = c.Owner.UserName;
    			
    			if(areaKey!=null)
    			{
    				if(!keyMap.containsKey(areaKey))
    					keyMap.put(areaKey, new CMMetric__c(ExternalId__c=areaKey,OpenCases__c=0,ClosedCases__c=0,Employee__r=emp, Area__c=c.AreaNumber__c, MetricDate__c=metricDate,RecordTypeId=rtIdMap.get('AreaMetric')));
    				keyMap.get(areaKey).OpenCases__c+=1;
    			}
    			if(!keyMap.containsKey(userKey))
    				keyMap.put(userKey, new CMMetric__c(ExternalId__c=userKey,OpenCases__c=0,ClosedCases__c=0,Employee__r=emp,MetricDate__c=metricDate,RecordTypeId=rtIdMap.get('UserMetric')));
    			keyMap.get(userKey).OpenCases__c+=1;
    		}
    	}
    	}
    	catch(Exception e){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'Diane.Campos@isyscm.com '};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Error Processing BatchCaseMetrics');
			mail.setPlainTextBody
			('The BatchCaseMetrics job failed. Some records may have been processed:' + '\n' + 'Message: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString() + '');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
    }
    global void finish (Database.Batchablecontext BC)
    {    	
    	upsert keyMap.values() ExternalId__c;
    	if(!Test.isRunningTest())
    		Database.executeBatch(new BatchCaseNoteEntryMetrics());
    }
}