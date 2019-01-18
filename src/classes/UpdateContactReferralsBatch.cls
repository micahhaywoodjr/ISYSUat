/**
 * Name: UpdateContactReferralsBatch
 * Author: Jonathan Broquist
 * Date: 5/20/16
 * Description: Batch class to update referral fields on the Contact object
 */
global class UpdateContactReferralsBatch implements Database.Batchable<sObject> {
    //================================================================================
    // Properties
    //================================================================================
    @TestVisible private Map<Id, AggregateResult> lifetimeResultMap;
    @TestVisible private Map<Id, AggregateResult> sixMonthResultMap;
    @TestVisible private Map<Id, AggregateResult> thisMonthResultMap;

    private String query;
    private Set<Id> contactIds;

    //================================================================================
    // Constructor
    //================================================================================
    global UpdateContactReferralsBatch() {
        // generate record type ids to exclude from custom setting
        String[] recordTypeIds = new String[]{};
        for(UpdateContactReferralRecordType__c recordType : UpdateContactReferralRecordType__c.getAll().values()) {
            recordTypeIds.add(recordType.RecordTypeId__c);
        }

        // create list of case status values to filter
        String[] statusList = new String[]{'Open', 'Closed', 'Re-Opened'};

        // query case aggregations
        lifetimeResultMap = new Map<Id, AggregateResult>([
                SELECT COUNT(ID) totalCases, OriginallyReferredBy__c Id
                FROM Case
                WHERE Status IN : statusList
                AND OriginallyReferredBy__c != NULL
                AND RecordTypeId NOT IN :recordTypeIds
                GROUP BY OriginallyReferredBy__c
        ]);

        sixMonthResultMap = new Map<Id, AggregateResult>([
                SELECT COUNT(ID) totalCases, OriginallyReferredBy__c Id
                FROM Case
                WHERE Status IN : statusList
                AND OriginallyReferredBy__c != NULL
                AND RecordTypeId NOT IN :recordTypeIds
                AND CaseOpenedDate__c = LAST_N_MONTHS:6
                GROUP BY OriginallyReferredBy__c
        ]);

        thisMonthResultMap = new Map<Id, AggregateResult>([
                SELECT COUNT(ID) totalCases, OriginallyReferredBy__c Id
                FROM Case
                WHERE Status IN : statusList
                AND OriginallyReferredBy__c != NULL
                AND RecordTypeId NOT IN :recordTypeIds
                AND CaseOpenedDate__c = THIS_MONTH
                GROUP BY OriginallyReferredBy__c
        ]);

        // set the contactids to query for batch update
        contactIds = lifetimeResultMap.keySet();

        // generate query string for updating contacts
        this.query = 'SELECT Id, ReferralsLifetime__c, ReferralsSixMonths__c, ReferralsMonth__c FROM Contact WHERE Id IN :contactIds';
    }

    //================================================================================
    // Methods
    //================================================================================
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        // instantiate list of contacts to update
        Contact[] updatedContacts = new Contact[]{};

        // iterate through contact objects and set referral fields
        for(SObject obj : scope) {
            Contact c = (Contact)obj;

            // set lifetime results
            if(lifetimeResultMap.containsKey(c.Id)) {
                c.ReferralsLifetime__c = (Decimal)lifetimeResultMap.get(c.Id).get('totalCases');
            }

            // set six month results
            if(sixMonthResultMap.containsKey(c.Id)) {
                c.ReferralsSixMonths__c = (Decimal)sixMonthResultMap.get(c.Id).get('totalCases');
            }

            // set this month results
            if(thisMonthResultMap.containsKey(c.Id)) {
                c.ReferralsMonth__c = (Decimal)thisMonthResultMap.get(c.Id).get('totalCases');
            }

            updatedContacts.add(c);
        }

        update updatedContacts;
    }

    global void finish(Database.BatchableContext BC) { }

}