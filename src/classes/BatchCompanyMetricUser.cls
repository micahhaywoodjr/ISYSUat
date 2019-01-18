global class BatchCompanyMetricUser implements Database.Batchable<sObject>, Database.Stateful
{
    private Date runDate = Date.today();    
    private integer daysInMonth = Date.daysInMonth(runDate.year(),runDate.month()); 
    private Date metricDate = Date.parse(String.valueOf(runDate.month())+'/'+daysInMonth+'/'+runDate.year());
    public String runDateMonthYear = String.valueOf(runDate.month()+'/'+runDate.year());
    private CompanyMetric__c cm = new CompanyMetric__c(ExternalId__c=runDateMonthYear,MonthEnding__c=metricDate,AdminStaff__c=0,QAStaff__c=0,CaseManagers__c=0);    
    global Database.Querylocator start(Database.Batchablecontext BC)
    {       
        return Database.getQueryLocator([Select Id,Profile.Name FROM User WHERE IsActive=true AND Profile.Name in ('Custom - Nurse','Custom - Admin Staff','Custom - QA Staff')]);
    }
    global void execute(Database.Batchablecontext BC, list<User> scope)
    {       
    	try{
        for(User u : scope)
        {
            if(u.Profile.Name=='Custom - Nurse')
                cm.CaseManagers__c+=1;          
            else if(u.Profile.Name=='Custom - Admin Staff')
                cm.AdminStaff__c+=1;
            else if(u.Profile.Name=='Custom - QA Staff')
                cm.QAStaff__c+=1;
        }
    	}
    	catch(Exception e){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'support@isyscm.com'};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Error Processing BatchCompanyMetricUser');
			mail.setPlainTextBody
			('The BatchCompanyMetricUser job failed. Some records may have been processed:' + '\n' + 'Message: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString() + '');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
    }
    global void finish (Database.Batchablecontext BC)
    {
        upsert cm ExternalId__c;
        if(!Test.isRunningTest())
    		Database.executeBatch(new BatchCompanyMetricOpportunity());
    }
}