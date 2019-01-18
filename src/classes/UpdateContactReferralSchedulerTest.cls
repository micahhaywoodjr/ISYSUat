/**
 * Name: UpdateContactReferralSchedulerTest
 * Author: Jonathan Broquist
 * Date: 5/20/16
 * Description: Test class for UpdateContactReferralScheduler
 */

@IsTest
private class UpdateContactReferralSchedulerTest {

    // CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    
    @isTest static void test() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('UpdateContactReferralScheduler', CRON_EXP, new UpdateContactReferralScheduler());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }

}