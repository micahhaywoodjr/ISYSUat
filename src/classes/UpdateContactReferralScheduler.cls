/**
 * Name: UpdateContactReferralScheduler
 * Author: Jonathan Broquist
 * Date: 5/20/16
 * Description: Schedulable class for UpdateContactReferralBatch class
 */
global class UpdateContactReferralScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateContactReferralsBatch batch = new UpdateContactReferralsBatch();
        // executes single batches to avoid error thrown by Boomi Quickbooks Widget
        database.executeBatch(batch, 1);
    }
}