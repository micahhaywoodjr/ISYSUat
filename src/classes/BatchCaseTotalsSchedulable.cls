global class BatchCaseTotalsSchedulable implements Schedulable
{
	global void execute(SchedulableContext sc)
    {
    	Database.executeBatch(new BatchCaseTotals());
    }
}