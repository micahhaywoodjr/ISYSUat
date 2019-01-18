public with sharing class ContactTriggerHandler
{
	List<Contact> oldRecords, newRecords;
    Map<Id,Contact> oldRecordsMap,newRecordsMap;
   
    public ContactTriggerHandler(List<Contact> newRecords, List<Contact> oldRecords, Map<Id,Contact> newRecordsMap, Map<Id,Contact> oldRecordsMap)
    {
		this.oldRecords = oldRecords;
	    this.newRecords = newRecords;
	    this.oldRecordsMap = oldRecordsMap;
	    this.newRecordsMap = newRecordsMap;
    }//end constructor
    
	public void processBeforeInsert()
	{
		List<String> areaCodes = new List<String>();
		List<String> regions = new List<String>();
		//If both the phone and the region are set, the Area on the Contact needs to be updated
		for(Contact c: newRecords)
		{
			if((c.Phone != null) && (c.Region__c!= null))
			{
				areaCodes.add(c.AreaCodePhone__c);
				regions.add(c.Region__c);
			}
		}//end for
		if(!areaCodes.isEmpty()&& !regions.isEmpty())
		{
			Map<String,Id> areaMap = getAreaMap(areaCodes, regions);
			//Now iterate all the contacts and put areas on them
			for(Contact c: newRecords)
			{
				if((c.Phone != null)&& (c.Region__c!= null))
				{
					String areaKey = c.AreaCodePhone__c + c.Region__c;
					if(areaKey!= null && areaMap.containsKey(areaKey))
					{
						c.Area__c = areaMap.get(areaKey);
					}
				}//end null check on phone and region
			}//end for			
		}//end null check on areas and regions		
    }//end processBeforeInsert()
    
    public void processAfterUpdate()
    {
    	//if the phone changes, send an update to the healthcare provider list so the trigger can make changes to area if necessary
		Set<Id> changedContactIdSet = new Set<Id>();
		for(Contact c : newRecords)
		{
			if(c.Phone != oldRecordsMap.get(c.Id).Phone)
				changedContactIdSet.add(c.Id);
		}
		if(changedContactIdSet.size()>0)
		{
			//query for any related healthcare provider that's primary and active
			//for(List<Healthcare_Provider__c> hcpList : [SELECT Id FROM Healthcare_Provider__c where Contact__c in :changedContactIdSet and InActive__c=false and Primary__c=true])
			for(List<Healthcare_Provider__c> hcpList : [SELECT Id FROM Healthcare_Provider__c where Contact__c in :changedContactIdSet and ProviderStatus__c='Active' and Primary__c=true])
				update hcpList;
		}
    }//end processAfterInsert()
   
    public void processBeforeUpdate()
    {
		List<String> areaCodes = new List<String>();
		List<String> regions = new List<String>();
		Map<Id,String> contactIdToKeyMap = new Map<Id,String>();
		
		//If either the phone or the region changes, the Area on the Contact needs to be updated
		for(Contact c: newRecords)
		{
			if((c.Phone != null && c.Phone != oldRecordsMap.get(c.Id).Phone)||(c.Region__c!= null && c.Region__c != oldRecordsMap.get(c.Id).Region__c))
			{
				areaCodes.add(c.AreaCodePhone__c);
				regions.add(c.Region__c);
				String concatenatedString = c.AreaCodePhone__c + c.Region__c;
				contactIdToKeyMap.put(c.id,concatenatedString);
			}
		}//end for
		if(!contactIdToKeyMap.isEmpty())
		{
			Map<String,Id> areaMap = getAreaMap(areaCodes, regions);	
			//Now iterate the contacts that were updated and put areas on them
			for(Id cId: contactIdToKeyMap.keySet())
			{
				String areaKey = contactIdToKeyMap.get(cId);
				if(areaKey!= null && areaMap.containsKey(areaKey))
				{
					newRecordsMap.get(cId).Area__c = areaMap.get(areaKey);
				}
			}
		}//end empty check on contactIdToKeyMap		
    }//end processBeforeUpdate()
    
    public Map<String,Id> getAreaMap(List<String>areaCodes, List<String>regions)
    {
    	Map<String,Id> areaMap = new Map<String,Id>();
		System.debug('areaCodes----'+areaCodes);
		System.debug('regions----'+regions);
    	//Query Area__c to get the matching areas
		for(Area__c area:[SELECT Id,Name,Region__c FROM Area__c where Region__c in :regions and Name in:areaCodes])
		{
			String key = area.Name + area.Region__c;
			areaMap.put(key,area.id);
		}			
		System.debug('areaMap---'+areaMap);
		return areaMap;
    }//end getAreaMap()
}