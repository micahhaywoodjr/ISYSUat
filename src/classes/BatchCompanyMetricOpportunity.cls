global class BatchCompanyMetricOpportunity implements Database.Batchable<sObject>, Database.Stateful
{
	private Date runDate = Date.today();    
    private integer daysInMonth = Date.daysInMonth(runDate.year(),runDate.month()); 
    private Date metricDate = Date.parse(String.valueOf(runDate.month())+'/'+daysInMonth+'/'+runDate.year());
    public String runDateMonthYear = String.valueOf(runDate.month()+'/'+runDate.year());
    private CompanyMetric__c cm = new CompanyMetric__c(ExternalId__c=runDateMonthYear,MonthEnding__c=metricDate,ReportsApproved__c=0,ReportsCompleted__c=0,ReportsInProcess__c=0,ReportsSubmitted__c=0);
	private integer currentMonth = runDate.month();
	private integer currentYear = runDate.year();
	
	global Database.Querylocator start(Database.Batchablecontext BC)
    {       
        return Database.getQueryLocator([Select Id,StageName,ActualCompletedDate__c FROM Opportunity WHERE StageName in ('In Process','Submitted','Approved','Completed')]);
    }
    global void execute(Database.Batchablecontext BC, list<Opportunity> scope)
    {
    	try{
    	for(Opportunity opp : scope)
    	{
    		if(opp.StageName=='In Process')
    			cm.ReportsInProcess__c+=1;
    		else if(opp.StageName=='Submitted')
    			cm.ReportsSubmitted__c+=1;
    		else if(opp.StageName=='Approved')
    			cm.ReportsApproved__c+=1;
    		else if(opp.StageName=='Completed' && opp.ActualCompletedDate__c!=null && ((opp.ActualCompletedDate__c.month()==currentMonth && opp.ActualCompletedDate__c.year()==currentYear) ))
    			cm.ReportsCompleted__c+=1;
    	}
    	}
    	catch(Exception e){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'Diane.Campos@isyscm.com '};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Error Processing BatchCompanyMetricOpportunity');
			mail.setPlainTextBody
			('The BatchCompanyMetricOpportunity job failed. Some records may have been processed:' + '\n' + 'Message: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString() + '');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
    }
    global void finish (Database.Batchablecontext BC)
    {
         upsert cm ExternalId__c;
        if(!Test.isRunningTest())
    		Database.executeBatch(new BatchCompanyMetricCase());
    }
}