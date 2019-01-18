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
private class TestBatchCaseMetrics 
{
    static List<Case> caseList;
    static testMethod void myUnitTest() 
    {
        caseList = [Select Id, AreaNumber__c, OwnerId, Owner.Username, IsClosed, Owner.Type,Status,OwnerAtCaseClose__c,ClosedDate FROM Case WHERE Status in ('Open','Re-Opened', 'Closed') and AssignmentRegion__c!=null and Id in :caseList];
        for(Case c : caseList)
        	System.debug('CLOSED------------------'+c.Status+':::'+c.IsClosed);
        BatchCaseMetrics bcm = new BatchCaseMetrics();
        bcm.execute(null, caseList);
        bcm.finish(null);
    }
    static
    {
    	List<Area__c> areaList = new List<Area__c>();
    	Area__c area1 = new Area__c();    	
    	area1.Name='706';
    	area1.AreaNumber__c='1';    	
    	areaList.add(area1);
    	    	
    	Area__c area2 = new Area__c();
    	area2.Name='707';
    	area2.AreaNumber__c='2';    	
    	areaList.add(area2);
    	
    	Area__c area3 = new Area__c();
    	area3.Name='708';
    	area3.AreaNumber__c='3';    	
    	areaList.add(area3);
    	
    	Area__c area4 = new Area__c();
    	area4.Name='709';
    	area4.AreaNumber__c='4';    	
    	areaList.add(area4);
    	insert areaList;
    	
    	Profile p = [SELECT p.Name,p.Id from Profile p where p.Name='Standard User' limit 1];
    	User u = new User(UserName='test@isys.com',email='test@isys.com',alias='tisys',communitynickname='tix',
		TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId=p.Id,LanguageLocaleKey='en_US',
	    FirstName='Test',LastName='User',IsActive=true,AssignedArea__c='706;707;708;');
		
		Test.startTest();
		insert u;
		Test.stopTest();
		
		Account a = new Account(Name='Test');
    	insert a;
    	Map<String, Contact> conMap = new Map<String, Contact>();
    	Contact con = new Contact(FirstName='Test', LastName='User', AccountId = a.Id, Phone='(706)602-6963');
    	conMap.put('706',con);
    	Contact con2 = new Contact(FirstName='Test', LastName='User', AccountId = a.Id, Phone='(707)602-6963');
    	conMap.put('707',con2);
    	Contact con3 = new Contact(FirstName='Test', LastName='User', AccountId = a.Id, Phone='(708)602-6963');
    	conMap.put('708',con3);
    	Contact con4 = new Contact(FirstName='Test', LastName='User', AccountId = a.Id, Phone='(709)602-6963');
    	conMap.put('709',con4);
    	insert conMap.values();
    	
    	caseList = new List<Case>();
    	Case c;
    	for(Area__c area : areaList)
    	{
	    	c = new Case();
	    	c.ContactId = conMap.get(area.Name).Id;
	    	c.OwnerId = u.Id;
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
	        caseList.add(c);
    	}
    	insert caseList;
    	
    	caseList.get(0).Status='Closed';
    	caseList.get(0).Rate__c='California';
    	caseList.get(0).Customer_Guidelines__c='my guidelines';
    	update caseList;
    }
}