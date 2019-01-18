global class BatchCompanyMetricCase implements Database.Batchable<sObject>, Database.Stateful
{
	private Date runDate = Date.today();    
    private integer daysInMonth = Date.daysInMonth(runDate.year(),runDate.month()); 
    private Date metricDate = Date.parse(String.valueOf(runDate.month())+'/'+daysInMonth+'/'+runDate.year());
    public String runDateMonthYear = String.valueOf(runDate.month()+'/'+runDate.year());
    private CompanyMetric__c cm = new CompanyMetric__c(ExternalId__c=runDateMonthYear,MonthEnding__c=metricDate,CasesOpen__c=0,CasesReOpened__c=0,CasesClosed__c=0);
	private integer currentMonth = runDate.month();
	private integer currentYear = runDate.year();
	
	global Database.Querylocator start(Database.Batchablecontext BC)
    {       
        return Database.getQueryLocator([Select Id,Status,ClosedDate FROM Case WHERE Status in ('Open','Re-Opened','Closed')]);
    }
    global void execute(Database.Batchablecontext BC, list<Case> scope)
    {
    	for(Case c : scope)
    	{
    		if(c.Status=='Open')
    			cm.CasesOpen__c+=1;
    		else if(c.Status=='Re-Opened')
    			cm.CasesReOpened__c+=1;
    		else if(c.Status=='Closed' && (c.ClosedDate.month()==currentMonth && c.ClosedDate.year()==currentYear))
    			cm.CasesClosed__c+=1;
    	}
    }
    global void finish (Database.Batchablecontext BC)
    {
        upsert cm ExternalId__c;
    }
}