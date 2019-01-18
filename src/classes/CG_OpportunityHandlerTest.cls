@isTest
private class CG_OpportunityHandlerTest {

	private static TestMethod void ProcessTest() {
                
        User u = new User();
	      User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    System.runAs ( thisUser ) {
        u.FirstName = 'Test'; 
        u.LastName = 'User';
        u.QB_Initials__c = 'TU';
        u.Username= 'testuserCGCG@CGcompany.com'; 
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
        acc.Type = 'Employer';
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
        opp.A_Note_Approval_Date_Time__c = null;
		insert opp;     
 
        Case_Note_Entry__c caseN1 = new Case_Note_Entry__c();
	    caseN1.Report__c = opp.Id;
	    caseN1.Professional_Hours_Nurse__c = 2.0;
        insert caseN1;
	    
	    Case_Note_Entry__c caseN2 = new Case_Note_Entry__c();
	    caseN2.Report__c = opp.Id;
	    caseN2.Professional_Hours_Nurse__c = 2.0;
        insert caseN2;
        
        opp = [SELECT id
              	FROM Opportunity
              LIMIT 1];
  
	    Opportunity Opp1 = new Opportunity();
        Opp1.Id = opp.id;
        opp1.QBServiceItem__c = 'RUSH-MCM-On Site';
	    Opp1.B_Note_Approval_Date_Time__c = dateTime.now();
        Opp1.A_Note_Approval_Date_Time__c = dateTime.now();
	    update Opp1;
               
 
	}
}