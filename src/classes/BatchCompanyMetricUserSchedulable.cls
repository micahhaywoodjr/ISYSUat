global class BatchCompanyMetricUserSchedulable implements Schedulable
{
	global void execute(SchedulableContext sc)
    {
    	Database.executeBatch(new BatchCompanyMetricUser());
    }
}