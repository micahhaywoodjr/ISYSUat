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
private class TestCmAssignmentTrg 
{
    static List<CMAssignment__c> cmaList;
    static List<User> userList = new List<User>();
    static testMethod void myUnitTest() 
    {
        /*for(CMAssignment__c cma : cmaList)
        {
        	System.debug('CaseManager:::'+cma.CaseManager__c);
        	System.debug('ExternalId:::'+cma.ExternalId__c);
        	System.debug('CaseManagerName:::'+cma.CaseManagerName__c);
        	System.debug('Area:::'+cma.Area__c);
        	System.debug('AreaNumber:::'+cma.AreaNumber__c);
        	if(cma.CaseManager__c!=userList.get(0).Id)
        		cma.CaseManager__c=userList.get(0).Id;
        }*/
        update cmaList;
        
        delete cmaList;
    }
    static
	{
		List<Area__c> areaList = new List<Area__c>();
		Profile p = [SELECT p.Name,p.Id from Profile p where p.Name='Standard User' limit 1];
    	areaList.add(new Area__c(Name='706',AreaNumber__c='1',Region__c='South'));
    	areaList.add(new Area__c(Name='707',AreaNumber__c='1',Region__c='South'));
    	areaList.add(new Area__c(Name='770',AreaNumber__c='2',Region__c='South'));
    	areaList.add(new Area__c(Name='771',AreaNumber__c='2',Region__c='South'));
    	areaList.add(new Area__c(Name='716',AreaNumber__c='3',Region__c='South'));
    	areaList.add(new Area__c(Name='717',AreaNumber__c='3',Region__c='South'));
    	areaList.add(new Area__c(Name='726',AreaNumber__c='4',Region__c='South'));
    	insert areaList;
    	
    	for(integer i=0; i<3; i++)
    	{
	    	User u = new User(UserName='test@isys.com'+i,email='test'+i+'@isys.com',alias='tisys'+i,communitynickname='tix'+i,
			TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId=p.Id,LanguageLocaleKey='en_US',
	    	FirstName='Test',LastName='User',IsActive=true,AssignedArea__c='706;707;770;771;716;',AssignedRegion__c='South');
			userList.add(u);
    	}
    	Test.startTest();
    	insert userList;
		Test.stopTest();    	
    	cmaList = [Select c.Name, c.ExternalId__c, c.CaseManager__c, c.CaseManagerName__c, c.Area__c, c.AreaNumber__c From CMAssignment__c c where c.CaseManager__c in :userList];
	}
}