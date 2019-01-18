@isTest
private class SubmitForApprovalOpp_Test {
    @TestSetup static void testData() {
        Environment_Settings__c e = new Environment_Settings__c();
        e.Name = 'Environment';
        e.ResultsNotificationEmail__c = 'test@testing.com';
        e.batchSize__c = 10;
        e.NewAcctBillingCodeBatchSize__c = 10;
        insert e;
    }
    
    private static testMethod void testHasErrors(){
        
        Account a = new Account();
        
        a.Name = 'Test Account';
        
        insert a;
        
        Opportunity opp = new Opportunity(AccountId=a.Id,name='Test Opportunity 1.0', Amount=0.0, closedate=system.today(),stageName ='Submitted', Service_Date_Thru__c=system.today());
        insert opp;
        
        Billing_Code__c bill= new Billing_Code__c(name ='01 Test Report',DefaultCode__c=true,Active__c=true,LinkCommunication__c=true);
        insert bill;
        
        Case_Note_Entry__c cne = new Case_Note_Entry__c(Report__c=opp.Id, Billing_Code__c=bill.id,Professional_Hours_Nurse__c=1);
        insert cne;
        
        Test.startTest();
            ApexPages.StandardController std = new ApexPages.StandardController(opp);
            
            SubmitForApprovalOpp controller = new SubmitForApprovalOpp(std);
            System.assert(controller.hasErrors);
            
            String pageRef = controller.validateCNE().getUrl();
        Test.stopTest();
        
        
        System.assert(pageRef.containsIgnoreCase('editCaseNoteEntries'));
        
    }
    
    private static testMethod void testIsTele(){
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        /*Contact c = new Contact();
        c.LastName = 'Test';
        c.Account = a;
        c.IsContactActivewiththisAccount__c = 'Yes';
        c.Role__c = 'Ortho-Surgeon';
        c.Other_Role__c = 'Foot Specialist';
        insert c;*/
        
        
        Opportunity opp = new Opportunity(AccountId=a.Id,name='Test Opportunity 1.0', Amount=0.0, closedate=system.today(),stageName ='Submitted', Service_Date_Thru__c=system.today(), QbServiceItem__c = 'MCM-Tele');
        insert opp;
        
        Billing_Code__c bill= new Billing_Code__c(name ='01 Test Report',DefaultCode__c=true,Active__c=true,LinkCommunication__c=true);
        insert bill;
        
        Case_Note_Entry__c cne = new Case_Note_Entry__c(Report__c=opp.Id, Billing_Code__c=bill.id,Professional_Hours_Nurse__c=1);
        insert cne;
        
        Appointment_Visit__c app = new Appointment_Visit__c(Case_Manager_Attended__c = 'Yes', Case_Report_Opportunity__c = opp.Id);
        insert app;
        
        Test.startTest();
            ApexPages.StandardController std = new ApexPages.StandardController(opp);
            
            SubmitForApprovalOpp controller = new SubmitForApprovalOpp(std);
            controller.validateAppointments();
            System.assert(controller.hasErrors);
            System.assert(!controller.appointmentError);
            
            String pageRef = controller.validateCNE().getUrl();
            
        Test.stopTest();
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}