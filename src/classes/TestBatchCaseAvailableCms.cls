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
private class TestBatchCaseAvailableCms 
{
    static List<Case> caseList = new List<Case>();
    static String availableCms='Jim Tom; Billy Bob;';
    static Case c;
    static Area__c area;
    static testMethod void myUnitTest() 
    {
        BatchCaseAvailableCms batch = new BatchCaseAvailableCms();
        batch.execute(null, caseList);
        batch.finish(null);
        c = [SELECT Id,AvailableCms__c FROM Case where Id=:c.Id];
        System.assertEquals(c.AvailableCms__c,availableCms);
        
        delete area;
        batch.execute(null, caseList);
        c = [SELECT Id,AvailableCms__c FROM Case where Id=:c.Id];
        System.assertEquals(c.AvailableCms__c,null);
    }
    static testMethod void testSchedulable()
    {
    	Test.startTest();        
    	String cron = '0 0 0 17 11 ? 2033';
    	System.schedule('BATR99zz', cron, new BatchCaseAvailableCmsSchedulable());
    	Test.stopTest();
    }
    static
    {
    	area = new Area__c();
    	area.Name='706';
    	area.AreaNumber__c='1';
    	area.AssignedCaseManagers__c=availableCms;
    	insert area;
    	
    	c = new Case();
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
        c.AssignmentRegion__c = area.Id;
        insert c;
        caseList.add(c);
    }
}