global class EmployeeFutureClass 
{
	@future	
	public static void handleNewUser(Set<Id> userIdSet)
	{
		List<SFDC_Employee__c> empList = new List<SFDC_Employee__c>();
		Map<Id,Map<String, Set<String>>> insertDeleteByUserMap = new Map<Id,Map<String, Set<String>>>();
		
		for(User u : [SELECT Id,Email,FirstName,LastName,UserName,AssignedArea__c,AssignedRegion__c FROM User WHERE Id in :userIdSet])
		{
			SFDC_Employee__c emp = new SFDC_Employee__c(SF_User__c=u.Id,Email_Address__c=u.Email,Name=u.FirstName+' '+u.LastName,SF_Username__c=u.Username);			
			empList.add(emp);
			Set<String> newRegion = new Set<String>();
			Set<String> newAreaCode = new Set<String>();
			if(u.AssignedArea__c!=null)
			{
				for(String areaCode : u.AssignedArea__c.split(';'))
					newAreaCode.add(areaCode);
			}
			if(u.AssignedRegion__c!=null)
			{
				for(String region : u.AssignedRegion__c.split(';'))
					newRegion.add(region);
			}
			Map<String,Set<String>> deleteInsertMap = new Map<String,Set<String>>();		
			for(String areaCode : newAreaCode)
			{			
				if(!deleteInsertMap.containsKey('insert'))
					deleteInsertMap.put('insert',new Set<String>());
				for(String region : newRegion)
					deleteInsertMap.get('insert').add(areaCode+':'+region);			
			}
			for(String region : newRegion)
			{
				if(!deleteInsertMap.containsKey('insert'))
					deleteInsertMap.put('insert',new Set<String>());
				for(String areaCode : newAreaCode)
					deleteInsertMap.get('insert').add(areaCode+':'+region);			
			}
			insertDeleteByUserMap.put(u.Id, deleteInsertMap);			
		}
			
		if(!insertDeleteByUserMap.isEmpty())
		{
			Map<String, List<Area__c>> areaByExtIdMap = new Map<String, List<Area__c>>();
			
			Set<String> addExternalIdSet = new Set<String>();
			for(Map<String, Set<String>> insertDeleteMap : insertDeleteByUserMap.values())
			{				
				if(insertDeleteMap.containsKey('insert'))
					addExternalIdSet.addAll(insertDeleteMap.get('insert'));
			}
			
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
			if(insertList.size()>0)
				insert insertList;
		}		
		upsert empList SF_Username__c;
	}	
	@future	
	public static void handleInactiveUser(Set<Id> inactiveUserIdSet)
	{
		for(List<CMAssignment__c> dList : [SELECT Id FROM CMAssignment__c where CaseManager__c in :inactiveUserIdSet])
			delete dList;
	}
	
}