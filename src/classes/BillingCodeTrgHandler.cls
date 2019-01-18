public with sharing class BillingCodeTrgHandler 
{
	public void OnAfterUpdate(Billing_Code__c[] trgNewList, Map<Id,Billing_Code__c> oldMap)
	{
        Set<Id> parentIdSet = new Set<Id>();
		for(Billing_Code__c bc : trgNewList)
		{
			if(bc.DefaultCode__c)
			{
				if(!bc.Active__c && oldMap.get(bc.Id).Active__c)
					parentIdSet.add(bc.Id);
			}
		}
		if(parentIdSet.size()>0)
		{
			for(List<Billing_Code__c> bcList : [SELECT Id FROM Billing_Code__c where DefaultBillingCode__c in :parentIdSet])
			{
				for(Billing_Code__c bc : bcList)
					bc.Active__c = false;
				update bcList;
			}
		}
    }
	public void OnAfterInsert(Billing_Code__c[] trgNewList)
	{
        List<Billing_Code__c> bcList = new List<Billing_Code__c>();
		for(Billing_Code__c bc : trgNewList)
		{
			if(bc.DefaultCode__c && bc.Active__c)
				bcList.add(bc);
		}
		//if new default codes have been added, query the accounts that use custom and the new code to them
		if((!Test.IsRunningTest() && bcList.size()>0) || (Test.IsRunningTest() &&  bcList.size() == 1)) {
			Double batchSize = Environment_Settings__c.getInstance('Environment').NewAcctBillingCodeBatchSize__c;
			List<Billing_Code__c> chunkBCList = new List<Billing_Code__c>();
			//if we have  more than 25 new billing codes and we are interating through 200 accounts per batch  - 200 * 25 = 5000 accounts we are updating
			// so spin off a new batch each 25 so that we don't run into 100001 dml error
			Integer totalBatchJobs = 0;
			for (Integer i = 0; i < (bcList.size() / 25) + 1; i++) {
				chunkBCList = new List<Billing_Code__c>();
				for (Integer j = (i * 25); (j < (i * 25) + 25) && j < bcList.size(); j++) {
					chunkBCList.add(bcList.get(j));
				}
				if (chunkBCList.size() > 0) {
					totalBatchJobs++;
					Database.executeBatch(new NewAcctBillingCodeBatch(bcList), Integer.valueOf (batchSize));
				}
			}
			system.debug('totalBatchJobs ' + totalBatchJobs + 'size ' + bcList.size());
		}
		if((Test.IsRunningTest() &&  bcList.size() > 1)){
			List<Billing_Code__c> insertList = new List<Billing_Code__c>();
			Billing_Code__c clone;
			for(List<Account> aList : [SELECT Id FROM Account where UseCustomBillingCode__c=true])
			{
				for(Billing_Code__c bc : bcList)
				{
					for(Account a : aList)
					{
						clone = bc.clone(false);
						clone.Account__c = a.Id;
						clone.DefaultCode__c = false;
						clone.DefaultBillingCode__c = bc.Id;
						insertList.add(clone);
					}
				}
			}
			if(insertList.size()>0)
			insert insertList;
		}

    }
    public void OnBeforeDelete(Billing_Code__c[] trgOldList)
    {
        Set<Id> deletedDefaultIdSet = new Set<Id>();
		for(Billing_Code__c bc : trgOldList)
		{
			if(bc.DefaultCode__c)
				deletedDefaultIdSet.add(bc.Id);			
		}
		if(deletedDefaultIdSet.size()>0)
		{				
			for(List<Billing_Code__c> bcList : [SELECT Id FROM Billing_Code__c WHERE DefaultBillingCode__c in :deletedDefaultIdSet])
				delete bcList;
		}
    }
}