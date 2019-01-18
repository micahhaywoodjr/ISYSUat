public with sharing class AreaTrgHandler 
{
	public static void onBeforeInsert(Area__c[] trgNew)
	{
		for(Area__c a : trgNew)
			a.ExternalId__c = a.Name+':'+a.Region__c;
	}
	public static void onBeforeUpdate(Area__c[] trgNew)
	{
		for(Area__c a : trgNew)
			a.ExternalId__c = a.Name+':'+a.Region__c;
	}
}