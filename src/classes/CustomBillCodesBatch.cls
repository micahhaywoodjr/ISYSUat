/*
Class Name    : CustomBillCodesBatch
Created by    : James Amos @ Levementum
Created On    : 04-03-2017
Description   : Query all of the Accounts with opties with caseEntry notes where defaultbillingcode = false
                    update the cne's and if success mark account.usebilling codes = true

 */

global class CustomBillCodesBatch implements Database.Batchable<sObject>,Database.stateful {
    List<err_CNE_Log> errLogs;
    List<err_CNE_Log> errFinishLogs;
    Integer updateTotalFailedCount = 0;
    Integer updateTotalSuccessCount = 0;
    Id AcctId;
    List<Id> AccountId;
    global CustomBillCodesBatch(){}
    global CustomBillCodesBatch(String AccntId){
        AcctId = AccntId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('** Start **');
        errLogs = new List<err_CNE_Log>();
        errFinishLogs = new List<err_CNE_Log>();
        String query;
        If(AcctId == null) {
            query = 'Select Id,Name,AccountId,CustomBillCodeProcessed__c  from Opportunity where  ' +
                    'account.UseCustomBillingCode__c = false and accountId <> null and CustomBillCodeProcessed__c = false and Total_Case_Note_Entries__c > 0  ';
        }else{
            query =  'Select Id,Name,AccountId,CustomBillCodeProcessed__c from Opportunity where AccountId = \''
                    + AcctId + '\' ';
        }
        system.debug('soql ' + query);
        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        System.debug('** Execute **');

        List<Opportunity> opps = new List<Opportunity>();


        for (Opportunity opp:scope) {
            Integer updateFailedCount = 0;
            Integer updateSuccessCount = 0;
            system.debug('** oppId ** ' + opp.Id + ' ' + opp.accountId);
            Map<Id, Id> acctBillingCodesMap = new Map<Id, Id>();
            List<Case_Note_Entry__c> updteCNEs = new List<Case_Note_Entry__c>();


           List<Billing_Code__c> acctBillingCodes = [Select Id, DefaultBillingCode__c From Billing_Code__c WHERE DefaultCode__c = false AND Account__c = :opp.AccountId AND Active__c=true  ]; //
            for (Billing_Code__c acctbc:acctBillingCodes) {
                acctBillingCodesMap.put(acctbc.DefaultBillingCode__c, acctbc.Id);
               //system.debug(acctbc.DefaultBillingCode__c + ' ' + acctbc.Id);
            }

            System.debug('** acctBillingCodesMap **' + acctBillingCodesMap.size());
            List<Case_Note_Entry__c> cnes = [SELECT Id, Billing_Code__c, Billing_Code__r.Name, Report__c FROM Case_Note_Entry__c where Report__c = :opp.Id]; //and  Billing_Code__c in : acctBillingCodesSet
            for (Case_Note_Entry__c cne:cnes) {
                Id newBc = acctBillingCodesMap.get(cne.Billing_Code__c);

                if (newBc != null) {
                    system.debug('** newBc ** ' + newBc  + ' ' + cne.Id);
                    cne.PrevBillingCode__c = cne.Billing_Code__c;
                    cne.Billing_Code__c = newBc;
                    updteCNEs.add(cne);

                }

            }

            system.debug('updteCNEs ' + updteCNEs.size());

            Database.SaveResult[] srList = Database.update(updteCNEs, false);
            //for (Database.SaveResult sr : srList) {
            for(Integer i=0;i<srList.size();i++){
                if (srList.get(i).isSuccess()) {
                    updateSuccessCount++;
                    updateTotalSuccessCount++;
                } else {
                    updateFailedCount++;

                    updateTotalFailedCount++;
                    for (Database.Error err : srList.get(i).getErrors()) {
                        err_CNE_Log errCNE = new err_CNE_Log(err.getMessage(), String.Valueof(err.getFields()), 'CaseEntryNotes updateCaseEntryNotes in CustomBillingCode ' +  opp.AccountId, updteCNEs.get(i).Id, '');
                        errLogs.add(errCNE);
                    }
                }
            }
            if ( (cnes.size() > 0 && updteCNEs.size() == 0) || (cnes.size() > 0 && updteCNEs.size() > 0 && updateFailedCount == 0)) {
                opp.CustomBillCodeProcessed__c = true;
                opps.add(opp);
            }

        }
       if (opps.size() > 0) {
            Database.SaveResult[] srList2 = Database.update(opps, false);
            for (Database.SaveResult sr : srList2) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        err_CNE_Log errCNE = new err_CNE_Log('updating opps ' + err.getMessage(), String.Valueof(err.getFields()), 'oppties on updateCaseEntryNotes in CustomBillingCode ', sr.getId(), '');
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
            email_body = ' updateSuccessCount ' + updateTotalSuccessCount + ' updateFailedCount' + updateTotalFailedCount  +
                    '<br> Batch ' + a.Id + ' the following number of errors ' + a.NumberOfErrors +  '<br>';
            for (err_CNE_Log aLog :errLogs) {
                email_body += String.valueOf( aLog.cneId) +  ' ' + aLog.src + ' ' + aLog.messsage +  '<br>' + aLog.flds;
                system.debug(aLog.messsage);
            }
            sendMail('Integration error on batch process',email_body);
        }
        if((errLogs.size() == 0 && a.NumberOfErrors == 0) || Test.IsRunningTest())  //if success go update all of the accounts = usecutsombillingcodes = true
        {
           If(AcctId == null){

                system.debug('**Updating Accounts**');
                List<Billing_Code__c> defaultBillingCodes =[SELECT Id FROM Billing_Code__c WHERE Active__c=true AND DefaultCode__c=true ORDER BY Name];
                List<Id> defaultBillingCodesIds = new List<Id> ();
                for(Billing_Code__c dbc: defaultBillingCodes){
                    defaultBillingCodesIds.add(dbc.Id);
                }
                Integer cseCount = [select count() from Case_Note_Entry__c where Billing_Code__c in :defaultBillingCodesIds and  report__r.Account.UseCustomBillingCode__c = false];
                system.debug('**CaseNoteEntries Count that still need to be prcessed** ' + cseCount);
                //if(cseCount == 0 || Test.IsRunningTest()){
                if(cseCount == 0 ){
                    try {
                        String acctSQL = 'Select Id, Name From Account ' +
                                'where Id in (Select AccountId From Opportunity where Total_Case_Note_Entries__c > 0 ) and UseCustomBillingCode__c = false limit 49999';
                        List<List<Account>> acctIdsList = new List<List<Account>> ();
                        List<Account> accts = new List<Account>();
                        List<Account> retrievedAccts = Database.query(acctSQL);
                        system.debug('*AccountSIze ' + retrievedAccts.size());
                        for(Integer i = 0;i<retrievedAccts.size();i++){
                            if(math.mod(i,2500) == 0 && i <> 0){
                                acctIdsList.add(accts);
                                accts = new List<Account>();
                            }else if(i == 2499){
                                acctIdsList.add(accts);
                            }
                            else{
                                accts.add(retrievedAccts[i]);
                            }
                        }
                        if(retrievedAccts.size() < 2499){
                            acctIdsList.add(accts);
                        }
                        for(List<Account> subAccounts: acctIdsList) {
                            for (Account acct:subAccounts) {
                                acct.UseCustomBillingCode__c = true;
                            }
                            Database.SaveResult[] srList = Database.update( subAccounts, false);
                           //for (Database.SaveResult sr : srList) {
                            for(Integer i=0;i<srList.size();i++){
                                if (!srList.get(i).isSuccess()) {
                                   for (Database.Error err : srList.get(i).getErrors()) {
                                        err_CNE_Log errCNE = new err_CNE_Log(err.getMessage(), String.Valueof(err.getFields()) , 'Finish Updating Accounts in CustomBillingCodesBatch' ,subAccounts.get(i).Id,  '');
                                        errFinishLogs.add(errCNE);
                                    }
                                }
                            }
                        }




                    }
                    catch (Exception e){
                        string email_body = '';
                        email_body = 'Batch ' + a.Id + ' the following number of errors ' + a.NumberOfErrors +  '<br>';
                        for (err_CNE_Log aLog :errFinishLogs) {
                            email_body += String.valueOf( aLog.cneId) +  ' ' + aLog.src + ' ' + aLog.messsage +  '<br>' + aLog.flds;
                            system.debug(aLog.messsage);
                        }
                        sendMail('Integration error on batch process',email_body);
                    }
                    if(errFinishLogs.size()> 0){
                        string email_body = '';
                        email_body = 'Batch ' + a.Id + ' the following number of errors ' + a.NumberOfErrors +  '<br>';
                        for (err_CNE_Log aLog :errFinishLogs) {
                            email_body += String.valueOf( aLog.cneId) +  ' ' + aLog.src + ' ' + aLog.messsage +  '<br>' + aLog.flds;
                            system.debug(aLog.messsage);
                        }
                        sendMail('Integration error on batch process',email_body);
                    }else{ sendMail('Success on batch process','Updated CaseEnryNotes and Accounts succesful');}

                }
               else{
                   sendMail('Integration error on batch process',String.valueof(cseCount) + 'CaseNoteEntries Count that still need to be prcessed');
               }
            }
        }
    }
    public void sendMail(String subject,String emailBody){
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