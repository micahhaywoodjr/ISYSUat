@IsTest
private class OpportunityApprovalQueueControllerTest 
{
    testMethod static void testOpportunityApprovalQueueController() 
    {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opp';
        testOpp.AccountId = testAccount.Id;
        testOpp.StageName = 'In Process';
        testOpp.CloseDate = System.today();
        testOpp.P_S_Comment__c = 'Test';
        testOpp.In_Review__c = 'No';
        testOpp.Service_Date_From__c = System.today();
        testOpp.Service_Date_Thru__c = System.today();
        insert testOpp;
        
        Case_Note_Entry__c testCaseNote = new Case_Note_Entry__c();
        testCaseNote.Expenses__c = 10;                
        testCaseNote.Professional_Hours__c = 10;
        testCaseNote.Report__c = testOpp.Id;
        testCaseNote.Adj_Professional_Hours__c = 0;        
        testCaseNote.Adj_Expenses__c = 10;        
        testCaseNote.Professional_Hours_Nurse__c = 1;                
        testCaseNote.Expenses_Nurse__c = 1;
        testCaseNote.Work_Description__c = 'Test';
        testCaseNote.Activity_Date__c=Date.today();
        insert testCaseNote;
        
        Approval.ProcessSubmitRequest testRequest = new Approval.ProcessSubmitRequest();
        testRequest.setComments('Submitting request for approval.');
        testRequest.setObjectId(testOpp.Id);
        
        Approval.ProcessResult result = Approval.process(testRequest);
        
        User approverUser = new User();
        List<ProcessInstanceWorkitem> workitems = [SELECT Id, ActorId, Actor.Id, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:testOpp.Id limit 1];
        if (!workitems.isEmpty()) 
        {
            approverUser = [SELECT Id, Name FROM User WHERE Id =: workitems[0].ActorId];
            System.debug('Run As: ' + approverUser.Name);
        }
        
        // Create and initialize our controller
        System.runAs(approverUser) 
        {
            Test.startTest();
            
            PageReference testPage = Page.OpportunityApprovalQueue;
            Test.setCurrentPage(testPage);
            
            OpportunityApprovalQueueController controller = new OpportunityApprovalQueueController();
            controller.InitializeController();
            
            Test.stopTest();
        }
    }       
}