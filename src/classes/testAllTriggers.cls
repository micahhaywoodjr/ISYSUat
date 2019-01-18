/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class testAllTriggers {

    static testMethod void testCaseAfterUpdate() 
    {
      List<Rate_Card__c> lstRc = new List<Rate_Card__c>([Select Account__c, Travel_Wait_Rate__c from Rate_Card__c Where Account__c<>null limit 1]);
        Case oCase = new Case();
        oCase.AccountId = lstRC[0].Account__c;
        oCase.Employee__c = lstRC[0].Account__c;
        oCase.Supervised_by__c = 'Senior Mentor';
        oCase.QB_Service_Item__c = 'ER';
        oCase.Current_Diagnosis__c = 'Test';
        oCase.Nature_and_History_of_Injury__c = 'Another test';
        oCase.Origin = 'Web';
        oCase.Priority = 'High';
        oCase.Jurisdiction__c = 'California-WC';
        oCase.Employee_Case_Trakker__c = 'testMe';
        insert oCase;
        Opportunity opp = new Opportunity(name='Test Opportunity 1.0', Amount=0.0, closedate=system.today(),stageName ='Submitted', Service_Date_Thru__c=system.today());
        opp.Related_Case__c = oCase.Id;
        opp.AccountId = oCase.AccountId;
        //insert opp;
        List<Case> lstCase = new List<Case>([Select Jurisdiction__c From Case Where AccountId = :  lstRC[0].Account__c and Employee__c = : lstRC[0].Account__c]);
        for(Case objCase : lstCase)
            objCase.Jurisdiction__c = 'Nevada-WC';
        update lstCase;
        lstRC[0].Travel_Wait_Rate__c = 20;
        update lstRC;
    }
}