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
private class TestBatchCompanyMetricUser 
{
    static List<User> uList = new List<User>();
    static testMethod void myUnitTest() 
    {
        BatchCompanyMetricUser mUser = new BatchCompanyMetricUser();
        uList = [Select Id,Profile.Name FROM User where Id in :uList];
        mUser.execute(null, uList);
        mUser.finish(null);
        
        CompanyMetric__c cm = [SELECT CaseManagers__c,AdminStaff__c,QAStaff__c FROM CompanyMetric__c WHERE ExternalId__c=:mUser.runDateMonthYear];
        System.assertEquals(1,cm.CaseManagers__c);
        System.assertEquals(1,cm.AdminStaff__c);
        System.assertEquals(1,cm.QAStaff__c);
    }
    static testMethod void testSchedulable()
    {
    	Test.startTest();        
    	String cron = '0 0 0 17 11 ? 2033';
    	System.schedule('BATR99zz', cron, new BatchCompanyMetricUserSchedulable());
    	Test.stopTest();
    }
    static
    {
    	integer i=0;
    	for(Profile p : [SELECT Id FROM Profile WHERE Name in ('Custom - Nurse','Custom - Admin Staff','Custom - QA Staff')])
    	{
    		uList.add(new User(UserName='test@isys.com'+i,email='test@isys.com',alias='tisys'+i,communitynickname='tix'+i,TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId=p.Id,LanguageLocaleKey='en_US',FirstName='Test',LastName='User',IsActive=true,AssignedArea__c='706;707;708;'));
    		i++;
    	}
    	insert uList;    	
    }
}