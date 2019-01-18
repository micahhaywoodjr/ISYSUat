/**
 * Name: UpdateContactReferralsBatchTest
 * Author: Jonathan Broquist
 * Date: 5/20/16
 * Description: Test class for UpdateContactReferralsBatch
 */

@IsTest
private class UpdateContactReferralsBatchTest {

    @isTest static void mainTest() {
        // instantiate batch class
        UpdateContactReferralsBatch batch = new UpdateContactReferralsBatch();

        // verify batch class aggregations
        system.assertEquals(10, batch.lifetimeResultMap.size());
        system.assertEquals(10, batch.sixMonthResultMap.size());
        system.assertEquals(10, batch.thisMonthResultMap.size());

        // verify lifetime total cases equals 10 for all contacts
        for(AggregateResult result : batch.lifetimeResultMap.values()) {
            system.assertEquals(10, result.get('totalCases'));
        }

        // verify 6 months total cases equals 3 for all contacts
        for(AggregateResult result : batch.sixMonthResultMap.values()) {
            system.assertEquals(3, result.get('totalCases'));
        }

        // verify this month total cases equals 2 for all contacts
        for(AggregateResult result : batch.thisMonthResultMap.values()) {
            system.assertEquals(2, result.get('totalCases'));
        }

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // retrieve contact records updated by batch class
        Contact[] updatedContacts = [SELECT Id, ReferralsLifetime__c, ReferralsMonth__c, ReferralsSixMonths__c FROM Contact WHERE ReferralsLifetime__c!=null];
        system.assertEquals(10, updatedContacts.size());

        // verify contact record referral fields were successfully updated
        for(Contact c : updatedContacts) {
            system.assertEquals(10, c.ReferralsLifetime__c);
            system.assertEquals(3, c.ReferralsSixMonths__c);
            system.assertEquals(2, c.ReferralsMonth__c);
        }
    }

    /**
     * Use test setup methods (methods that are annotated with @testSetup) to create test records once and then access them 
     * in any test method in the test class. Test setup methods are useful and can be time-saving when you need to create a 
     * common set of records that all test methods operate on or prerequisite data.
     * Records created in a test setup method are rolled back at the end of test class execution. Test setup methods enable 
     * you to create common test data easily and efficiently. By setting up records once for the class, you don’t need to 
     * re-create records for each test method.
     * 
     * Also, because the rollback of records that are created during test setup happens at the end of the execution of the 
     * entire class, the number of records that are rolled back is reduced. As a result, system resources are used more 
     * efficiently compared to creating those records and having them rolled back for each test method. Therefore, test 
     * setup methods can reduce test execution times especially when you’re working with many records.
     * If a test class contains a test setup method, the testing framework executes the test setup method first, before any 
     * test method in the class. Records that are created in a test setup method are available to all test methods in the 
     * test class and are rolled back at the end of test class execution. If a test method changes those records, such as 
     * record field updates or record deletions, those changes are rolled back after each test method finishes execution. 
     * The next executing test method gets access to the original unmodified state of those records.
     * 
     * If you create additional test records inside a test method, those records are rolled back at the end of the test 
     * method’s execution, which also happens when you’re not using test setup methods.
     */
    @testSetup static void setupData() {
        // create custom settings for records type ids to exclude
        UpdateContactReferralRecordType__c customerCaseSetting = new UpdateContactReferralRecordType__c();
        customerCaseSetting.Name = 'Cases-Customers';
        customerCaseSetting.RecordTypeId__c = [SELECT Id FROM RecordType WHERE Name=:customerCaseSetting.Name AND SobjectType='Case' LIMIT 1].Id;
        insert customerCaseSetting;

        // create contact parent account
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        // create contacts
        Contact[] contacts = new Contact[]{};
        for(Integer i=0; i<10; i++) {
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'John';
            c.LastName = 'Doe ' + i;
            contacts.add(c);
        }
        insert contacts;

        // create cases related to contacts
        Integer currentContactIndex = 0;
        Integer currentIndex = 0;

        Case[] cases = new Case[]{};
        for(Integer i=0; i<100; i++) {
            currentIndex++;

            Case c = new Case();
            c.Status = 'Open';
            c.Origin = 'Test';
            c.OriginallyReferredBy__c = contacts.get(currentContactIndex).Id;
            c.Employee_Case_Trakker__c = 'test stuff here';
            cases.add(c);

            if(currentIndex == 10) {
                currentIndex = 0;
                currentContactIndex++;
            }
        }
        insert cases;

        // update case opened date fields to overwrite values from Workflow
        currentContactIndex = 0;
        currentIndex = 0;

        for(Case c : cases) {
            currentIndex++;

            c.CaseOpenedDate__c = system.today().addMonths(-12);

            if(currentIndex >= 6 && currentIndex <= 8) {
                // add to 6 month window
                c.CaseOpenedDate__c = system.today().addMonths(-1);
            } else if(currentIndex > 8) {
                // add to this month window
                c.CaseOpenedDate__c = system.today();
            }

            if(currentIndex == 10) {
                currentIndex = 0;
                currentContactIndex++;
            }
        }
        update cases;
    }
}