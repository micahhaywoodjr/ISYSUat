@isTest

private class bulkNoteAddControllerTest 
{
    static testMethod void testNewCaseNote() 
    {
        //Setup mock records
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        
        insert testAccount;
        System.Assert(testAccount.Id != null, 'Unable to create test account record.');
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test - Opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.today();
        testOpp.P_S_Comment__c = 'Test';
        testOpp.Service_Date_From__c = System.today();
        testOpp.Service_Date_Thru__c = System.today();
        
        insert testOpp;
        System.Assert(testOpp.Id != null, 'Unable to create test opportunity record.');
        
        Billing_Code__c testCode = new Billing_Code__c();
        testCode.Active__c = true;
        testCode.DefaultCode__c = true;
        testCode.Name = 'Unit Test Code';
        testCode.Max__c = 1;
        testCode.Min__c = 0;
        
        insert testCode;
        System.Assert(testCode.Id != null, 'Unable to create test billing code record.');
        
        // Create and page controller
        PageReference testPage = Page.bulknoteadd;
        Test.setCurrentPage(testPage);
        
        ApexPages.currentPage().getParameters().put('id', testOpp.Id);
        
        //Perform Test
        Test.startTest();
        bulkNoteAddController controller = new bulkNoteAddController();
        
        System.Assert(controller.editMode == false, 'Expected edit mode to be false.');
        System.Assert(controller.pageIndex == 0, 'Expected initial page index to be zero');
        
        List<SelectOption> codes = controller.billingCodeOptions;
        System.Assert(!codes.isEmpty(), 'Expected billing code options to contain at least one record.');
         
        List<CaseNoteItem> data = controller.pageData;
        System.Assert(!data.isEmpty(), 'Expected page data to contain at least one record.');
        
        if (!data.isEmpty()) 
        {
            CaseNoteItem note = data[0];
            note.entry.Expenses__c = 10;
            note.entry.Mileage__c = 10;
            note.entry.Driving_From_City__c = 'Dallas';
            note.entry.Professional_Hours__c = 10;
            note.entry.Driving_To_City__c = 'NY';
            note.entry.Report__c = testOpp.Id;
            note.entry.Adj_Professional_Hours__c = 0;
            note.entry.Adj_Travel_Wait_Hours__c = 0;
            note.entry.Adj_Expenses__c = 10;
            note.entry.Adj_Mileage__c = 100;
            note.entry.Travel_Wait_Hours__c = 1;
            note.entry.Professional_Hours_Nurse__c = 1;
            note.entry.Mileage_Nurse__c = 1;
            note.entry.Travel_Wait_Hours_Nurse__c = 1;
            note.entry.Expenses_Nurse__c = 1;
            note.entry.Work_Description__c = 'Test';
            note.entry.Billing_Code__c = testCode.Id;
            note.entry.Activity_Date__c = System.today();
            
            PageReference saveRef = controller.save();
            
            controller.selectedBillingCodeId = testCode.Id;
            controller.currentCaseNoteIndex = 0;
            controller.billingCodeChanged();
            
        }
        
        PageReference cancelRef = controller.cancel();
        System.Assert(cancelRef.getUrl() == '/' + testOpp.Id, 'Expected cancel url to redirect user back to test opportunity');
        
        
        PageReference addRef = controller.addNotes();
        System.Assert(addRef.getUrl() == '/apex/bulknoteadd?id=' + testOpp.Id, 'Expected cancel url to redirect user back to add case notes');
        
        Test.stopTest();
    }
    
    static testMethod void testSaveAndNewCaseNote() 
    {
        //Setup mock records
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        
        insert testAccount;
        System.Assert(testAccount.Id != null, 'Unable to create test account record.');
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test - Opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.today();
        testOpp.P_S_Comment__c = 'Test';
        testOpp.Service_Date_From__c = System.today();
        testOpp.Service_Date_Thru__c = System.today();
                
        insert testOpp;
        System.Assert(testOpp.Id != null, 'Unable to create test opportunity record.');
        
        Billing_Code__c testCode = new Billing_Code__c();
        testCode.Active__c = true;
        testCode.DefaultCode__c = true;
        testCode.Name = 'Unit Test Code';
        testCode.Max__c = 1;
        testCode.Min__c = 0;
        
        insert testCode;
        System.Assert(testCode.Id != null, 'Unable to create test billing code record.');
        
        // Create and page controller
        PageReference testPage = Page.bulknoteadd;
        Test.setCurrentPage(testPage);
        
        ApexPages.currentPage().getParameters().put('id', testOpp.Id);
        
        //Perform Test
        Test.startTest();
        bulkNoteAddController controller = new bulkNoteAddController();
        
        System.Assert(controller.editMode == false, 'Expected edit mode to be false.');
        System.Assert(controller.pageIndex == 0, 'Expected initial page index to be zero');
        
        List<SelectOption> codes = controller.billingCodeOptions;
        System.Assert(!codes.isEmpty(), 'Expected billing code options to contain at least one record.');
         
        List<CaseNoteItem> data = controller.pageData;
        System.Assert(!data.isEmpty(), 'Expected page data to contain at least one record.');
        
        if (!data.isEmpty()) 
        {
            CaseNoteItem note = data[0];
            note.entry.Expenses__c = 10;
            note.entry.Mileage__c = 10;
            note.entry.Driving_From_City__c = 'Dallas';
            note.entry.Professional_Hours__c = 10;
            note.entry.Driving_To_City__c = 'NY';
            note.entry.Report__c = testOpp.Id;
            note.entry.Adj_Professional_Hours__c = 0;
            note.entry.Adj_Travel_Wait_Hours__c = 0;
            note.entry.Adj_Expenses__c = 10;
            note.entry.Adj_Mileage__c = 100;
            note.entry.Professional_Hours_Nurse__c = 1;
            note.entry.Mileage_Nurse__c = 1;
            note.entry.Travel_Wait_Hours_Nurse__c = 1;
            note.entry.Expenses_Nurse__c = 1;
            note.entry.Travel_Wait_Hours__c = 1;
            note.entry.Work_Description__c = 'Test';
            note.entry.Billing_Code__c = testCode.Id;
            note.entry.Activity_Date__c = System.today();
            
            PageReference saveRef = controller.saveNew();
            
            controller.selectedBillingCodeId = testCode.Id;
            controller.currentCaseNoteIndex = 0;
            controller.billingCodeChanged();
            
        }
        
        PageReference cancelRef = controller.cancel();
        System.Assert(cancelRef.getUrl() == '/' + testOpp.Id, 'Expected cancel url to redirect user back to test opportunity');
        
        Test.stopTest();
    }
    
    static testMethod void testEditAllCaseNotes() 
    {
        //Setup mock records
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        
        insert testAccount;
        System.Assert(testAccount.Id != null, 'Unable to create test account record.');
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test - Opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.today();
        testOpp.P_S_Comment__c = 'Test';
        testOpp.Service_Date_From__c = System.today();
        testOpp.Service_Date_Thru__c = System.today();
                
        insert testOpp;
        System.Assert(testOpp.Id != null, 'Unable to create test opportunity record.');
        
        Billing_Code__c testCode = new Billing_Code__c();
        testCode.Active__c = true;
        testCode.DefaultCode__c = true;
        testCode.Name = 'Unit Test Code';
        testCode.Max__c = 1;
        testCode.Min__c = 0;
        
        insert testCode;
        System.Assert(testCode.Id != null, 'Unable to create test billing code record.');
        
        List<Case_Note_Entry__c> notes = new List<Case_Note_Entry__c>();
        for (integer i=0; i < 11; i++) 
        {
            Case_Note_Entry__c note = new Case_Note_Entry__c();
            note.Expenses__c = 10;                
        	note.Professional_Hours__c = 10;
        	note.Report__c = testOpp.Id;
        	note.Adj_Professional_Hours__c = 0;        
        	note.Adj_Expenses__c = 10;        
        	note.Professional_Hours_Nurse__c = 1;                
        	note.Expenses_Nurse__c = 1;        
        	note.Activity_Date__c=Date.today();
            note.Work_Description__c = 'Test ' + i;            
            notes.add(note);
        }
        
        insert notes;
        for (Case_Note_Entry__c n : notes) 
        {
            System.Assert(n.Id != null, 'Expected all test case note entries to have a valid Salesforce record id.');
            if (n.Id == null) break;    
        }
        
        // Create and page controller 
        PageReference testPage = Page.bulknoteadd;
        Test.setCurrentPage(testPage);
        
        ApexPages.currentPage().getParameters().put('id', testOpp.Id);
        ApexPages.currentPage().getParameters().put('edit', '1');
        
        //Perform Test
        Test.startTest();
        bulkNoteAddController controller = new bulkNoteAddController();
        
        System.Assert(controller.editMode == true, 'Expected edit mode to be true.');
        System.Assert(controller.pageIndex == 0, 'Expected initial page index to be zero');
        System.Assert(controller.showPageNavigation == true, 'Expected show page navigation to be true');
        System.Assert(controller.allowMovePrev == false, 'Expected allow move prev to be false');
        System.Assert(controller.allowMoveNext == true, 'Expected allow move next to be true');
        
        controller.moveNext();
        System.Assert(controller.pageIndex == 1, 'Expected page index to be one');
        System.Assert(controller.allowMovePrev == true, 'Expected allow move prev to be true');
        System.Assert(controller.allowMoveNext == false, 'Expected allow move next to be false');
        
        List<CaseNoteItem> pdata = controller.pageData;
        System.Assert(!pdata.isEmpty(), 'Expected page data to contain at least one record.');
        
        controller.movePrev();
        System.Assert(controller.pageIndex == 0, 'Expected initial page index to be zero');
        System.Assert(controller.allowMovePrev == false, 'Expected allow move prev to be false');
        System.Assert(controller.allowMoveNext == true, 'Expected allow move next to be true');
        
        List<CaseNoteItem> data = controller.caseNotes;
        System.Assert(!data.isEmpty(), 'Expected data to contain at least one record.');
        
        for(CaseNoteItem n : data) 
            n.entry.Work_Description__c = 'Updated';
        
        controller.save();
        
        List<Case_Note_Entry__c> results = [SELECT Id, Work_Description__c FROM Case_Note_Entry__c WHERE Report__c =: testOpp.Id];
        System.Assert(!notes.isEmpty(), 'Expected at least one note entry record to exist against test opportunity');
        
        Test.stopTest();        
    }
    
    static testMethod void testAuditAllCaseNotes() 
    {
        //Setup mock records
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        
        insert testAccount;
        System.Assert(testAccount.Id != null, 'Unable to create test account record.');
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test - Opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.today();
        testOpp.P_S_Comment__c = 'Test';
        testOpp.Service_Date_From__c = System.today();
        testOpp.Service_Date_Thru__c = System.today();
            
        insert testOpp;
        System.Assert(testOpp.Id != null, 'Unable to create test opportunity record.');
        
        Billing_Code__c testCode = new Billing_Code__c();
        testCode.Active__c = true;
        testCode.DefaultCode__c = true;
        testCode.Name = 'Unit Test Code';
        testCode.Max__c = 1;
        testCode.Min__c = 0;
        
        insert testCode;
        System.Assert(testCode.Id != null, 'Unable to create test billing code record.');
        
        List<Case_Note_Entry__c> notes = new List<Case_Note_Entry__c>();
        for (integer i=0; i < 11; i++) 
        {
            Case_Note_Entry__c note = new Case_Note_Entry__c();
            note.Expenses__c = 10;                
        	note.Professional_Hours__c = 10;
        	note.Report__c = testOpp.Id;
        	note.Adj_Professional_Hours__c = 0;        
        	note.Adj_Expenses__c = 10;        
        	note.Professional_Hours_Nurse__c = 1;                
        	note.Expenses_Nurse__c = 1;        
        	note.Activity_Date__c=Date.today();
            note.Work_Description__c = 'Test ' + i; 
            
            notes.add(note);
        }
        
        insert notes;
        for (Case_Note_Entry__c n : notes) 
        {
            System.Assert(n.Id != null, 'Expected all test case note entries to have a valid Salesforce record id.');
            if (n.Id == null) break;    
        }
        
        // Create and page controller 
        PageReference testPage = Page.bulknoteadd;
        Test.setCurrentPage(testPage);
        
        ApexPages.currentPage().getParameters().put('id', testOpp.Id);
        ApexPages.currentPage().getParameters().put('audit', '1');
        ApexPages.currentPage().getParameters().put('edit', '1');
        
        //Perform Test
        Test.startTest();
        bulkNoteAddController controller = new bulkNoteAddController();
        
        System.Assert(controller.auditMode == true, 'Expected edit mode to be true.');
        System.Assert(controller.pageIndex == 0, 'Expected initial page index to be zero');
        System.Assert(controller.showPageNavigation == true, 'Expected show page navigation to be true');
        System.Assert(controller.allowMovePrev == false, 'Expected allow move prev to be false');
        System.Assert(controller.allowMoveNext == true, 'Expected allow move next to be true');
        
        controller.moveNext();
        System.Assert(controller.pageIndex == 1, 'Expected page index to be one');
        System.Assert(controller.allowMovePrev == true, 'Expected allow move prev to be true');
        System.Assert(controller.allowMoveNext == false, 'Expected allow move next to be false');
        
        List<CaseNoteItem> pdata = controller.pageData;
        System.Assert(!pdata.isEmpty(), 'Expected page data to contain at least one record.');
        
        controller.movePrev();
        System.Assert(controller.pageIndex == 0, 'Expected initial page index to be zero');
        System.Assert(controller.allowMovePrev == false, 'Expected allow move prev to be false');
        System.Assert(controller.allowMoveNext == true, 'Expected allow move next to be true');
        
        List<CaseNoteItem> data = controller.caseNotes;
        System.Assert(!data.isEmpty(), 'Expected data to contain at least one record.');
        
        for(CaseNoteItem n : data) 
        {
            n.entry.Work_Description__c = 'Updated';
            n.entry.Adj_Travel_Wait_Hours__c = 0.2;
            n.entry.Adj_Professional_Hours__c = 0.2;
        }
        controller.save();
        
        List<Case_Note_Entry__c> results = [SELECT Id, Work_Description__c, Adj_Travel_Wait_Hours__c, Adj_Professional_Hours__c FROM Case_Note_Entry__c WHERE Report__c =: testOpp.Id];
        System.Assert(!notes.isEmpty(), 'Expected at least one note entry record to exist against test opportunity');
        
        Test.stopTest();        
    }
}