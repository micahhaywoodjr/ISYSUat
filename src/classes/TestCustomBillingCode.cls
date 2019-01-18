/*

Class Name    : TestCustomBillingCode
Modified  by  : Levementum LLC - James Amos
Modified On   : 03-30-2017
Description   : Code Coverage for CustomBillingCode Controller
*/
@isTest
private class TestCustomBillingCode 
{

    @testSetup static void testData() {
        Environment_Settings__c e = new Environment_Settings__c();
        e.Name = 'Environment';
        e.ResultsNotificationEmail__c = 'test@testing.com';
        e.NewAcctBillingCodeBatchSize__c= 10;
        insert e;

        a = new Account(Name='Test Account');
        insert a;
        List<Billing_Code__c> bcList = new List<Billing_Code__c>();
        List<Billing_Code__c> bcDefaultList = new List<Billing_Code__c>();
        for(integer i=0;i<10;i++)
        {
            Billing_Code__c bc = new Billing_Code__c();
            bc.Name = '0' + i + '- Standard Progress Report';
            bc.Min__c=1;
            bc.Max__c=2;
            bc.Active__c=true;
            bc.DefaultCode__c=true;
            bcDefaultList.add(bc);
        }
        insert bcDefaultList;

        Account acct = [SELECT Id,Name FROM Account WHERE Name ='Test Account'];
        Opportunity opp = new Opportunity();
        opp.name = 'testOpp';
        opp.StageName = 'In Process';
        opp.CloseDate = Date.valueOf('2017-01-01');
        opp.accountId = acct.Id;
        insert opp;
        Opportunity Opty = [SELECT Id,Name from Opportunity where Name = 'testOpp'];

        for(integer k=0;k<10;k++) {
            Case_Note_Entry__c cne = new Case_Note_Entry__c();
            cne.Report__c = Opty.Id;
            cne.Professional_Hours_Nurse__c = 10;
            Insert cne;
        }

        List<Billing_Code__c> bcDefaultListt = [Select Id,Name from Billing_Code__c where DefaultCode__c=true];
        Integer j=0;
        for(Billing_Code__c defaultBc:  bcDefaultListt)
        {
            Billing_Code__c bc = new Billing_Code__c();
            bc.Name = 'Test'+j;
            bc.Min__c=1;
            bc.Max__c=2;
            bc.Active__c=true;
            bc.DefaultCode__c=false;
            bc.Account__c = acct.Id;
            bc.DefaultBillingCode__c = defaultBc.Id;
            bc.Account__c = acct.Id;
            bcList.add(bc);
            j++;
        }
        insert bcList;
        List<Billing_Code__c> bcdList = [Select Id from Billing_Code__c where  Name like '%Standard Progress Report'];

        Case_Note_Entry__c cne = new Case_Note_Entry__c();
        cne.Report__c = Opty.Id;
        cne.Professional_Hours_Nurse__c = 1;
        cne.Professional_Hours__c = 1;
        cne.Adj_Professional_Hours__c = 1;
        cne.Billing_Code__c = bcdList[0].Id;

        Insert cne;


    }

    static Account a;

    static testMethod void updateCustomBillingCode_Success()
    {
        Account acct = [SELECT Id,Name,UseCustomBillingCode__c,(Select Id From Billing_Codes__r) FROM Account WHERE Name ='Test Account'];
        CustomBillingCode cBc = new CustomBillingCode(new ApexPages.StandardController(acct));
        List<CustomBillingCode.BillingCodeChange> bcList = cbc.defaultList;
        List<SelectOption> searchSelect = cbc.searchSelect; 
        for(CustomBillingCode.BillingCodeChange bcc : bcList)
        {
        	bcc.getBillingCode();
        	bcc.getOriginalMax();
        	bcc.getOriginalMin();
        }
        System.assertEquals(10,bcList.size());
        cbc.save();
        
        //a = [SELECT Id, UseCustomBillingCode__c, (Select Id From Billing_Codes__r) FROM Account where Id=:a.Id];
        System.assertEquals(true, acct.UseCustomBillingCode__c);
        System.assertEquals(10,acct.Billing_Codes__r.size());
        
        //make sure that when the account uses custom billing it updates the records
        cBc = new CustomBillingCode(new ApexPages.StandardController(acct));
        bcList = cbc.defaultList;
        cBc.save();
        
        //a = [SELECT Id, UseCustomBillingCode__c, (Select Id From Billing_Codes__r) FROM Account where Id=:a.Id];
        acct = [SELECT Id,Name,UseCustomBillingCode__c,(Select Id From Billing_Codes__r) FROM Account WHERE Name ='Test Account'];
        System.assertEquals(true, acct.UseCustomBillingCode__c);
        System.assertEquals(20, acct.Billing_Codes__r.size());

        cBc.backToAccount();
    }

}