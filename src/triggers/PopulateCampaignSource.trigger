//Developed by SFDC Extension team against case#03919655
trigger PopulateCampaignSource on Opportunity (Before Insert) {

    Set<String> setCaseId = new Set<String>();        //set of caseId
    Map<String, String> mapCaseCampaignId = new Map<String, String>();    //map of case Id to campaign Id
    for(Opportunity oppt : Trigger.New){            //Loop through all opportunities
        if(oppt.Related_Case__c != null)                //if opportunity has related case
            setCaseId.add(oppt.Related_Case__c);            //add it to case
    }
    
    //retrieving cases
    List<Case> lstCase = [Select Id, Primary_Campaign__c From Case where Id in: setCaseId];
    
    for(Case c : lstCase){        ///looping through all case records
        if(c.Primary_Campaign__c != null)        //if case has primary campaign
            mapCaseCampaignId.put(c.Id, c.Primary_Campaign__c);        //put case in map
    }
    
    for(Opportunity oppt : Trigger.New){            // loop through all opportunity records
        if(oppt.Related_Case__c != null){    //if opportunity has related case
            if(mapCaseCampaignId.containsKey(oppt.Related_Case__c))    //if this case is in map
                oppt.CampaignId = mapCaseCampaignId.get(oppt.Related_Case__c);        //update campaign
        }
    }

}