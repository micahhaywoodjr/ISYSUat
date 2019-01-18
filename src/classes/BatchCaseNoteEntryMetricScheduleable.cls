global class BatchCaseNoteEntryMetricScheduleable implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchCaseNoteEntryMetrics());
    }
}