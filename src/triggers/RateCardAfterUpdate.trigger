trigger RateCardAfterUpdate on Rate_Card__c (after update) {
    List<Rate_Card__c> lstRC = Trigger.New;
    if(lstRC!=null && lstRC.size()>0)
    {
    	Set<String> setAccountIds = new Set<String>();
        Set<String> setRCIds = new Set<String>();
        for(Rate_Card__c oRC : lstRC)
        {
            if((oRC.Travel_Wait_Rate__c != Trigger.oldMap.get(oRC.Id).Travel_Wait_Rate__c) ||
                (oRC.Rush_Travel_Wait_Rate__c != Trigger.oldMap.get(oRC.Id).Rush_Travel_Wait_Rate__c) ||
                (oRC.Rush_Professional_Rate__c != Trigger.oldMap.get(oRC.Id).Rush_Professional_Rate__c) ||
                (oRC.Rush_Mileage_Rate__c != Trigger.oldMap.get(oRC.Id).Rush_Mileage_Rate__c) ||
                (oRC.Professional_Rate__c != Trigger.oldMap.get(oRC.Id).Professional_Rate__c) ||
                (oRC.Mileage_Rate__c != Trigger.oldMap.get(oRC.Id).Mileage_Rate__c))
            {
                setAccountIds.add(oRC.Account__c);
                setRCIds.add(oRC.Id);
            }
        }
        
        if(setRCIds.size()>0)
        {
        	List<Opportunity> lstOpp = new List<Opportunity>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
                Rush_Mileage_Rate__c, Professional_Rate__c, QBJurisdiction__c, Mileage_Rate__c, AccountId, Amount_Locked__c From Opportunity Where AccountId in : setAccountIds]);
            
            List<Rate_Card__c> lstRateCard = new List<Rate_Card__c>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
                Rush_Mileage_Rate__c, Professional_Rate__c, Mileage_Rate__c, Account__c, Name From Rate_Card__c Where Id in : setRCIds]);
                
            Map<String, List<Opportunity>> mapOppLegal = new Map<String, List<Opportunity>>();
            for(Opportunity oOpp : lstOpp)
            {
            	if(!mapOppLegal.containsKey(oOpp.AccountId+'~'+oOpp.QBJurisdiction__c))
            	{
            		List<Opportunity> tmpList = new List<Opportunity>();
            		tmpList.add(oOpp);
            		mapOppLegal.put(oOpp.AccountId+'~'+oOpp.QBJurisdiction__c, tmpList);
            	}
            	else
                    mapOppLegal.get(oOpp.AccountId+'~'+oOpp.QBJurisdiction__c).add(oOpp);
            }    
            List<Opportunity> lstToUpdate = new List<Opportunity>();
            for(Rate_Card__c objRC : lstRateCard)
            {
            	List<Opportunity> tmpLstOpp = mapOppLegal.get(objRC.Account__c+'~'+objRC.Name);
            	if(tmpLstOpp!=null && tmpLstOpp.size()>0)
            	{
	            	for(Opportunity objOpp : tmpLstOpp)
	            	{
	            		if(!objOpp.Amount_Locked__c)
	            		{
	            			objOpp.Travel_Wait_Rate__c = objRC.Travel_Wait_Rate__c;
	                        objOpp.Rush_Travel_Wait_Rate__c = objRC.Rush_Travel_Wait_Rate__c;
	                        objOpp.Rush_Professional_Rate__c = objRC.Rush_Professional_Rate__c;
	                        objOpp.Rush_Mileage_Rate__c = objRC.Rush_Mileage_Rate__c;
	                        objOpp.Professional_Rate__c = objRC.Professional_Rate__c;
	                        objOpp.Mileage_Rate__c = objRC.Mileage_Rate__c;
	                        lstToUpdate.add(objOpp);
	            		}
	            	}
            	}
            }
            
            if(lstToUpdate.size()>0)
                update lstToUpdate;
        }
    }
}