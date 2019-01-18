@isTest
private class Test_createUpdateRates {

    static testMethod void myUnitTest() {
        //Account
		Account a = new Account();
		a.Name = 'ACC';
		a.Travel_Wait_Rate__c = 100;
		a.ShippingStreet = '123';
		a.Rush_Travel_Wait_Rate__c = 123;
		a.ShippingCity = 'NYC';
		a.ShippingCountry = 'USA';
		a.ShippingPostalCode = '23233';
		a.ShippingState = 'CA';
		a.ShippingStreet = 'Street';
		a.Rush_Mileage_Rate__c = 3450;
		a.Professional_Rate__c = 230;
		a.Mileage_Rate__c = 100;
		insert a;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(a);
		createUpdateRates ctl = new createUpdateRates(sc);
		
		
		Set<String> lstLegal = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Case.Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            lstLegal.add(f.getValue());
        }
        system.debug('---------lstLegal-----------' + lstLegal);
		
		ctl.processMe();
		
		Rate_Card__c rc = new Rate_Card__c();
		rc.Account__c = a.Id;
		rc.Name = 'CALIFORNIA-WC';
		insert rc;
		
		ctl.processMe();
		
		//Select r.Travel_Wait_Rate__c, r.Rush_Travel_Wait_Rate__c, r.Rush_Professional_Rate__c, r.Rush_Mileage_Rate__c, 
		//r.Professional_Rate__c, r.Mileage_Rate__c, r.MCM_On_Site__c, r.Account__c From Rate_Card__c r
		
    }
}