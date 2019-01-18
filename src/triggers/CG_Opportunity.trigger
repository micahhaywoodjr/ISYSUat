trigger CG_Opportunity on Opportunity (after update) {

set<ID> oIDs = new set<ID>();
set<ID> tIDs = new set<ID>();


 for(Opportunity opp: Trigger.new){
     //Determine if Date has been Updated
        if((Trigger.oldMap.get(opp.id).B_Note_Approval_Date_Time__c == null) && (opp.B_Note_Approval_Date_Time__c !=null)){
            oIDs.add(opp.Id);
        }  
     	if((Trigger.oldMap.get(opp.id).A_Note_Approval_date_Time__c == null) && (opp.A_Note_Approval_Date_Time__c !=null)){
            tIDs.add(opp.Id);
        }
    }

    CG_OpportunityHandler.handleOpportunities(oIDs);
    CG_OpportunityHandler.handleTimesheets(tIDs);
    
    
}