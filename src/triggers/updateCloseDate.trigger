trigger updateCloseDate on Opportunity (Before update) {
/**
This trigger was developed to store the Closed Date, this is just to ensure that the opportunity always keeps the closed date from the first time it was submitted for approval.

**/

for(opportunity oppty:Trigger.new)
{

    if(oppty.Submitted__c == true)
    {
        if(oppty.First_Submission_Closed_Date__c == null)
        {
            oppty.First_Submission_Closed_Date__c = oppty.closeDate;
        }
        
        if(oppty.First_Submission_Closed_Date__c != null)
        {
            if(oppty.First_Submission_Closed_Date__c != oppty.closeDate)
            {
                oppty.closeDate = oppty.First_Submission_Closed_Date__c;
            }
        
        }
        
    }
}
}