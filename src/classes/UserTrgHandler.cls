public with sharing class UserTrgHandler 
{
	public void onAfterUpdate(User[] trgNewList, Map<Id,User> oldMap, Map<Id,User> newMap)
	{		
		Map<Id,Map<String, Set<String>>> insertDeleteByUserMap = new Map<Id,Map<String, Set<String>>>();
		Set<Id> inactiveIdSet = new Set<Id>();
		for(User u : trgNewList)
		{
			Set<String> oldAreaCode = new Set<String>();
			Set<String> newAreaCode = new Set<String>();
			Set<String> oldRegion = new Set<String>();
			Set<String> newRegion = new Set<String>();			
			User oldU = oldMap.get(u.Id);
			if(!u.IsActive && oldU.IsActive)
			{
				//just add an inactive user to the and continue - then remove all CM Assignments later
				inactiveIdSet.add(u.Id);
				continue;
			}
			//skip anything that didn't change
			if(oldU.AssignedArea__c==u.AssignedArea__c && oldU.AssignedRegion__c==u.AssignedRegion__c)
				continue;
						
			if(oldU.AssignedArea__c!=null)
			{
				for(String areaCode : oldU.AssignedArea__c.split(';'))
					oldAreaCode.add(areaCode);
			}
			if(u.AssignedArea__c!=null)
			{
				for(String areaCode : u.AssignedArea__c.split(';'))
					newAreaCode.add(areaCode);
			}
			if(oldU.AssignedRegion__c!=null)
			{
				for(String region : oldU.AssignedRegion__c.split(';'))
					oldRegion.add(region);
			}
			if(u.AssignedRegion__c!=null)
			{
				for(String region : u.AssignedRegion__c.split(';'))
					newRegion.add(region);
			}
			insertDeleteByUserMap.put(u.Id, buildKeys(u.Id, oldAreaCode,newAreaCode,oldRegion,newRegion));			
		}
		
		if(!insertDeleteByUserMap.isEmpty())
		{
			Map<String, List<Area__c>> areaByExtIdMap = new Map<String, List<Area__c>>();
			Set<String> deleteExternalIdSet = new Set<String>();
			Set<String> addExternalIdSet = new Set<String>();
			for(Map<String, Set<String>> insertDeleteMap : insertDeleteByUserMap.values())
			{
				if(insertDeleteMap.containsKey('delete'))
					deleteExternalIdSet.addAll(insertDeleteMap.get('delete'));
				if(insertDeleteMap.containsKey('insert'))
					addExternalIdSet.addAll(insertDeleteMap.get('insert'));
			}			
			for(List<CMAssignment__c> dList : [SELECT Id FROM CMAssignment__c where ExternalId__c in :deleteExternalIdSet])
				delete dList;
			
			for(Area__c area : [SELECT Id, Name, Region__c, ExternalId__c From Area__c where ExternalId__c in :addExternalIdSet])
			{
				if(!areaByExtIdMap.containsKey(area.ExternalId__c))
					areaByExtIdMap.put(area.ExternalId__c, new List<Area__c>());
				areaByExtIdMap.get(area.ExternalId__c).add(area);
			}				
							
			List<CMAssignment__c> insertList = new List<CMAssignment__c>();
			for(Id userId : insertDeleteByUserMap.keySet())
			{
				Map<String, Set<String>> insertDeleteMap = insertDeleteByUserMap.get(userId);									
				if(insertDeleteMap.containsKey('insert'))
				{
					for(String externalId : insertDeleteMap.get('insert'))
					{
						//this shouldn't happen but check in case all the areas with that number are deleted
						if(areaByExtIdMap.containsKey(externalId))
						{
							for(Area__c area : areaByExtIdMap.get(externalId))
							{
								CMAssignment__c cma = new CMAssignment__c();
								cma.Area__c = area.Id;
								cma.CaseManager__c = userId;
								cma.ExternalId__c = externalId+':'+userId;
								insertList.add(cma);
							}
						}
						//else
						//	newMap.get(userId).AssignedArea__c.addError('You attempted to add an area to this User but the area does not exist');
					}
				}				
			}
			System.debug('INSERTLIST::::'+insertList);
			if(insertList.size()>0)
				insert insertList;
		}
		if(!inactiveIdSet.isEmpty())
		{
			//for(List<CMAssignment__c> dList : [SELECT Id FROM CMAssignment__c where CaseManager__c in :inactiveIdSet])
			//	delete dList;
			EmployeeFutureClass.handleInactiveUser(inactiveIdSet);
		}
	}
	public void onAfterInsert(User[] trgNewList, Map<Id,User> newMap)
	{
		EmployeeFutureClass.handleNewUser(newMap.keySet());
	}
	private Map<String,Set<String>> buildKeys(Id userId, Set<String> oldAreaCode, Set<String> newAreaCode, Set<String> oldRegion, Set<String> newRegion)
	{
		Map<String,Set<String>> deleteInsertMap = new Map<String,Set<String>>();
		for(String areaCode : oldAreaCode)
		{
			if(!newAreaCode.contains(areaCode))
			{
				if(!deleteInsertMap.containsKey('delete'))
					deleteInsertMap.put('delete',new Set<String>());
				for(String region : newRegion)
					deleteInsertMap.get('delete').add(areaCode+':'+region+':'+userId);
			}
		}
		for(String region : oldRegion)
		{
			if(!newRegion.contains(region))
			{
				if(!deleteInsertMap.containsKey('delete'))
					deleteInsertMap.put('delete',new Set<String>());
				for(String areaCode : newAreaCode)
					deleteInsertMap.get('delete').add(areaCode+':'+region+':'+userId);
			}
		}
		for(String areaCode : newAreaCode)
		{
			if(!oldAreaCode.contains(areaCode))
			{
				if(!deleteInsertMap.containsKey('insert'))
					deleteInsertMap.put('insert',new Set<String>());
				for(String region : newRegion)
					deleteInsertMap.get('insert').add(areaCode+':'+region);
			}
		}
		for(String region : newRegion)
		{
			if(!oldRegion.contains(region))
			{
				if(!deleteInsertMap.containsKey('insert'))
					deleteInsertMap.put('insert',new Set<String>());
				for(String areaCode : newAreaCode)
					deleteInsertMap.get('insert').add(areaCode+':'+region);
			}
		}
		return deleteInsertMap;
	}
}