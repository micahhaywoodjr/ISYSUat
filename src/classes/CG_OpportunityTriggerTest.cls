@isTest
private class CG_OpportunityTriggerTest {

    private static TestMethod void ProcessBTest() {
        
        User u = new User();
	      User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    System.runAs ( thisUser ) {
        u.FirstName = 'Test'; 
        u.LastName = 'User';
        u.QB_Initials__c = 'TU';
        u.Username= 'testuserCGCG@Ccompany.com'; 
        u.Email = 'testuser@company.com';
        u.Alias = 'utest';
        u.TimeZoneSidKey = 'America/Denver';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = [SELECT Id
                         FROM Profile
                        WHERE Name = 'Custom - Nurse'].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
    }
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.OwnerId = u.id;
        insert acc;
        
        Account pacc = new Account();
        pacc.FirstName = 'John';
        pacc.LastName = 'Smith';
        insert pacc;
        
        Opportunity opp = new Opportunity();
        opp.CloseDate = Date.TODAY();
        opp.StageName = 'Completed';
        opp.AccountId = acc.Id;
        opp.QBJurisdiction__c = 'California-WC';
        opp.Name = 'Test opp';
        opp.QBServiceItem__c = 'MCM-On SIte';
        opp.Employee__c = pacc.id;
        opp.Service_Date_Thru__c = Date.TODAY();
        opp.B_Note_Approval_Date_Time__c = null;
        insert opp;
        
        Opportunity newOpp = new Opportunity();
        newOpp.Id = opp.Id;
        newOpp.B_Note_Approval_Date_Time__c = dateTime.now();
        newOpp.A_Note_Approval_Date_Time__c = dateTime.now();
        update newOpp;
        
        Opportunity noDateOpp = new Opportunity();
        noDateOpp.Id = opp.Id;
        noDateOpp.B_Note_Approval_Date_Time__c = null;
        noDateOpp.A_Note_Approval_Date_Time__c = null;
        update noDateOpp;
        
        Opportunity upOpp = new Opportunity();
        upOpp.Id = opp.Id;
        upOpp.B_Note_Approval_Date_Time__c = dateTime.now();
        upOpp.B_Note_Approval_Date_Time__c = dateTime.now();
        update upOpp;
        
    
    }

}