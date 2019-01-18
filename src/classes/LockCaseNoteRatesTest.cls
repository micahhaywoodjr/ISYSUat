@istest
private class LockCaseNoteRatesTest 
{

    public static testMethod void testCaseNoteRateLock() 
    {

        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test - Opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.today();
        testOpp.P_S_Comment__c = 'Test';
        testOpp.Service_Date_From__c = System.today();
        testOpp.Service_Date_Thru__c = System.today();
        insert testOpp;

        List<Billing_Code__c> bcs= new List <Billing_Code__c>();
        Billing_Code__c testCode = new Billing_Code__c();
        testCode.Active__c = true;
        testCode.Name = 'T';
        testCode.Max__c = 10;
        testCode.Min__c = 0;
        testCode.DefaultCode__c = true;
        bcs.add(testCode);

        Billing_Code__c testCode2 = new Billing_Code__c();
        testCode2.Active__c = true;
        testCode2.Name = 'T';
        testCode2.Max__c = 10;
        testCode2.Min__c = 0;
        testCode2.DefaultCode__c = true;
        bcs.add(testCode2);
        insert bcs;
        
        Case_Note_Entry__c testCaseNote = new Case_Note_Entry__c();
        //testCaseNote.Expenses__c = 10;
        //testCaseNote.Mileage__c = 10;
        testCaseNote.Driving_From_City__c = 'Dallas';
        testCaseNote.Driving_To_City__c='Houston';
        //testCaseNote.Professional_Hours__c = 10;
        testCaseNote.Report__c = testOpp.Id;
        //testCaseNote.Adj_Professional_Hours__c = 0;
        testCaseNote.Adj_Travel_Wait_Hours__c = 1;
        //testCaseNote.Adj_Expenses__c = 10;
        //testCaseNote.Adj_Mileage__c = 100;
        testCaseNote.Travel_Wait_Hours__c = 1;
        //testCaseNote.Professional_Hours_Nurse__c = 1;
        testCaseNote.Mileage_Nurse__c = 1;
        testCaseNote.Travel_Wait_Hours_Nurse__c = 1;
        //testCaseNote.Expenses_Nurse__c = 1;
        testCaseNote.Work_Description__c = 'Test';
        testCaseNote.Billing_Code__c = testCode.Id;
        testCaseNote.Activity_Date__c = System.today();
        insert testCaseNote;
        
        Test.startTest();        
        testOpp.StageName = 'Submitted';
        update testOpp;        
        Test.stopTest();
        
        List<Case_Note_Entry__c> caseNotes = [SELECT Id, Report__r.Amount_Locked__c, Rate_Calculation__c FROM Case_Note_Entry__c WHERE Report__c =: testOpp.Id];
        
    }
}