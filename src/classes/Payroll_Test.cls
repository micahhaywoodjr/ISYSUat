/*This test class is implemented only at a base level.No test coverage existed for this class.*/

@isTest
private class Payroll_Test {

	private static testMethod void testConstructor(){
		System.debug('testConstructorx');


		User coveringNurse = [select id from user where UserName='test2@isys.com'];
		User otherNurse = [select id from user where UserName='test@isys.com'];
		Opportunity onlyOpp = [select id from Opportunity limit 1];
		System.debug('nurse '+coveringNurse);
		System.debug('onlyOpp '+onlyOpp);
		System.debug('select the employee list '+[SELECT Id, Employee__c, Employee__r.SF_User__r.Name FROM Payroll__c WHERE DateSubmitted__c >= :Date.TODAY().addDays(-10) AND DateSubmitted__c <= :Date.TODAY().addDays(10)]);
		Payroll controller = new PayRoll();
		controller.prTemp.sDate__c = Date.TODAY().addDays(-10);
		controller.prTemp.eDate__c = Date.TODAY().addDays(10);
		controller.processDateChange();
		controller.processDateChange();
		//additional test coverage Levementum 3/6/17
		//go to page
		System.debug('initialize page');
		PageReference pageRef = Page.Payroll;
		Test.setCurrentPage(pageRef);
		Test.setCurrentPageReference(pageRef);
		System.currentPageReference().getParameters().put('tEmployeeType', 'selected');
		System.currentPageReference().getParameters().put('tEmployee', coveringNurse.Id);
		System.currentPageReference().getParameters().put('tEmployeeName', 'Test+Person');
		System.currentPageReference().getParameters().put('sDate', '2017-01-01');
		System.currentPageReference().getParameters().put('eDate', '2099-01-01');


		//start controller
		Payroll payController = new PayRoll();

		payController.prTemp.sDate__c = Date.TODAY().addDays(-10);
		payController.prTemp.eDate__c = Date.TODAY().addDays(10);

		payController.processDateChange();
		System.debug('payController.toBeProcessedList '+payController.toBeProcessedList);
		System.debug('payController.processedList '+payController.processedList);
		payController.toBeProcessedSelected=coveringNurse.Id;
		payController.processedSelected=otherNurse.Id;

		System.debug('call functions');

		//add a row
		payController.addRow();
		//remove row
//		payController.deleteRow();
		payController.save_state();

		Test.setCurrentPage( payController.previous_page());
//		Case_Note_Entry__c cne : [Select CreatedById, CreatedBy.Name, Report__r.RelatedCaseNoLeadingZero__c, Report__r.Report_Submission_Date__c, Report__r.Name, Report__r.Employee__c, Professional_Hours__c, Travel_Wait_Hours__c, Report__r.Employee__r.Name, Report__c From Case_Note_Entry__c]
//		System.debug('case note filtered '+[Select CreatedById, CreatedBy.Name, Report__r.RelatedCaseNoLeadingZero__c, Report__r.Report_Submission_Date__c, Report__r.Name, Report__r.Employee__c, Professional_Hours__c, Travel_Wait_Hours__c, Report__r.Employee__r.Name, Report__c From Case_Note_Entry__c]);
		System.debug('cn unfiltered '+[Select CreatedBy.ProfileId ,CreatedById, CreatedBy.Name, Report__r.RelatedCaseNoLeadingZero__c, Report__r.Report_Submission_Date__c, Report__r.Name, Report__r.Employee__c, Professional_Hours__c, Travel_Wait_Hours__c, Report__r.Employee__r.Name, Report__c From Case_Note_Entry__c]);

		String fn = payController.fullName;
		String fn2 = payController.firstName;
		decimal th = payController.threshold;
		//user added payroll temp
		System.debug('onlyOpp.id '+onlyOpp.id);
		PayrollTemp__c uapTemp =new PayrollTemp__c(Opportunity__c=onlyOpp.id);
		insert uapTemp;
		System.debug('uapTemp '+uapTemp);
		payController.userAddedPrTemp=uapTemp;
		payController.addRow();
		payController.deleteRow();
		payController.save_state();
		PageReference anotherpr = payController.previous_page_redirect();
		PageReference anotherpr2 = payController.cancel();
		Test.setCurrentPage( payController.confirm());
		Test.setCurrentPage( payController.save());
		payController.resetProcessed();
		payController.resetToBeProcessed();

//		Test.stopTest();
	}
	
	static
    {
		Environment_Settings__c e = new Environment_Settings__c();
		e.Name = 'Environment';
		e.ResultsNotificationEmail__c = 'test@testing.com';
		e.batchSize__c = 10;
		e.NewAcctBillingCodeBatchSize__c = 10;
		insert e;

		Opportunity opp;
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
		//need to have employee records
		list<SFDC_Employee__c> new_emp_list = new List<SFDC_Employee__c>();
		SFDC_Employee__c e1=new SFDC_Employee__c(SF_User__c=u.Id,SF_Username__c=u.UserName);
		SFDC_Employee__c e2=new SFDC_Employee__c(SF_User__c=coveringNurse.Id,SF_Username__c=coveringNurse.UserName);
		new_emp_list.add(e1);
		new_emp_list.add(e2);
		System.debug('new_emp_list '+new_emp_list);
		insert new_emp_list;
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
        					Current_Diagnosis__c = 'Fine',Jurisdiction__c = 'Jurisdiction__c OLD');
	    	insert c;
	    	
	    	opp = new Opportunity(name='Test Opportunity 1.0',AccountId=a.Id,Amount=0.0,CloseDate=system.today(),stageName ='Submitted',Service_Date_From__c=Date.today(),Service_Date_Thru__c=Date.today().addDays(2), Report_Submission_Date__c=system.today(),A_Note_Approval_Date_Time__c=system.today());
	        System.debug('-----------------'+opp.Service_Date_From__c);
	        System.debug('-----------------'+opp.Service_Date_Thru__c);
	        insert opp;
			
	        Case_Note_Entry__c profCne = new Case_Note_Entry__c(Primary_Nurse__c=true,Report__c=opp.Id, Billing_Code__c=profBc.Id,Professional_Hours_Nurse__c=1,Adj_Professional_Hours__c=1,Professional_Hours__c=1,Travel_Wait_Hours__c=1);
	        insert profCne;
	                
		}
		system.runAs(coveringNurse)
		{
			Case_Note_Entry__c waitCne = new Case_Note_Entry__c(Covering_Nurse__c=true,Report__c=opp.Id, Billing_Code__c=waitBc.Id,Travel_Wait_Hours_Nurse__c=1,Adj_Travel_Wait_Hours__c=1,Travel_Wait_Hours__c=1,Adj_Mileage__c=1,Mileage__c=1,Mileage_Nurse__c=1,Driving_From_City__c='SF',Driving_To_City__c='SD',Adj_Expenses__c=1,Expenses__c=1,Expenses_Nurse__c=1);
			insert waitCne;
		}
    	
    	
		
    }
	
}