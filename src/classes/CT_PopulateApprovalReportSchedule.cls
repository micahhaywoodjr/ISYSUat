global class CT_PopulateApprovalReportSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CT_PopulateApprovalReportBatch());
    }
    
    public static testmethod void testBatchAddClientAgency(){
        Test.startTest();
        CT_PopulateApprovalReportSchedule sch = new CT_PopulateApprovalReportSchedule();
        sch.execute(null);
        Test.stopTest();
	}
}