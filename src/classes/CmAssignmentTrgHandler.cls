public with sharing class CmAssignmentTrgHandler 
{	
	public void onBeforeUpdate(CMAssignment__c[] trgNewList)
	{
		//make sure the external id changes if the case manager changes
		//this will prevent a user from changing the case manager if another record exists for that combination
		for(CMAssignment__c cma : trgNewList)
			cma.ExternalId__c = cma.AreaCode__c+':'+cma.AreaRegion__c+':'+cma.CaseManager__c;
	}
	public void onBeforeInsert(CMAssignment__c[] trgNewList)
	{
		for(CMAssignment__c cma : trgNewList)
		{
			cma.ExternalId__c = cma.AreaCode__c+':'+cma.AreaRegion__c+':'+cma.CaseManager__c;
			System.debug('CmaExternal::::'+cma.ExternalId__c);
		}
	}
	public void onAfterDelete(CMAssignment__c[] trgOldList)
	{
		Set<Id> areaIdSet = new Set<Id>();		
		for(CMAssignment__c cma : trgOldList)
		{
			areaIdSet.add(cma.Area__c);
		}
		doUpdate(areaIdSet);
	}
	public void onAfterInsert(CMAssignment__c[] trgNewList)
	{
		Set<Id> areaIdSet = new Set<Id>();
		for(CMAssignment__c cma : trgNewList)
			areaIdSet.add(cma.Area__c);
		doUpdate(areaIdSet);
	}
	public void onAfterUpdate(CMAssignment__c[] trgNewList, Map<Id,CMAssignment__c> oldMap)
	{
		Set<Id> areaIdSet = new Set<Id>();
		for(CMAssignment__c cma : trgNewList)
		{
			if(cma.CaseManager__c != oldMap.get(cma.Id).CaseManager__c)
				areaIdSet.add(cma.Area__c);
		}
		if(!areaIdSet.isEmpty())
			doUpdate(areaIdSet);
	}	
	
	private static void doUpdate(Set<Id> areaIdSet)
	{		
		List<Area__c> aList = new List<Area__c>();
		for(Area__c area : [Select a.Id, Name, (Select CaseManagerName__c From CM_Assignments__r order by CaseManagerName__c) From Area__c a where a.Id in :areaIdSet])
		{
			String names='';
			for(CMAssignment__c cma : area.CM_Assignments__r)
				names+=cma.CaseManagerName__c+';';
			area.AssignedCaseManagers__c=names;
			aList.add(area);
		}		
		if(aList.size()>0)
			update aList;						
	}
}