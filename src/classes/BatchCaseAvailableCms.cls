global class BatchCaseAvailableCms implements Database.Batchable<sObject>
{
	global Database.Querylocator start(Database.Batchablecontext BC)
	{
		return Database.getQueryLocator([Select Id, AssignmentRegion__c FROM Case]);
	}
	global void execute(Database.Batchablecontext BC, list<SObject> scope)
	{
		try{
			Case c;
			Set<Id> areaIdSet = new Set<Id>();
			for(SObject so : scope)
			{
				c = (Case)so;
				areaIdSet.add(c.AssignmentRegion__c);
			}
			Map<Id,Area__c> areaByIdMap = new Map<Id,Area__c>([SELECT Id, AssignedCaseManagers__c FROM Area__c where Id in :areaIdSet]);
			for(SObject so : scope)
			{
				c=(Case)so;
				if(areaByIdMap.containsKey(c.AssignmentRegion__c))
					c.AvailableCMs__c = areaByIdMap.get(c.AssignmentRegion__c).AssignedCaseManagers__c;
				else
					c.AvailableCMs__c = '';
			}
			update scope;
		}
		catch(Exception e){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'support@isyscm.com '};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Error Processing BatchCaseAvailableCms');
			mail.setPlainTextBody
			('The BatchCaseAvailableCms job failed. Some records may have been processed:' + '\n' + 'Message: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString() + '');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	global void finish (Database.Batchablecontext BC)
	{
		if(!Test.isRunningTest())
			Database.executeBatch(new BatchCaseMetrics());
	}
}