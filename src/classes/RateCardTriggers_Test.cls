@isTest
private class RateCardTriggers_Test {

    static testMethod void test_RateCardUpdate()
    {
        Account a = new Account(Name='TEST_ACCOUNT');
        insert a;
        Opportunity o = new Opportunity(Name='TEST_OPPTY',AccountId=a.Id,StageName='TEST_ACCOUNT', CloseDate=Date.today());
        insert o;
        o.Amount_Locked__c = false;
        update o;
        Rate_Card__c rc = new Rate_Card__c();
        rc.Travel_Wait_Rate__c=1.11;
        rc.Rush_Travel_Wait_Rate__c=1.11;
        rc.Rush_Professional_Rate__c=1.11; 
        rc.Rush_Mileage_Rate__c=1.11;
        rc.Professional_Rate__c=1.11;
        rc.Mileage_Rate__c=1.11;
        rc.Account__c=a.Id;
        rc.Name='TEST_RATE_CARD';
        insert rc;
        list<Rate_Card__c> RateCardList = new list<Rate_Card__c>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
            Rush_Mileage_Rate__c, Professional_Rate__c, Mileage_Rate__c, Account__c, Name From Rate_Card__c WHERE Id=:rc.Id]);
        
        if(!RateCardList.isEmpty())
        {
	        for(Rate_Card__c r:RateCardList)
	        {
	        	if(r.Professional_Rate__c != null)
	        	r.Professional_Rate__c =(r.Professional_Rate__c + 1.00);
	        	else
	        	r.Professional_Rate__c =1.00;
	        }
			update RateCardList;
        }
    }
}