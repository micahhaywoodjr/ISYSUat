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
private class TestBatchCaseNoteEntryMetrics 
{
	static List<Case_Note_Entry__c> cneList = new List<Case_Note_Entry__c>();
	static Opportunity opp;
	static testMethod void myUnitTest() 
    {
    	BatchCaseNoteEntryMetrics cneMetrics = new BatchCaseNoteEntryMetrics();
    	

    	System.debug(cneList);
    	cneMetrics.execute(null, cneList);
    	cneMetrics.finish(null);
    }
    static
    {
		Environment_Settings__c e = new Environment_Settings__c();
		e.Name = 'Environment';
		e.ResultsNotificationEmail__c = 'test@testing.com';
		e.batchSize__c = 10;
		e.NewAcctBillingCodeBatchSize__c = 10;
		insert e;

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
    	
    	Profile p = [SELECT p.Name,p.Id from Profile p where p.Name='Custom - Nurse' limit 1];
    	Profile p2 = [SELECT p.Name,p.Id from Profile p where p.Name='Custom - Sr Nurse' limit 1];
    	
    	List<User> userList = new List<User>();
    	User u = new User(UserName='test@isys.com',email='test@isys.com',alias='tisys',communitynickname='tix',
		TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId=p.Id,LanguageLocaleKey='en_US',
	    FirstName='Test',LastName='User',IsActive=true,AssignedArea__c='706;707;708;');
		
		User coveringNurse = new User(UserName='test2@isys.com',email='test@isys.com',alias='tisy2',communitynickname='tix2',
		TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId=p2.Id,LanguageLocaleKey='en_US',
	    FirstName='Test',LastName='User',IsActive=true,AssignedArea__c='706;707;708;');
		userList.add(u);
		userList.add(coveringNurse);
		Test.startTest();
		insert userList;
		Test.stopTest();
		
		List<Billing_Code__c> bcList = new List<Billing_Code__c>();
        Billing_Code__c profBc= new Billing_Code__c(name ='ECT',DefaultCode__c=true,Active__c=true,Min__c=0.5,Max__c=3);
        bcList.add(profBc);
        Billing_Code__c waitBc= new Billing_Code__c(name ='T01',DefaultCode__c=true,Active__c=true,Min__c=1,Max__c=3);
        bcList.add(waitBc);        
        insert bcList;
		
		System.runAs(u)
		{
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
	    	
	    	Case c = new Case(Supervised_by__c = 'MySelf',Status = 'Open',QB_Service_Item__c = 'ER',Priority = 'High',
        					Origin = 'Web',Nature_and_History_of_Injury__c = 'Nothing',Employee_Case_Trakker__c = 'Nothing',
        					Current_Diagnosis__c = 'Fine',Jurisdiction__c = 'Jurisdiction__c OLD',
        					AssignmentRegion__c = areaList[2].Id);
	    	insert c;

	    	System.debug('Case Region ' + c.AssignmentRegion__r.AreaNumber__c);
	    	
	    	opp = new Opportunity(
	    					name='Test Opportunity 1.0',
	    					AccountId=a.Id,
	    					//Related_Case__c = c.Id,
	    					Amount=0.0,
	    					CloseDate=system.today(),
	    					stageName ='Submitted',
	    					Service_Date_From__c=Date.today(),
	    					Service_Date_Thru__c=Date.today().addDays(2), 
	    					Report_Submission_Date__c=system.today(),
	    					A_Note_Approval_Date_Time__c=system.today());
	        System.debug('-----------------'+opp.Service_Date_From__c);
	        System.debug('-----------------'+opp.Service_Date_Thru__c);
	        insert opp;

	        opp.Related_Case__c = c.Id;
	        update opp;
			
	        Case_Note_Entry__c profCne = 
	        		new Case_Note_Entry__c(
	        				Primary_Nurse__c=true,Report__c=opp.Id, Billing_Code__c=profBc.Id,
	        				Professional_Hours_Nurse__c=1,
	        				Adj_Professional_Hours__c=1,
	        				Professional_Hours__c=1
	        				);
	        insert profCne;
	        cneList.add(profCne);      


	        Case_Note_Entry__c profCne2 = 
	        		new Case_Note_Entry__c(
	        				Primary_Nurse__c=true,Report__c=opp.Id, Billing_Code__c=waitBc.Id,
	        				Travel_Wait_Hours_Nurse__c=1,
							Adj_Travel_Wait_Hours__c=1,
							Travel_Wait_Hours__c=1,
							Adj_Mileage__c=1,
							Mileage__c=1,
							Mileage_Nurse__c=1,
							Driving_From_City__c='SF',
							Driving_To_City__c='SD',
							Adj_Expenses__c=1,
							Expenses__c=1,
							Expenses_Nurse__c=1
	        				);
	        insert profCne2;
	        cneList.add(profCne2);      
	        		
		}
		system.runAs(coveringNurse)
		{
			Case_Note_Entry__c waitCne = 
					new Case_Note_Entry__c(
							Covering_Nurse__c=true,Report__c=opp.Id, Billing_Code__c=waitBc.Id,
							Travel_Wait_Hours_Nurse__c=1,
							Adj_Travel_Wait_Hours__c=1,
							Travel_Wait_Hours__c=1,
							Adj_Mileage__c=1,
							Mileage__c=1,
							Mileage_Nurse__c=1,
							Driving_From_City__c='SF',
							Driving_To_City__c='SD',
							Adj_Expenses__c=1,
							Expenses__c=1,
							Expenses_Nurse__c=1);
			insert waitCne;
        	cneList.add(waitCne);
		}
    	
    	cneList = [SELECT 
    				Primary_Nurse__c,Covering_Nurse__c,Adj_Travel_Wait_Hours__c,Adj_Professional_Hours__c,Adj_Mileage__c,
    				Adj_Expenses__c,CreatedById,CreatedBy.UserName,Report__r.Report_Submission_Date__c,
    				Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c,
    				Report__c,Travel_Wait_Hours__c,Travel_Wait_Hours_Nurse__c,Professional_Hours__c,
    				Professional_Hours_Nurse__c,Mileage__c,Mileage_Nurse__c,Expenses__c,Expenses_Nurse__c 
    				FROM Case_Note_Entry__c 
    				WHERE Report__r.StageName in ('Submitted','Approved','Completed') AND CreatedBy.IsActive=true and Id in :cneList];

    	System.debug(cneList);
		
    }
}