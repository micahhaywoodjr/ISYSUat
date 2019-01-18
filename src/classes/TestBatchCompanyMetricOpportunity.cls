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
private class TestBatchCompanyMetricOpportunity 
{
    static List<Opportunity> oppList = new List<Opportunity>();
    static testMethod void myUnitTest() 
    {
        BatchCompanyMetricOpportunity mOpp = new BatchCompanyMetricOpportunity();
        mOpp.execute(null, oppList);
        mOpp.finish(null);
        CompanyMetric__c cm = [SELECT ReportsInProcess__c,ReportsSubmitted__c,ReportsApproved__c,ReportsCompleted__c FROM CompanyMetric__c WHERE ExternalId__c=:mOpp.runDateMonthYear];
        System.assertEquals(1,cm.ReportsApproved__c);
        System.assertEquals(1,cm.ReportsSubmitted__c);
        System.assertEquals(1,cm.ReportsInProcess__c);
        System.assertEquals(1,cm.ReportsCompleted__c);
    }
    static
    {    	
    	oppList.add(new Opportunity(StageName='In Process'));
    	oppList.add(new Opportunity(StageName='Submitted'));
    	oppList.add(new Opportunity(StageName='Approved'));
    	oppList.add(new Opportunity(StageName='Completed',ActualCompletedDate__c=Date.today()));    	
    }
}