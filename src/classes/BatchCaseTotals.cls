global class BatchCaseTotals implements Database.Batchable<sObject>//, Database.Stateful
{
	//Map<Id,Case> statefulMap = new Map<Id,Case>();
	global Database.Querylocator start(Database.Batchablecontext BC)
    {
    	//Get case ids of all parent cases
    	Set<Id> caseIdsToProcess = new Set<Id>();
    	for(Case c : [SELECT Id,OriginalCase__c FROM Case WHERE OriginalCase__c != null]){
    		caseIdsToProcess.add(c.OriginalCase__c);
    	}
    	//return query of only parent cases to be processed. Children will be queried and summed during execute.
    	return Database.getQueryLocator([Select Id,OriginalCase__c,Total_Invoiced__c, TotalExpenses__c, RushProfessionalHoursB__c, 
    	RushProfessionalBillingsTotalB__c, RushNonProfessionalHoursB__c, RushNonProfessionalBillingsTotalB__c, RushMileageTotalB__c, 
    	RushMileageBillingsTotalB__c, ProfessionalHoursCM__c, ProfessionalHoursB__c, ProfessionalHoursA__c, ProfessionalBillingsTotalB__c, 
    	NonProfessionalHoursCM__c, NonProfessionalHoursB__c, NonProfessionalHoursA__c, NonProfessionalBillingsTotalB__c, MileageTotalCM__c, 
    	MileageTotalB__c, MileageTotalA__c, MileageBillingsTotalB__c, MileageBillingsTotalA__c From Case WHERE Id IN :caseIdsToProcess]);
    }
    global void execute(Database.Batchablecontext BC, list<Case> scope)
    {
    	//Populate map to hold parent case id and list of child cases
    	Map<Id,List<Case>> parentToChildCases = new Map<Id,List<Case>>();
    	for(Case c : scope){
    		parentToChildCases.put(c.Id,new List<Case>());
    	}
    	
    	//loop through all child cases related to the parents passed in from the start method. Populate the children to the correct parent id.
    	for(Case c : [Select Id,OriginalCase__c,Total_Invoiced__c, TotalExpenses__c, RushProfessionalHoursB__c, 
    	RushProfessionalBillingsTotalB__c, RushNonProfessionalHoursB__c, RushNonProfessionalBillingsTotalB__c, RushMileageTotalB__c, 
    	RushMileageBillingsTotalB__c, ProfessionalHoursCM__c, ProfessionalHoursB__c, ProfessionalHoursA__c, ProfessionalBillingsTotalB__c, 
    	NonProfessionalHoursCM__c, NonProfessionalHoursB__c, NonProfessionalHoursA__c, NonProfessionalBillingsTotalB__c, MileageTotalCM__c, 
    	MileageTotalB__c, MileageTotalA__c, MileageBillingsTotalB__c, MileageBillingsTotalA__c From Case WHERE OriginalCase__c IN :parentToChildCases.keySet()]){
    		if(parentToChildCases.containsKey(c.OriginalCase__c))
    			parentToChildCases.get(c.OriginalCase__c).add(c);
    	}
    	
    	/*
    	Map<Id,Case> updateMap = new Map<Id,Case>();
    	Case tempC;*/
    	List<Case> casesToUpdate = new List<Case>();
    	for(Case tempC : scope)
    	{
    		Case newCase = new Case(Id = tempC.Id);
    		//Set the Total Hours to the hours on the case now
    		if(tempC.ProfessionalHoursCM__c!=null)
    			newCase.TotalProfessionalHoursCM__c=tempC.ProfessionalHoursCM__c;
    		else
    			newCase.TotalProfessionalHoursCM__c = 0;
    		if(tempC.ProfessionalHoursA__c!=null)
    			newCase.TotalProfessionalHoursA__c=tempC.ProfessionalHoursA__c;
    		else
    			newCase.TotalProfessionalHoursA__c=0;
    		if(tempC.NonProfessionalHoursCM__c!=null)
    			newCase.TotalNonProfessionalHoursCM__c=tempC.NonProfessionalHoursCM__c;
    		else
    			newCase.TotalNonProfessionalHoursCM__c = 0;
    		if(tempC.NonProfessionalHoursA__c!=null)
    			newCase.TotalNonProfessionalHoursA__c=tempC.NonProfessionalHoursA__c;
    		else
    			newCase.TotalNonProfessionalHoursA__c = 0;
    		if(tempC.MileageTotalCM__c!=null)
    			newCase.TotalMileageTotalCM__c=tempC.MileageTotalCM__c;
    		else
    			newCase.TotalMileageTotalCM__c= 0;
    		if(tempC.MileageTotalA__c!=null)
    			newCase.TotalMileageTotalA__c=tempC.MileageTotalA__c;
    		else
    			newCase.TotalMileageTotalA__c = 0;
    		if(tempC.MileageBillingsTotalA__c!=null)
    			newCase.TotalMileageBillingsTotalA__c=tempC.MileageBillingsTotalA__c;
    		else
    			newCase.TotalMileageBillingsTotalA__c = 0;
    		if(tempC.ProfessionalHoursB__c!=null)
    			newCase.TotalProfessionalHoursB__c=tempC.ProfessionalHoursB__c;
    		else
    			newCase.TotalProfessionalHoursB__c = 0;
    		if(tempC.ProfessionalBillingsTotalB__c!=null)
    			newCase.TotalProfessionalBillingsTotalB__c=tempC.ProfessionalBillingsTotalB__c;
    		else
    			newCase.TotalProfessionalBillingsTotalB__c = 0;
    		if(tempC.NonProfessionalHoursB__c!=null)
    			newCase.TotalNonProfessionalHoursB__c=tempC.NonProfessionalHoursB__c;   
    		else
    			newCase.TotalNonProfessionalHoursB__c = 0; 		
    		if(tempC.NonProfessionalBillingsTotalB__c!=null)
    			newCase.TotalNonProfessionalBillingsTotalB__c=tempC.NonProfessionalBillingsTotalB__c;
    		else
    			newCase.TotalNonProfessionalBillingsTotalB__c = 0;
    		if(tempC.MileageTotalB__c!=null)
    			newCase.TotalMileageTotalB__c=tempC.MileageTotalB__c;
    		else
    			newCase.TotalMileageTotalB__c = 0;
    		if(tempC.MileageBillingsTotalB__c!=null)
    			newCase.TotalMileageBillingsTotalB__c=tempC.MileageBillingsTotalB__c;
    		else
    			newCase.TotalMileageBillingsTotalB__c = 0;	
    		if(tempC.RushProfessionalHoursB__c!=null)
    			newCase.TotalRushProfessionalHoursB__c = tempC.RushProfessionalHoursB__c;
    		else
    			newCase.TotalRushProfessionalHoursB__c = 0;
    		if(tempC.RushProfessionalBillingsTotalB__c!=null)
    			newCase.TotalRushProfBillingsTotalB__c = tempC.RushProfessionalBillingsTotalB__c;
    		else
    			newCase.TotalRushProfBillingsTotalB__c = 0;
    		if(tempC.RushNonProfessionalHoursB__c!=null)
    			newCase.TotalRushNonProfessionalHoursB__c = tempC.RushNonProfessionalHoursB__c;
    		else
    			newCase.TotalRushNonProfessionalHoursB__c = 0;
    		if(tempC.RushNonProfessionalBillingsTotalB__c!=null)
    			newCase.TotalRushNonProfBillingsTotalB__c = tempC.RushNonProfessionalBillingsTotalB__c;
    		else
    			newCase.TotalRushNonProfBillingsTotalB__c = 0;
    		if(tempC.RushMileageTotalB__c!=null)
    			newCase.TotalRushMileageTotalB__c = tempC.RushMileageTotalB__c;
    		else
    			newCase.TotalRushMileageTotalB__c = 0;
    		if(tempC.RushMileageBillingsTotalB__c!=null)
    			newCase.TotalRushMileageBillingsTotalB__c = tempC.RushMileageBillingsTotalB__c;
    		else
    			newCase.TotalRushMileageBillingsTotalB__c = 0;
    		if(tempC.TotalExpenses__c!=null)
    			newCase.GrandTotalExpenses__c = tempC.TotalExpenses__c;
    		else
    			newCase.GrandTotalExpenses__c = 0;
    		if(tempC.Total_Invoiced__c!=null)
    			newCase.GrandTotalInvoiced__c = tempC.Total_Invoiced__c;
    		else
    			newCase.GrandTotalInvoiced__c = 0;
    		/*if(c.OriginalCase__c!=null)
    		{
    			if(!statefulMap.containsKey(c.OriginalCase__c))
    				statefulMap.put(c.OriginalCase__c,new Case(Id=c.OriginalCase__c,TotalRushProfessionalHoursB__c=0, TotalRushProfBillingsTotalB__c=0, TotalRushNonProfessionalHoursB__c=0, TotalRushNonProfBillingsTotalB__c=0, TotalRushMileageTotalB__c=0, TotalRushMileageBillingsTotalB__c=0, TotalProfessionalHoursCM__c=0, TotalProfessionalHoursB__c=0, TotalProfessionalHoursA__c=0, TotalProfessionalBillingsTotalB__c=0, TotalNonProfessionalHoursCM__c=0, TotalNonProfessionalHoursB__c=0, TotalNonProfessionalHoursA__c=0, TotalNonProfessionalBillingsTotalB__c=0, TotalMileageTotalCM__c=0, TotalMileageTotalB__c=0, TotalMileageTotalA__c=0, TotalMileageBillingsTotalB__c=0, TotalMileageBillingsTotalA__c=0, GrandTotalInvoiced__c=0, GrandTotalExpenses__c=0));
    			tempC = statefulMap.get(c.OriginalCase__c);    			
    		}
    		else
    		{
    			if(!statefulMap.containsKey(c.Id))
    				statefulMap.put(c.Id,new Case(Id=c.Id,TotalRushProfessionalHoursB__c=0, TotalRushProfBillingsTotalB__c=0, TotalRushNonProfessionalHoursB__c=0, TotalRushNonProfBillingsTotalB__c=0, TotalRushMileageTotalB__c=0, TotalRushMileageBillingsTotalB__c=0, TotalProfessionalHoursCM__c=0, TotalProfessionalHoursB__c=0, TotalProfessionalHoursA__c=0, TotalProfessionalBillingsTotalB__c=0, TotalNonProfessionalHoursCM__c=0, TotalNonProfessionalHoursB__c=0, TotalNonProfessionalHoursA__c=0, TotalNonProfessionalBillingsTotalB__c=0, TotalMileageTotalCM__c=0, TotalMileageTotalB__c=0, TotalMileageTotalA__c=0, TotalMileageBillingsTotalB__c=0, TotalMileageBillingsTotalA__c=0, GrandTotalInvoiced__c=0, GrandTotalExpenses__c=0));
    			tempC = statefulMap.get(c.Id);
    		}
    		if(!updateMap.containsKey(tempC.Id))
    			updateMap.put(tempC.Id,tempC);
    		*/
    		for(Case c : parentToChildCases.get(tempC.Id)){	
	    		if(c.ProfessionalHoursCM__c!=null)
	    			newCase.TotalProfessionalHoursCM__c+=c.ProfessionalHoursCM__c;
	    		if(c.ProfessionalHoursA__c!=null)
	    			newCase.TotalProfessionalHoursA__c+=c.ProfessionalHoursA__c;
	    		if(c.NonProfessionalHoursCM__c!=null)
	    			newCase.TotalNonProfessionalHoursCM__c+=c.NonProfessionalHoursCM__c;
	    		if(c.NonProfessionalHoursA__c!=null)
	    			newCase.TotalNonProfessionalHoursA__c+=c.NonProfessionalHoursA__c;
	    		if(c.MileageTotalCM__c!=null)
	    			newCase.TotalMileageTotalCM__c+=c.MileageTotalCM__c;
	    		if(c.MileageTotalA__c!=null)
	    			newCase.TotalMileageTotalA__c+=c.MileageTotalA__c;
	    		if(c.MileageBillingsTotalA__c!=null)
	    			newCase.TotalMileageBillingsTotalA__c+=c.MileageBillingsTotalA__c;
	    			
	    		if(c.ProfessionalHoursB__c!=null)
	    			newCase.TotalProfessionalHoursB__c+=c.ProfessionalHoursB__c;
	    		if(c.ProfessionalBillingsTotalB__c!=null)
	    			newCase.TotalProfessionalBillingsTotalB__c+=c.ProfessionalBillingsTotalB__c;
	    		if(c.NonProfessionalHoursB__c!=null)
	    			newCase.TotalNonProfessionalHoursB__c+=c.NonProfessionalHoursB__c;    		
	    		if(c.NonProfessionalBillingsTotalB__c!=null)
	    			newCase.TotalNonProfessionalBillingsTotalB__c+=c.NonProfessionalBillingsTotalB__c;
	    		if(c.MileageTotalB__c!=null)
	    			newCase.TotalMileageTotalB__c+=c.MileageTotalB__c;
	    		if(c.MileageBillingsTotalB__c!=null)
	    			newCase.TotalMileageBillingsTotalB__c+=c.MileageBillingsTotalB__c;
	    			
	    		if(c.RushProfessionalHoursB__c!=null)
	    			newCase.TotalRushProfessionalHoursB__c+=c.RushProfessionalHoursB__c;
	    		if(c.RushProfessionalBillingsTotalB__c!=null)
	    			newCase.TotalRushProfBillingsTotalB__c+=c.RushProfessionalBillingsTotalB__c;
	    		if(c.RushNonProfessionalHoursB__c!=null)
	    			newCase.TotalRushNonProfessionalHoursB__c+=c.RushNonProfessionalHoursB__c;
	    		if(c.RushNonProfessionalBillingsTotalB__c!=null)
	    			newCase.TotalRushNonProfBillingsTotalB__c+=c.RushNonProfessionalBillingsTotalB__c;
	    		if(c.RushMileageTotalB__c!=null)
	    			newCase.TotalRushMileageTotalB__c+=c.RushMileageTotalB__c;
	    		if(c.RushMileageBillingsTotalB__c!=null)
	    			newCase.TotalRushMileageBillingsTotalB__c+=c.RushMileageBillingsTotalB__c;
	    			
	    		if(c.TotalExpenses__c!=null)
	    			newCase.GrandTotalExpenses__c+=c.TotalExpenses__c;
	    		if(c.Total_Invoiced__c!=null)
	    			newCase.GrandTotalInvoiced__c+=c.Total_Invoiced__c;
	    	}
	    	casesToUpdate.add(newCase);
    	}
    	update casesToUpdate;
    	//update updateMap.values();
    }
    global void finish (Database.Batchablecontext BC)
    {
    
    }
}