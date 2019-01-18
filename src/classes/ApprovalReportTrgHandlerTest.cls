@isTest
private class ApprovalReportTrgHandlerTest {
	
	private static testMethod void testInsert(){
		Account acc = new Account();
		acc.Name = 'Test';
		insert acc;
		
		Opportunity opp = new Opportunity();
		opp.CloseDate = Date.TODAY();
		opp.StageName = 'New';
		opp.AccountId = acc.Id;
		opp.Name = 'Test opp';
		insert opp;
		
		Approval_Report__c ar1 = new Approval_Report__c();
		ar1.Action__c = 'Step #1: A Note Report Approval';
		ar1.CaseReportEmployeeName__c = opp.Id;
		ar1.DateTime__c = Date.TODAY().addDays(-5);
		insert ar1;
		
		Test.startTest();
		Approval_Report__c ar2 = new Approval_Report__c();
		ar2.Action__c = 'Step #2: B Note Report Approval';
		ar2.CaseReportEmployeeName__c = opp.Id;
		ar2.DateTime__c = Date.TODAY().addDays(1);
		insert ar2;
		Test.stopTest();
		
		System.assertEquals([SELECT NewActionDate__c FROM Approval_Report__c WHERE Id =: ar1.Id].NewActionDate__c,Date.TODAY().addDays(1));
	}
	
}