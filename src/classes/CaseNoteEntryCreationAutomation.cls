public class CaseNoteEntryCreationAutomation {

    //Handler for auto creation of Case Note Entry records

	public static void CaseNoteEntryHandler(set<ID> tIDs){
		
		//RETURN IF FALSE
		CaseNoteEntryAutomation__c cs = CaseNoteEntryAutomation__c.getOrgDefaults();
		if(!cs.Active__c && cs.Billing_Code_ID__c != null)
			return;
		
		//Split the list into batches of 50
	    list<set<ID>> tIDSetList = new list<set<ID>>();

		set<ID> currentSet = new set<ID>();
		Integer currentCount = 1;
		
		for(ID i: tIDs){
		   if(currentCount == 50){
		       currentSet.add(i);dispatchNewRecords(currentSet);currentSet = new set<ID>();currentCount = 1;
		   }else{
		       currentSet.add(i);
		       currentCount++;
		   }
		}
		
		if(currentSet.size() > 0)
    		dispatchNewRecords(currentSet);
	}
	
	public static void dispatchNewRecords(set<ID> tIDs){
	    
	    	//CHECK CUSTOM SETTING FOR ENABLED FLAG
		//RETURN IF FALSE
		CaseNoteEntryAutomation__c cs = CaseNoteEntryAutomation__c.getOrgDefaults();
		if(!cs.Active__c && cs.Billing_Code_ID__c != null)
			return;

		//Case Note Entry Creation Automation
		String casePrefix = Schema.SObjectType.Case.getKeyPrefix();
		ID nurseProfileId = [Select ID from Profile Where Name ='Custom - Nurse' LIMIT 1].Id;
		ID srNurseProfileId = [Select ID from Profile Where Name = 'Custom - Sr Nurse' LIMIT 1].Id;

		set<Task> processSet = new set<Task>();

		list<Task> tList = [Select ID, Status, ActivityDate, Subject, Owner.ProfileId, OwnerId, WhatId 
									from Task 
									Where Id in: tIDs 
										AND (Owner.ProfileId =: nurseProfileId OR Owner.ProfileId =: srNurseProfileId OR OwnerId =: '0050R000000WXPb')
										AND Status = 'Completed'
										AND WhatId != NULL
							];

		for(Task t:tList){
			//Check for Tasks meeting criteria for creation of Case Note Entry
			/*Criteria
				Associated to Case
				Owner profile is Custom - Nurse OR Custom - Sr. Nurse
				Subject starts with Email
			*/	
			if(((String)t.WhatId).startsWith(casePrefix) 
					&& t.Subject.startsWith('Email')){
				processSet.add(t);
			}
		}

		//Send Identified records to process
		if(processSet.size() > 0)
			processNewRecords(processSet, cs.Billing_Code_ID__c);
	    
	}
	
	
	

	//Process all identified records
	public static void processNewRecords(set<Task> tList, String billingCodeID){

		list<Task> updateList = new list<Task>();
		list<Case_Note_Entry__c> insertList = new list<Case_Note_Entry__c>();

		set<ID> cIDs = new set<ID>();
		for(Task t :tList){
			cIDs.add(t.whatId);
		}
		//Query the associated Cases with associated info
		
		
		//Date d = System.Today();
	/*	map<ID,CASE> cMap = 
			new map<ID,CASE>([SELECT ID, 
								(SELECT ID, StageName, Service_Date_From__c, Service_Date_Thru__c
									FROM CASE.Opportunities__r 
									WHERE StageName = 'In Process' AND Service_Date_From__c <=: d 
																   AND Service_Date_Thru__c >=: d) 
								FROM CASE WHERE ID in:cIDs]);
		*/		
		for(Task t: tList){
			//Query in loop intentionally placed.
			//method running Async with max 50 batch being send to process
			list<Case> cRecord = [SELECT ID, 
								(SELECT ID, StageName, Service_Date_From__c, Service_Date_Thru__c
									FROM CASE.Opportunities__r 
									WHERE StageName = 'In Process' AND Service_Date_From__c <=: t.ActivityDate 
																   AND Service_Date_Thru__c >=: t.ActivityDate) 
								FROM CASE WHERE ID=:t.WhatId];

			if(cRecord.size() > 0){
				Case c = cRecord[0];
				list<Opportunity> opps = c.Opportunities__r;
				if(opps.size() != null && opps.size() == 1){
					//Build Case Note Entry
					insertList.add(createCNE(t, c, opps[0],billingCodeID));
					t.Case_Note_Entry__c = true;
					updateList.add(t);
				}else{
					//IF MORE THEN ONE FOUND FLAG TASK RECORD
					updateList.add(new Task(Id=t.Id, Error_Case_Note_Entry_Creation__c = true));
				}
			}

			/*if(cMap.containsKey(t.WhatId)){
				Case c = cMap.get(t.WhatId);
				list<Opportunity> opps = c.Opportunities__r;
				if(opps.size() != null && opps.size() == 1){
					//Build Case Note Entry
					insertList.add(createCNE(t, c, opps[0],billingCodeID));
					t.Case_Note_Entry__c = true;
					updateList.add(t);
				}else{
					//IF MORE THEN ONE FOUND FLAG TASK RECORD
					updateList.add(new Task(Id=t.Id, Error_Case_Note_Entry_Creation__c = true));
				}
			}*/
		}
		//INSERT CASE NOTE ENTRY 
		if(insertList.size() > 0)
			insert insertList;
		//UPDATE TASK RECORDS for ERRORS
		if(updateList.size() > 0)
			update updateList;
		//NOTIFY TASK OWNER THAT ERROR CREATING CASENOTEENTRY (MAYBE A WORKFLOW INSTEAD OF APEX)
	}

	//Create Case Note Entry with default values
	public static Case_Note_Entry__c createCNE(Task t, Case c, Opportunity o, String billingCodeID){
		Case_Note_Entry__c cne = new Case_Note_Entry__c();
		cne.Activity_Date__c = t.ActivityDate != null ? t.ActivityDate : System.Today();
		cne.Report__c = o.Id;
		cne.Work_Description__c = '***Case Manager to complete description***';
		cne.Professional_Hours_Nurse__c = 0.1;
		cne.Billing_Code__c = billingCodeID;
		cne.RelatedCommunicationHistories__c = t.Id +';;' + t.Subject + ',,';

		return cne;
	}
}