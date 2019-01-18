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
private class TestAreaTrg 
{
    static testMethod void myUnitTest() 
    {
        List<Area__c> aList = new List<Area__c>();
        Area__c a = new Area__c(Name='706',AreaNumber__c='1',Region__c='South');
        Area__c a2 = new Area__c(Name='706',AreaNumber__c='1',Region__c='South2');
        aList.add(a);
        aList.add(a2);
        try
        {
        	insert aList;
        	a2.Region__c='South';
        	update a2;
        }
        catch(DmlException e)
        {
        	System.debug(e);
        	System.assert(e.getDmlMessage(0).contains('duplicate'));
        }
    }
}