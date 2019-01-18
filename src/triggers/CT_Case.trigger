trigger CT_Case on Case (after update, before update, before insert, after insert)
{
    CT_ITriggerHandler.ICaseTriggerHandler handler;    
    if(trigger.isAfter)
    {
	    if(trigger.isUpdate)
	    {
            handler = new CT_CaseTriggerHandler(trigger.isExecuting, trigger.size);
            handler.OnAfterUpdate(trigger.old, trigger.new, trigger.oldmap, trigger.newmap);
	    }
	    else if(trigger.isInsert)
	    {
	    	Set<Id> closedCaseIdSet = new Set<Id>();
	    	for(Case c : trigger.new)
	    	{
	    		if(c.IsClosed)
	    			closedCaseIdSet.add(c.Id);
	    	}
	    	
	    	if(!closedCaseIdSet.isEmpty())
    			update populateCaseCloseDate(closedCaseIdSet, trigger.newMap, false);
	    }
    }
    if(trigger.isBefore)
    {
    	if(trigger.isInsert)
    	{
    		Set<Id> areaIdSet = new Set<Id>();
    		List<Case> changeList = new List<Case>();
    		for(Case c : trigger.new)
    		{
    			if(c.AssignmentRegion__c != null)
    			{
    				areaIdSet.add(c.AssignmentRegion__c);
    				changeList.add(c);
    			}
    			//stores the owner at case close so we can run metrics against it    			
    			if(c.IsClosed)
    				c.OwnerAtCaseClose__c = c.OwnerId;
    		}
    		if(areaIdSet.size()>0)
    		{
    			Map<Id,Area__c> areaByIdMap = new Map<Id,Area__c>([SELECT Id, AssignedCaseManagers__c from Area__c where Id in :areaIdSet]);
    			for(Case c : changeList)
    			{
    				if(areaByIdMap.containsKey(c.AssignmentRegion__c))
    					c.AvailableCMs__c = areaByIdMap.get(c.AssignmentRegion__c).AssignedCaseManagers__c;
    				else
    					c.AvailableCMs__c = null;
    			}
    		}
    	}
    	if(trigger.isUpdate)
    	{
    		List<Case> changeList = new List<Case>();
    		Set<Id> areaIdSet = new Set<Id>();
    		Case oldCase;
    		Set<Id> closedCaseIdSet = new Set<Id>();
    		for(Case c : trigger.new)
    		{
    			oldCase = trigger.oldMap.get(c.Id);
    			if(c.AssignmentRegion__c != oldCase.AssignmentRegion__c)
    			{
    				areaIdSet.add(c.AssignmentRegion__c);
    				changeList.add(c);
    			}
    			//stores the owner at case close so we can run metrics against it
    			if(!oldCase.IsClosed && c.IsClosed)
    			{
    				c.OwnerAtCaseClose__c = oldCase.OwnerId;
    				closedCaseIdSet.add(c.Id);
    			}
    			else if(oldCase.IsClosed && !c.IsClosed)
    				c.OwnerAtCaseClose__c = null;
    		}
    		if(areaIdSet.size()>0)
    		{
    			Map<Id,Area__c> areaByIdMap = new Map<Id,Area__c>([SELECT Id, AssignedCaseManagers__c from Area__c where Id in :areaIdSet]);
    			for(Case c : changeList)
    			{
    				if(areaByIdMap.containsKey(c.AssignmentRegion__c))
    					c.AvailableCMs__c = areaByIdMap.get(c.AssignmentRegion__c).AssignedCaseManagers__c;
    				else
    					c.AvailableCMs__c = null;
    			}
    		}
    		if(!closedCaseIdSet.isEmpty())
    			populateCaseCloseDate(closedCaseIdSet, trigger.newMap, true);
    	}
    }
    private static List<Case> populateCaseCloseDate(Set<Id> closedCases, Map<Id,Case> newMap, boolean isBefore)
    {    	
    	Datetime currentDt = System.now();    	
    	Date d;
    	Map<Id,Datetime> caseIdToDtMap = new Map<Id,Datetime>();
    	List<Case> caseList = new List<Case>();
    	for(AggregateResult ar : [SELECT Related_Case__c, MAX(Service_Date_Thru__c) FROM Opportunity WHERE Related_Case__c in :closedCases AND StageName in ('Submitted','Approved','Completed') GROUP BY Related_Case__c])
    	{
    		if(newMap.containsKey((Id)ar.get('Related_Case__c')))
    		{
    			if(ar.get('expr0')!=null)
    			{
					d = (Date)ar.get('expr0');
					caseIdToDtMap.put((Id)ar.get('Related_Case__c'),Datetime.newInstance(d.year(),d.month(),d.day(),currentDt.hour(),currentDt.minute(),currentDt.second()));    				
    			}
    		}
    	}
    	for(Id caseId : closedCases)
    	{
    		if(caseIdToDtMap.containsKey(caseId))
    		{
    			if(isBefore)
    				newMap.get(caseId).CaseClosedDate__c=caseIdToDtMap.get(caseId);
    			else
    				caseList.add(new Case(Id=caseId,CaseClosedDate__c=caseIdToDtMap.get(caseId)));
    		}
    		else
    		{
    			if(isBefore)
    				newMap.get(caseId).CaseClosedDate__c=currentDt;
    			else
    				caseList.add(new Case(Id=caseId,CaseClosedDate__c=currentDt));
    		}
    	}
    	return caseList;
    }
}