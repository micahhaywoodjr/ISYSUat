global class BatchCaseAvailableCmsSchedulable implements Schedulable
{
	global void execute(SchedulableContext sc)
    {
    	Database.executeBatch(new BatchCaseAvailableCms());
    }
}