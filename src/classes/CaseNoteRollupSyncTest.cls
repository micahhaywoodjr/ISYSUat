@isTest
private class CaseNoteRollupSyncTest 
{    
    public static testMethod void testCaseNoteRollup() 
    {
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        
        Case testCase = new Case(Employee_Case_Trakker__c='Test');
        insert testCase;
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test - Opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.today();
        testOpp.P_S_Comment__c = 'Test';
        testOpp.Related_Case__c = testCase.Id;
        //testOpp.Service_Date_From__c = System.today() - 3;
        //testOpp.Service_Date_Thru__c = System.today();
        insert testOpp;
        
        List<Billing_Code__c> bcList = new List<Billing_Code__c>();
        Billing_Code__c proHoursBc = new Billing_Code__c();
        proHoursBc.Active__c = true;
        proHoursBc.Name = 'W';
        proHoursBc.Max__c = 10;
        proHoursBc.Min__c = 0;
        proHoursBc.DefaultCode__c = true;
        bcList.add(proHoursBc);
        
        Billing_Code__c travelWaitHoursBc = new Billing_Code__c();
        travelWaitHoursBc.Active__c = true;
        travelWaitHoursBc.Name = 'T';
        travelWaitHoursBc.Max__c = 10;
        travelWaitHoursBc.Min__c = 0;
        travelWaitHoursBc.DefaultCode__c = true;
        bcList.add(travelWaitHoursBc);
        insert bcList;
        
        Case_Note_Entry__c travelWaitCaseNote = new Case_Note_Entry__c();        
        travelWaitCaseNote.Adj_Travel_Wait_Hours__c = 1;        
        travelWaitCaseNote.Travel_Wait_Hours_Nurse__c = 1;     
        travelWaitCaseNote.Mileage_Nurse__c = 1;
        travelWaitCaseNote.Driving_From_City__c = 'Dallas';
        travelWaitCaseNote.Driving_To_City__c='Houston';
        travelWaitCaseNote.Work_Description__c = 'Test';
        travelWaitCaseNote.Billing_Code__c = travelWaitHoursBc.Id;       
        travelWaitCaseNote.Report__c = testOpp.Id; 
        insert travelWaitCaseNote;
        
        Test.startTest();        
        testOpp.StageName = 'Submitted';
        update testOpp;        
        Test.stopTest();        
    }
}