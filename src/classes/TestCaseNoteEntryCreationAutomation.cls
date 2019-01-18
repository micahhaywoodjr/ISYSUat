@isTest
private class TestCaseNoteEntryCreationAutomation {
   	static List<Case_Note_Entry__c> cneList = new List<Case_Note_Entry__c>();
	static Opportunity opp;
	static testMethod void test1() 
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

    	//Create Primary Nurse and Covering Nurse Users

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
		
	//	Test.startTest();
		insert userList;
		//Test.stopTest();

		List<Billing_Code__c> bcList = new List<Billing_Code__c>();

		Billing_Code__c testcode= new Billing_Code__c(name ='test',DefaultCode__c=true,Active__c=true,Min__c=0.1,Max__c=3);
        bcList.add(testcode);
        Billing_Code__c profBc= new Billing_Code__c(name ='ECT',DefaultCode__c=true,Active__c=true,Min__c=0.5,Max__c=3);
        bcList.add(profBc);
        Billing_Code__c waitBc= new Billing_Code__c(name ='T01',DefaultCode__c=true,Active__c=true,Min__c=1,Max__c=3);
        bcList.add(waitBc);        
        insert bcList;

        //Create Org Default Custom Settings
    	CaseNoteEntryAutomation__c orgDefault = CaseNoteEntryAutomation__c.getOrgDefaults();
    	orgDefault.Active__c = true;
    	orgDefault.Billing_Code_ID__c = testcode.Id;
    	upsert orgDefault;

System.runAs(u)
{
		//Create Account and Contacts
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
	    	

	    	//Create Case
	    	Case c = new Case(Supervised_by__c = 'MySelf',Status = 'Open',QB_Service_Item__c = 'ER',Priority = 'High',
        					Origin = 'Web',Nature_and_History_of_Injury__c = 'Nothing',Employee_Case_Trakker__c = 'Nothing',
        					Current_Diagnosis__c = 'Fine',Jurisdiction__c = 'Jurisdiction__c OLD',
        					AssignmentRegion__c = areaList[2].Id);
	    	insert c;

	    	//Create Opp
	    	opp = new Opportunity(
	    					name='Test Opportunity 1.0',
	    					AccountId=a.Id,
	    					//Related_Case__c = c.Id,
	    					Amount=0.0,
	    					CloseDate=system.today(),
	    					stageName ='In Process',
	    					Service_Date_From__c=Date.today().addDays(-5),
	    					Service_Date_Thru__c=Date.today().addDays(-1), 
	    					Report_Submission_Date__c=system.today(),
	    					A_Note_Approval_Date_Time__c=system.today());
	        insert opp;

	        opp.Related_Case__c = c.Id;
	        update opp;

	        list<Task> tList = new list<Task>();
	        
	        for(Integer i = 0;i<500; i++){
	            Task t1 = new Task();
    	        t1.ActivityDate = System.today().addDays(-2);
    	        t1.WhatId = c.Id;
    	        t1.Subject = 'Email: Test';
    	        t1.Status = 'Completed';
	            
	            tList.add(t1);
	        }
	        
	        for(Integer i = 0;i<500; i++){
	            Task t1 = new Task();
    	        t1.ActivityDate = System.today();
    	        t1.WhatId = c.Id;
    	        t1.Subject = 'Email: Test';
    	        t1.Status = 'Completed';
	            
	            tList.add(t1);
	        }
	        
            Test.StartTest();
    	        insert tList;
    	    Test.StopTest();
            
            set<ID> tIDs = new set<ID>();
            for(Task t:tList){
                tIDs.add(t.Id);
            }
            
            tList = [Select ID, Case_Note_Entry__c,Error_Case_Note_Entry_Creation__c,ActivityDate from Task Where ID in: tIDs ];
            
            for(Task t:tList){
                if(t.ActivityDate == System.Today()){
                    System.assertEquals(true,t.Error_Case_Note_Entry_Creation__c);
                }else{
                    System.assertEquals(True, t.Case_Note_Entry__c); 
                }
                
            }
}
}
	static testMethod void test2() 
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

    	//Create Primary Nurse and Covering Nurse Users

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

		Billing_Code__c testcode= new Billing_Code__c(name ='test',DefaultCode__c=true,Active__c=true,Min__c=0.1,Max__c=3);
        bcList.add(testcode);
        Billing_Code__c profBc= new Billing_Code__c(name ='ECT',DefaultCode__c=true,Active__c=true,Min__c=0.5,Max__c=3);
        bcList.add(profBc);
        Billing_Code__c waitBc= new Billing_Code__c(name ='T01',DefaultCode__c=true,Active__c=true,Min__c=1,Max__c=3);
        bcList.add(waitBc);        
        insert bcList;

        //Create Org Default Custom Settings
    	CaseNoteEntryAutomation__c orgDefault = CaseNoteEntryAutomation__c.getOrgDefaults();
    	orgDefault.Active__c = true;
    	orgDefault.Billing_Code_ID__c = testcode.Id;
    	upsert orgDefault;

System.runAs(u)
{
		//Create Account and Contacts
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
	    	

	    	//Create Case
	    	Case c = new Case(Supervised_by__c = 'MySelf',Status = 'Open',QB_Service_Item__c = 'ER',Priority = 'High',
        					Origin = 'Web',Nature_and_History_of_Injury__c = 'Nothing',Employee_Case_Trakker__c = 'Nothing',
        					Current_Diagnosis__c = 'Fine',Jurisdiction__c = 'Jurisdiction__c OLD',
        					AssignmentRegion__c = areaList[2].Id);
	    	insert c;


	    	Task firstTask = new Task();
	    	firstTask.WhatId = c.Id;
	        firstTask.Subject = 'Email: Test';
	        firstTask.Status = 'Completed';
	        insert firstTask;


	    	//Create Opp
	    	opp = new Opportunity(
	    					name='Test Opportunity 1.0',
	    					AccountId=a.Id,
	    					//Related_Case__c = c.Id,
	    					Amount=0.0,
	    					CloseDate=system.today(),
	    					stageName ='In Process',
	    					Service_Date_From__c=Date.today(),
	    					Service_Date_Thru__c=Date.today().addDays(2), 
	    					Report_Submission_Date__c=system.today(),
	    					A_Note_Approval_Date_Time__c=system.today());
	        insert opp;


	        Opportunity opp2 = new Opportunity(
	    					name='Test Opportunity 1.0',
	    					AccountId=a.Id,
	    					//Related_Case__c = c.Id,
	    					Amount=0.0,
	    					CloseDate=system.today(),
	    					stageName ='In Process',
	    					Service_Date_From__c=Date.today(),
	    					Service_Date_Thru__c=Date.today().addDays(2), 
	    					Report_Submission_Date__c=system.today(),
	    					A_Note_Approval_Date_Time__c=system.today());
	        insert opp2;

	        opp2.Related_Case__c = c.Id;
	        update opp2;

	        opp.Related_Case__c = c.Id;
	        update opp;

	        Task t1 = new Task();
	        t1.WhatId = c.Id;
	        t1.Subject = 'Email: Test';
	        t1.Status = 'Completed';
	        insert t1;
}
    }
}