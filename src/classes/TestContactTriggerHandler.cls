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


@isTest(SeeAllData = true)
private class TestContactTriggerHandler 
{
	static void setupData()
	{
		Area__c a1 = new Area__c(Name='111',Region__c='Test Region1');
		Area__c a2 = new Area__c(Name='000',Region__c='Test Region2');
		List<Area__c> areas = new List<Area__c>();
		areas.add(a1);
		areas.add(a2);
		insert areas;
	}
    static testMethod void testAll() 
    {
    	setupData();
    	Account a = new Account(Name ='test account1');
    	insert a;
    	
        Contact c = new Contact(accountid = a.id,FirstName ='test first', lastName = 'test last',Phone = '(111)-222-2222',Region__c='Test Region1' );
        insert c;
        
        c.Region__c = 'Test Region2';
        c.Phone = '(000)-222-2222';
        update c;
    }
}