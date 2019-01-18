/*
Class Name    : CustomBillingCodeAcct
Created by    : James Amos @ Levementum
Created On    : 04-03-2017
Description   : Query all of the Accounts with opties with caseEntry notes where defaultbillingcode = false
                    and create new custom billing codes from default
 */


global class CustomBillingCodeAcct  implements Database.Batchable<sObject>,Database.stateful{
    List<err_CNE_Log> errLogs;

    Integer updateTotalFailedCount = 0;
    Integer updateTotalSuccessCount = 0;
    Integer TotalAccounts = 0;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('** Start **');
        errLogs = new List<err_CNE_Log>();
        String query;
        //One to process all accounts with Opps that have case note entries but do not have custom billing codes
        ///Select a.Id, (Select Total_Case_Note_Entries__c From Opportunities) From Account a where a.Id in (Select AccountId From Opportunity where Total_Case_Note_Entries__c > 0 ) and a.UseCustomBillingCode__c = false

        query = 'Select Id, Name From Account ' +
                'where Id in (Select AccountId From Opportunity where Total_Case_Note_Entries__c > 0 ) and UseCustomBillingCode__c = false ';

        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('** Execute **');
        Integer AccountSize = scope.size();
        system.debug('*AccountSIze ' + AccountSize);
        Integer TotalAccounts = TotalAccounts + AccountSize;
        List<Billing_Code__c> bcList = [SELECT Id, Name, AdminMax__c, AdminMin__c, Min__c, Max__c FROM Billing_Code__c WHERE Active__c=true AND DefaultCode__c=true ORDER BY Name];
        system.debug('bcList ' + bcList.size());
        //chunk the account list so that bulkify so if we batch have the size 200 * 312 default billing codes, we will not run into governor dml limits
        List<List<Account>> acctIdsList = new List<List<Account>> ();
        List<Account> accts = new List<Account>();

        for(Integer i = 0;i<AccountSize;i++){
            if(math.mod(i,21) == 0 && i <> 0){
                acctIdsList.add(accts);
                system.debug('*subaccountListSize' + accts.size());
                accts = new List<Account>();

            }else if(i == 20){
                system.debug('*added first one' + accts.size());
                acctIdsList.add(accts);
            }
            else{
                system.debug('Account ' + scope[i].Id);
                accts.add(scope[i]);
            }
        }
        if(AccountSize < 20){
            system.debug('*added first one' + accts.size());
            acctIdsList.add(accts);
        }
        Billing_Code__c clone;

        List<Billing_Code__c> bcUpdateAccountList = new List<Billing_Code__c>();
        for(List<Account> subAccounts: acctIdsList) {
            for (Account acct:subAccounts) {
                system.debug('*Account ' + acct.id);
                for (Billing_Code__c dbc : bcList) {
                    clone = dbc.clone(false);
                    clone.Account__c = acct.Id;
                    clone.DefaultCode__c = false;
                    clone.DefaultBillingCode__c = dbc.Id;
                    bcUpdateAccountList.add(clone);
                }
            }
            Database.SaveResult[] srList = Database.insert( bcUpdateAccountList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    updateTotalSuccessCount++;
                } else {

                    updateTotalFailedCount++;
                    for (Database.Error err : sr.getErrors()) {
                        err_CNE_Log errCNE = new err_CNE_Log(err.getMessage(), String.Valueof(err.getFields()) + String.valueOf(bcUpdateAccountList), 'Execute in CustomBillingCodeAcct Batch' ,null,  '');
                        errLogs.add(errCNE);
                    }
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('** Finish **');
        System.debug('** updateSuccessCount **' + updateTotalSuccessCount + ' updateFailedCount' + updateTotalFailedCount);
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        if ( Test.IsRunningTest()){
            err_CNE_Log errCNE = new err_CNE_Log('test' ,'errfields', 'updateCaseEntryNotes in CustomBillingCode', null, '');
            errLogs.add(errCNE);
        }
        if (errLogs.size() > 0 || a.NumberOfErrors > 0) {
            string email_body = '';


            email_body = ' insertSuccessCount ' + updateTotalSuccessCount + ' insertFailedCount' + updateTotalFailedCount  +
                    '<br> Batch ' + a.Id + ' the following number of errors ' + a.NumberOfErrors +  '<br>';
            for (err_CNE_Log aLog :errLogs) {
                email_body += String.valueOf( aLog.cneId) +  ' ' + aLog.src + ' ' + aLog.messsage +  '<br>' + aLog.flds;
                system.debug(aLog.messsage);
            }
            SendmailHander(email_Body,'Integration error on batch process');
        }else{

            //send success
            String email_body = ' Succesfully inserted ' + updateTotalSuccessCount + ' Billing Codes on ' + TotalAccounts + 'Accounts for batch ' +   a.Id ;
            SendmailHander(email_Body,'Integration Success on batch process');
        }
    }
    private void SendmailHander(string emailBody,string subject){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = Environment_Settings__c.getInstance('Environment').ResultsNotificationEmail__c.split(';');

        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject(subject);
        mail.setHtmlBody(emailBody);
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
    public class err_CNE_Log {
        public String messsage;
        public String flds;
        public String src;
        public Id cneId;
        public String cneName;
        public err_CNE_Log(String msg, String fldss, String srce, Id cne_Id, String cne_Name) {
            messsage = msg;
            flds = fldss;
            src = srce;
            cneId = cne_Id;
            cneName = cne_Name;
        }
    }
}