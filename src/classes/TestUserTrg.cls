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
private class TestUserTrg 
{
    static List<User> userList;
    static testMethod void myUnitTest() 
    {
        Test.startTest();
    	insert userList;
    	Test.stopTest();
    	
        for(User u : userList)
        {
        	u.AssignedArea__c='701;702;703';
        	u.AssignedRegion__c='North';
        }
        update userList;
    }
    static
    {
    	userList = new List<User>();
    	Profile p = [SELECT p.Name,p.Id from Profile p where p.Name='Standard User' limit 1];
    	List<Area__c> areaList = new List<Area__c>();
    	//for(integer x=0;x<200;x++)
    	//{
	    	for(integer i=1; i<5; i++)
	    	{
    		  areaList.add(new Area__c(Name='70'+i,AreaNumber__c=String.valueOf(i),Region__c='South'));
    		  areaList.add(new Area__c(Name='70'+i,AreaNumber__c=String.valueOf(i),Region__c='North'));
	    	}
    	//}
    	insert areaList;
    	for(integer i=0; i<3; i++)
    	{
	    	User u = new User(UserName='test@isys.com'+i,email='test'+i+'@isys.com',alias='tisys'+i,communitynickname='tix'+i,
			TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId=p.Id,LanguageLocaleKey='en_US',
	    	FirstName='Test',LastName='User',IsActive=true,AssignedArea__c='702;703;704;',AssignedRegion__c='South');
			userList.add(u);
    	}    	
    }
}