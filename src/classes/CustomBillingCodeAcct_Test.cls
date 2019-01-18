/*
Class Name    :  CustomBillingCodeAcct_Test
Created by    : James Amos @ Levementum
Created On    : 04-03-2017
Description   : Code Coverage for  CustomBillingCodeAcct
 */

@IsTest
public with sharing class CustomBillingCodeAcct_Test {
    @TestSetup static void testData(){
        Environment_Settings__c e = new Environment_Settings__c();
        e.Name = 'Environment';
        e.ResultsNotificationEmail__c = 'test@testing.com';
        e.batchSize__c = 10;
        e.NewAcctBillingCodeBatchSize__c= 10;
        insert e;
        
        Account a = new Account(Name='Test Account',CustomBillCodeProcessed__c = false,UseCustomBillingCode__c = false);
        insert a;

        List<Billing_Code__c> bcList = new List<Billing_Code__c>();
        List<Billing_Code__c> bcDefaultList = new List<Billing_Code__c>();
        for(integer i=0;i<10;i++)
        {
            Billing_Code__c bc = new Billing_Code__c();
            bc.Name = '0' + i + '- Standard Progress Report';
            bc.Min__c=.5;
            bc.Max__c=1.0;
            bc.Active__c=true;
            bc.DefaultCode__c=true;
            bcDefaultList.add(bc);
        }
        insert bcDefaultList;

        Account acct = [SELECT Id,Name FROM Account WHERE Name ='Test Account'];
        Account acct1 = [SELECT Id,Name FROM Account WHERE Name ='Test Account'];

        Opportunity opp = new Opportunity();
        opp.name = 'testOpp';
        opp.StageName = 'In Process';
        opp.CloseDate = Date.valueOf('2017-01-01');
        opp.accountId = acct.Id;
        opp.CustomBillCodeProcessed__c = false;
        insert opp;

        Opportunity Opty = [SELECT Id,Name from Opportunity where Name = 'testOpp'];
        List<Billing_Code__c> bcdList = [Select Id from Billing_Code__c where  Name like '%Standard Progress Report'];

        Case_Note_Entry__c cne = new Case_Note_Entry__c();
        cne.Report__c = Opty.Id;
        cne.Professional_Hours_Nurse__c = 1;
        cne.Professional_Hours__c = 1;
        cne.Adj_Professional_Hours__c = 1;
        cne.Billing_Code__c = bcdList[0].Id;
        Insert cne;

        List<Billing_Code__c> bcDefaultListt = [Select Id,Name from Billing_Code__c where DefaultCode__c=true];
        Integer j=0;
        for(Billing_Code__c defaultBc:  bcDefaultListt)
        {
            Billing_Code__c bc = new Billing_Code__c();
            bc.Name = 'Best'+j;
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

    }

    @IsTest
    static void CustomBillingCodeAcct_Success(){
        Test.startTest();
        Database.executeBatch(new CustomBillingCodeAcct(),1);
        Test.stopTest();
    }
}