trigger SurveyResultsTrigger on Survey_Results__c (before insert, before update, before delete, after insert, after update, after delete) {

    if(Trigger.isAfter) {

        if(Trigger.isDelete) {

            List<Survey_Results__c> surveys = new List<Survey_Results__c>();

            for(Survey_Results__c sr : Trigger.old) {

                surveys.add(sr);

            }
            // Call the Flow
            Map<String, Object> params = new Map<String, Object>();
            params.put('SurveyResults', surveys);
            Flow.Interview.UpdateSurveyScore updateSurveyResults = new Flow.Interview.UpdateSurveyScore(params);
            updateSurveyResults.start();

        }
    }
}