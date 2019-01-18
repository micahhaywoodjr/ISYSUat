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
private class TestCaseReOpen 
{
    static Case c;
    static testMethod void myUnitTest() 
    {
        CaseReOpen reOpen = new CaseReOpen(new ApexPages.StandardController(c));
        reOpen.reOpenCase();
    }
    static
    {
    	Area__c area = new Area__c();
    	area.Name='706';
    	area.AreaNumber__c='1';
    	area.AssignedCaseManagers__c='Jim Tom; Billy Bob;';
    	insert area;
    	
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
        c.AssignmentRegion__c = area.Id;
        insert c;
        
        Surgery_Hospitalization__c sh = new Surgery_Hospitalization__c();
        sh.Case__c = c.Id;
        sh.Admission_Date__c=Date.today();        
        insert sh;
        
        Healthcare_Provider__c hcp = new Healthcare_Provider__c();
        hcp.Area__c=area.Id;
        hcp.Case__c=c.Id;
        hcp.Primary__c=true;
        hcp.ProviderStatus__c='Active';
        hcp.Specialty__c='Awesomeness';
        insert hcp;
    }
}