/**
 * Created by Speedy2 on 3/7/17.
 */

@IsTest
private class TestSurveyResultsTrigger {

    Static Case c;

    static void setupData()
    {
        Account acct = new Account(Name='Test');
        insert acct;

        c = new Case();
        c.Supervised_by__c = 'MySelf';
        c.Status = 'Closed';
        c.QB_Service_Item__c = 'ER';
        c.Priority = 'High';
        c.Origin = 'Web';
        c.Nature_and_History_of_Injury__c = 'Nothing';
        c.Employee_Case_Trakker__c = 'Nothing';
        c.Current_Diagnosis__c = 'Fine';
        c.Jurisdiction__c = 'California-WC';
        c.QB_Service_Item__c = 'MCM-On Site';
        //c.AssignmentRegion__c = area.Id;
        insert c;

        Survey_Results__c sr1 = new Survey_Results__c(Case__c=c.Id, Overall_Rating__c = 9);
        Survey_Results__c sr2 = new Survey_Results__c(Case__c=c.Id, Overall_Rating__c = 19);
        Survey_Results__c sr3 = new Survey_Results__c(Case__c=c.Id, Overall_Rating__c = 119);
        List<Survey_Results__c> sr = new List<Survey_Results__c>();

        sr.add(sr1);
        sr.add(sr2);
        sr.add(sr3);
        insert sr;
    }

    static testMethod void testBehavior() {

        setupData();

        List<Survey_Results__c> surveyResults = [SELECT id, Name FROM Survey_Results__c];

        for(Survey_Results__c sr : surveyResults) {

            delete sr;

        }
    }
}