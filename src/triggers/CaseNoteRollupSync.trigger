trigger CaseNoteRollupSync on Opportunity (after delete, after insert, after undelete, after update) 
{
	Set<String> stagesToCount = new Set<String>();
	stagesToCount.add('Submitted');
	stagesToCount.add('Approved');
	stagesToCount.add('Completed');
	
	Set<Id> caseIds = new Set<Id>();
	if (Trigger.isDelete) 
	{
		for (Opportunity opp : trigger.old) 
		{
			if (opp.Related_Case__c != null) 
				caseIds.add(opp.Related_Case__c);			
		}
	}
	else 
	{
		for (Opportunity opp : trigger.new) 
		{
			if (opp.Related_Case__c != null) 
				caseIds.add(opp.Related_Case__c);			
		}
	}
	
	if (!caseIds.isEmpty()) 
	{
		List<Case> casesToUpdate = new List<Case>();
		for (Case c : [SELECT Id, (SELECT Amount, A_Professional_Hours_Nurse_Total__c, A_Professional_Hours_Total__c, Service_Date_Thru__c, B_Professional_Hours_Total__c, 
		A_Non_Professional_Hours_Nurse_Total__c, A_Non_Professional_Hours_Total__c, B_Non_Professional_Hours_Total__c, A_Mileage_Billings_Total__c, A_Mileage_Miles_Nurse_Total__c,
		A_Mileage_Miles_Total__c, A_Non_Professional_Billings_Total__c, A_Professional_Billings_Total__c, B_Mileage_Billings_Total__c, B_Mileage_Miles_Total__c,
		B_Non_Professional_Billings_Total__c, B_Professional_Billings_Total__c, B_Rush_Mileage_Billings_Total__c, B_Rush_Mileage_Miles_Total__c, B_Rush_Non_Professional_Billings_Total__c,
		B_Rush_Non_Professional_Hours_Total__c, B_Rush_Professional_Billings_Total__c, B_Rush_Professional_Hours_Total__c, Total_Expenses__c, Primary_NCM_Prof_Hours__c,
		Primary_NCM_Travel_Wait_Hours__c, Primary_NCM_Mileage__c, Covering_NCM_Prof_Hours__c, Covering_NCM_Travel_Wait_Hours__c, Covering_NCM_Mileage__c, ProfHoursPrimaryCMCredit__c,
		PrimaryCMTravelWaitHoursCredit__c, CoveringCMProfHours__c, CoveringCMTravelWaitHoursCredit__c, StageName FROM Opportunities__r ORDER BY Service_Date_Thru__c Desc) FROM Case WHERE Id in :caseIds]) 
		{
			Case caseToUpdate = new Case(Id=c.Id);
			decimal totalInvoiced = 0;
			decimal professionalHoursCM = 0;
			decimal nonprofessionalHoursCM = 0;
			decimal mileageTotalCM = 0;
			decimal professionalHoursA = 0;
			decimal nonprofessionalHoursA = 0;
			decimal mileageTotalA = 0;
			decimal mileageBillingsTotalA = 0;
			decimal professionalHoursB = 0;
			decimal nonprofessionalHoursB = 0;
			decimal mileageTotalB = 0;
			decimal professionalBillingsTotalB = 0;
			decimal nonprofessionalBillingsTotalB = 0;
			decimal mileageBillingsTotalB = 0;
			decimal rushProfessionalHoursB = 0;
			decimal rushNonProfessionalHoursB = 0;
			decimal rushMileageTotalB = 0;
			decimal rushProfessionalBillingsTotalB = 0;
			decimal rushNonProfessionalBillingsTotalB = 0;
			decimal rushMileageBillingsTotalB = 0;
			decimal totalExpenses = 0;
			decimal primaryCMProfHours = 0;
			decimal primaryCMTravelWaitHours = 0;
			decimal primaryCMMileage = 0;
			decimal coveringCMProfHours = 0;
			decimal coveringCMTravelWaitHours = 0;
			decimal coveringCMMileage = 0;
			decimal primaryCMProfHoursCredit = 0;
			decimal primaryCMTravelWaitHoursCredit = 0;
			decimal coveringCMProfHoursCredit = 0;
			decimal coveringCMTravelWaitHoursCredit = 0;
			date dateOfLastReport = null;
			
			for (Opportunity opp : c.Opportunities__r) 
			{
				if (opp.StageName != 'In Process' && dateOfLastReport == null) 
					dateOfLastReport = opp.Service_Date_Thru__c;				
				
				if (stagesToCount.contains(opp.StageName)) 
				{
					totalInvoiced += opp.Amount;
					professionalHoursCM += opp.A_Professional_Hours_Nurse_Total__c;
					nonprofessionalHoursCM += opp.A_Non_Professional_Hours_Nurse_Total__c;
					mileageTotalCM += opp.A_Mileage_Miles_Nurse_Total__c;
					professionalHoursA += opp.A_Professional_Hours_Total__c;
					nonprofessionalHoursA += opp.A_Non_Professional_Hours_Total__c;
					mileageTotalA += opp.A_Mileage_Miles_Total__c;
					mileageBillingsTotalA += opp.A_Mileage_Billings_Total__c;
					professionalHoursB += opp.B_Professional_Hours_Total__c;
					nonprofessionalHoursB += opp.B_Non_Professional_Hours_Total__c;
					mileageTotalB += opp.B_Mileage_Miles_Total__c;
					professionalBillingsTotalB += opp.B_Professional_Billings_Total__c;
					nonprofessionalBillingsTotalB += opp.B_Non_Professional_Billings_Total__c;
					mileageBillingsTotalB += opp.B_Mileage_Billings_Total__c;
					rushProfessionalHoursB += opp.B_Rush_Professional_Hours_Total__c;
					rushNonProfessionalHoursB += opp.B_Rush_Non_Professional_Hours_Total__c;
					rushMileageTotalB += opp.B_Rush_Mileage_Miles_Total__c;
					rushProfessionalBillingsTotalB += opp.B_Rush_Professional_Billings_Total__c;
					rushNonProfessionalBillingsTotalB += opp.B_Rush_Non_Professional_Billings_Total__c;
					rushMileageBillingsTotalB += opp.B_Rush_Mileage_Billings_Total__c;
					primaryCMProfHours += opp.Primary_NCM_Prof_Hours__c;
					primaryCMTravelWaitHours += opp.Primary_NCM_Travel_Wait_Hours__c;
					primaryCMMileage += opp.Primary_NCM_Mileage__c;
					coveringCMProfHours += opp.Covering_NCM_Prof_Hours__c;
					coveringCMTravelWaitHours += opp.Covering_NCM_Travel_Wait_Hours__c;
					coveringCMMileage += opp.Covering_NCM_Mileage__c;
					primaryCMProfHoursCredit += opp.ProfHoursPrimaryCMCredit__c;
					primaryCMTravelWaitHoursCredit += opp.PrimaryCMTravelWaitHoursCredit__c;
					coveringCMProfHoursCredit += opp.CoveringCMProfHours__c;
					coveringCMTravelWaitHoursCredit += opp.CoveringCMTravelWaitHoursCredit__c;
					totalExpenses += opp.Total_Expenses__c;
				}
			}
			
			//When a delete is triggered and no Submitted opps exist then
			//just grab the most recent Service Date across all related opps.
			if (dateOfLastReport == null && Trigger.isDelete) 
			{
				for (Opportunity opp : c.Opportunities__r) 
				{
					dateOfLastReport = opp.Service_Date_Thru__c;
					break;
				}
			}
			
			if (c.Opportunities__r == null) 
				caseToUpdate.Date_of_Last_Report__c = dateOfLastReport;			
			else if (dateOfLastReport != null) 
				caseToUpdate.Date_of_Last_Report__c = dateOfLastReport;
						
			caseToUpdate.Total_Invoiced__c = totalInvoiced;
			caseToUpdate.ProfessionalHoursCM__c = professionalHoursCM;
			caseToUpdate.NonProfessionalHoursCM__c = nonprofessionalHoursCM;
			caseToUpdate.MileageTotalCM__c = mileageTotalCM;
			caseToUpdate.ProfessionalHoursA__c = professionalHoursA;
			caseToUpdate.NonProfessionalHoursA__c = nonprofessionalHoursA;
			caseToUpdate.MileageTotalA__c = mileageTotalA;
			caseToUpdate.MileageBillingsTotalA__c = mileageBillingsTotalA;
			caseToUpdate.ProfessionalHoursB__c = professionalHoursB;
			caseToUpdate.NonProfessionalHoursB__c = nonprofessionalHoursB;
			caseToUpdate.MileageTotalB__c = mileageTotalB;
			caseToUpdate.ProfessionalBillingsTotalB__c = professionalBillingsTotalB;
			caseToUpdate.NonProfessionalBillingsTotalB__c = nonprofessionalBillingsTotalB;
			caseToUpdate.MileageBillingsTotalB__c = mileageBillingsTotalB;
			caseToUpdate.RushProfessionalHoursB__c = rushProfessionalHoursB;
			caseToUpdate.RushNonProfessionalHoursB__c = rushNonProfessionalHoursB;
			caseToUpdate.RushMileageTotalB__c = rushMileageTotalB;
			caseToUpdate.RushProfessionalBillingsTotalB__c = rushProfessionalBillingsTotalB;
			caseToUpdate.RushNonProfessionalBillingsTotalB__c = rushNonProfessionalBillingsTotalB;
			caseToUpdate.RushMileageBillingsTotalB__c = rushMileageBillingsTotalB;
			caseToUpdate.PrimaryCMProfHours__c = primaryCMProfHours;
			caseToUpdate.PrimaryCMTravelWaitHours__c = primaryCMTravelWaitHours;
			caseToUpdate.PrimaryCMMileage__c = primaryCMMileage;
			caseToUpdate.CoveringCMProfHours__c = coveringCMProfHours;
			caseToUpdate.CoveringCMTravelWaitHours__c = coveringCMTravelWaitHours;
			caseToUpdate.CoveringCMMileage__c = coveringCMMileage;
			caseToUpdate.PrimaryCMProfHoursCredit__c = primaryCMProfHoursCredit;
			caseToUpdate.PrimaryCMTravelWaitHoursCredit__c = primaryCMTravelWaitHoursCredit;
			caseToUpdate.CoveringCMProfHoursCredit__c = coveringCMProfHoursCredit;
			caseToUpdate.CoveringCMTravelWaitHoursCredit__c = coveringCMTravelWaitHoursCredit;
			caseToUpdate.TotalExpenses__c = totalExpenses;
			
			casesToUpdate.add(caseToUpdate);
		}
		
		if (!casesToUpdate.isEmpty()) 
			update casesToUpdate;
	}
}