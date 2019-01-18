/*

Class Name    : NewAcctBillingCodeBatch
Modified by   : Levementum LLC - James Amos
Modified On   : 04-04-2017
Description   : NewAcctBillingCodeBatch - when a billing code is create - clone it and add a new to all accounts
*/

 global class NewAcctBillingCodeBatch implements  Database.Batchable<sObject>,Database.stateful{
     List<err_CNE_Log> errLogs;

     Integer updateTotalFailedCount = 0;
     Integer updateTotalSuccessCount = 0;

     List<Billing_Code__c> bcList;

     global NewAcctBillingCodeBatch(List<Billing_Code__c> newBcList){
         bcList = newBcList;
     }
     global Database.QueryLocator start(Database.BatchableContext BC) {
         System.debug('** Start **');
         errLogs = new List<err_CNE_Log>();


         String query;
         query = 'SELECT Id FROM Account where UseCustomBillingCode__c=true';

         return Database.getQueryLocator(query);
     }

     global void execute(Database.BatchableContext BC, List<Account> scope) {
         System.debug('** Execute **');


         List<Billing_Code__c> insertList = new List<Billing_Code__c>();
         Billing_Code__c clone;

         for(Billing_Code__c nbc : bcList)
         {
             for(Account a : scope)
             {
                 clone = nbc.clone(false);
                 clone.Account__c = a.Id;
                 clone.DefaultCode__c = false;
                 clone.DefaultBillingCode__c = nbc.Id;
                 insertList.add(clone);
             }
         }

         if(insertList.size()>0)
             insert insertList;

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
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             String[] toAddresses = Environment_Settings__c.getInstance('Environment').ResultsNotificationEmail__c.split(';');

             mail.setToAddresses(toAddresses);
             mail.setSenderDisplayName('Salesforce Support');
             mail.setSubject('Integration error on batch process');

             email_body = 'Batch ' + a.Id + ' the following number of errors ' + a.NumberOfErrors;
             for (err_CNE_Log aLog :errLogs) {
                 email_body += String.valueOf( aLog.cneId) +  ' ' + aLog.messsage +  '<br>';
                 system.debug(aLog.messsage);
             }
             mail.setHtmlBody(email_body);
             // Send the email you have created.
             Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                     mail
             });
         }
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