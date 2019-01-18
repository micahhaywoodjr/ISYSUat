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
private class TestUpdateActivityDate {

    static testMethod void updateTest() {
        Opportunity opp = new Opportunity(name='Test Opportunity 1.0', Amount=0.0, closedate=system.today(),stageName ='Submitted', Service_Date_Thru__c=system.today());
        insert opp;
        
        Billing_Code__c bill= new Billing_Code__c(name ='01 Test Report',DefaultCode__c=true,Active__c=true);
        insert bill;
        
        Case_Note_Entry__c cne = new Case_Note_Entry__c(Report__c=opp.Id, Billing_Code__c=bill.id,Professional_Hours_Nurse__c = 1);
        insert cne;
        
        update opp;        
    }
}