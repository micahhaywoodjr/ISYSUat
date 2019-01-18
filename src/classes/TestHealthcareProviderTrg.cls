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
private class TestHealthcareProviderTrg 
{
    static Case c;
    static Area__c area;
    static Area__c area2;
    static Contact con;
    static Healthcare_Provider__c hcp;
    static testMethod void myUnitTest() 
    {
        c = [SELECT Id, AssignmentRegion__c FROM Case where Id=:c.Id];
        System.assertEquals(area.Id, c.AssignmentRegion__c);
        con.Phone='(770)377.7126';
        //this tests that when the contact phone number changes the ContactTrg updates the related HCP records
        update con;
        c = [SELECT Id, AssignmentRegion__c FROM Case where Id=:c.Id];
        System.assertEquals(area2.Id, c.AssignmentRegion__c);
    }
    static
    {
    	List<Area__c> areaList = new List<Area__c>();
    	area = new Area__c();
    	area.Name='706';
    	area.AreaNumber__c='1';
    	area.Region__c='South';
    	areaList.add(area);
    	
    	area2 = new Area__c();
    	area2.Name='770';
    	area2.AreaNumber__c='1';
    	area2.Region__c='South';
    	areaList.add(area2);
    	insert areaList;
    	
    	Account a = new Account(Name='Test');
    	insert a;
    	
    	con = new Contact(FirstName='Test', Region__c='South', LastName='User', AccountId = a.Id, Phone='(706)602-6963');
    	insert con;
    	
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
        c.ContactId = con.Id;        
        insert c;
        
    	hcp = new Healthcare_Provider__c();
    	hcp.Case__c = c.Id;
    	hcp.Primary__c = true;
    	//hcp.Inactive__c = false;
    	hcp.ProviderStatus__c='Active';
    	hcp.Contact__c = con.Id;
    	hcp.Specialty__c = 'MD';
    	//hcp.AreaRegion__c=con.Region__c;
    	insert hcp;
    }
}