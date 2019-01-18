@isTest
private class Test_CaseAfterUpdate {

    static testMethod void myUnitTest() {
        Case c = new Case();
        c.Supervised_by__c = 'MySelf';
        c.Status = 'Open';
        c.QB_Service_Item__c = 'ER';
        c.Priority = 'High';
        c.Origin = 'Web';
        c.Nature_and_History_of_Injury__c = 'Nothing';
        c.Employee_Case_Trakker__c = 'Nothing';
        c.Current_Diagnosis__c = 'Fine';
        c.Jurisdiction__c = 'Jurisdiction__c OLD';
        c.QB_Service_Item__c = 'QB_Service_Item__c OLD';
        insert c;
        
        Account a = new Account();
		a.Name = 'ACC1';
		insert a;
        
        Opportunity o = new Opportunity();
		o.AccountId = a.id;
		o.Name = 'test o1';
		o.Employee__c = a.Id;
		o.Service_Date_Thru__c = system.today();
		o.CloseDate = system.today();
		o.StageName = 'In Process';
		o.Amount_Locked__c = false;
		o.Current_Prognosis__c = 'Hi';
		o.TTD__c = 'sdfsdf';
		o.Status_of_EE_Job_Descriptions_JD__c = 'JD Not Applicable'; 
		o.Status_of_EE_Job_Analysis_JA__c = 'JA Not Applicable'; 
		o.Remain_U_C__c = 'sdfsdf'; 
		o.I_Will__c = 'I Will'; 
		o.Employer_Status__c = 'Employer'; 
		o.Employee_Status__c = 'Employee'; 
		o.Employee_Motivation_to_Return_to_Work__c = 'sdfsdf'; 
		o.Diagnostics_Evidence_Based_Information__c = 'sdfsdf'; 
		o.Current_Work_Status__c = 'asdad'; 
		o.Current_Treatment__c = 'asdad'; 
		o.Current_Prognosis__c = 'adad';
		o.Related_Case__c = c.Id;
		insert o;
        
        
        c.Origin = 'Phone';
        c.Jurisdiction__c = 'Jurisdiction__c New';
        c.QB_Service_Item__c = 'QB_Service_Item__c New';
        update c;
        
        
        
    }
}