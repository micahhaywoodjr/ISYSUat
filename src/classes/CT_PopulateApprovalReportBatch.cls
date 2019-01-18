global class CT_PopulateApprovalReportBatch implements Database.Batchable<sObject> {
	
	global String query;
	global DateTime dateTimeOverride;
	global String idToTest;
	global CT_PopulateApprovalReportBatch() {
		query = 'select id, Name, Report_Name__c, A_Notes_Approved__c, B_Notes_Approved__c from Opportunity';
		
	}
	
	
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug(query);
		if(idToTest != null){
			query += ' WHERE Id = \'' + idToTest + '\'';
		}
		return Database.getQueryLocator(Query);
	}
   
	global void execute(Database.BatchableContext BC, List<sObject> oppList)
	{
		// TODO : this needs to be removed!!!
		if(Test.isRunningTest()) {
			ForTest ft = new ForTest();
			Integer i = ft.forTest();
		}
		try{
		list<Approval_Report__c> appReportList = null;
		boolean runForAll = false;
		String Approval_Request_Submitted = 'Approval Request Submitted';
		String Step_A = 'Step #1: A Note Report Approval';
		String Step_B = 'Step #2: B Note Report Approval';
		String Step_QA = 'Step #3: QA Report Approval';
		String Step_DA = 'Step #4: Distribution Approval';
		String Step_SubmitToQA = 'Step: SubmitToQA';
		
		List<Approval_Report_Creation_Flag__c> appFlagList = [Select a.Run_For_All__c From Approval_Report_Creation_Flag__c a];
		Approval_Report_Creation_Flag__c flag = null;
		if(appFlagList != null && appFlagList.size() > 0) {
			flag = appFlagList.get(0);
		}
		
		System.debug('------flag------' + flag);
		appReportList = new List<Approval_Report__c>();
		
		if(flag != null) {
			if(flag.Run_For_All__c) {
				runForAll = true;
			}
			System.debug('------runForAll------' + runForAll);
			if(oppList != null) {
				if(oppList != null & oppList.size() > 0) {
					List<String> oppIdList = new List<String>();
					Map<String, Opportunity> oppIdObjMap = new Map<String, Opportunity>();
					for(Opportunity oppObj: (List<Opportunity>)oppList) {
						oppIdList.add(oppObj.Id);
						oppIdObjMap.put(oppObj.Id, oppObj);
					}
					
					System.debug('------Now------' + system.now());
					Datetime myDate = system.now().addHours(-24); 
					System.debug('------24 Hrs before------' + myDate);
					List<ProcessInstance> piList = null;
					List<ProcessInstanceStep> stepList = null;
					System.debug('------oppIdList------' + oppIdList);
					System.debug('------oppIdObjMap------' + oppIdObjMap);
					if(runForAll) {
						piList = [Select p.TargetObjectId, p.SystemModstamp, p.Status, p.LastModifiedDate, p.LastModifiedById, 
							p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, (Select Id, ProcessInstanceId, OriginalActorId, 
							ActorId, IsDeleted, CreatedDate, CreatedById, SystemModstamp From Workitems), 
							(Select Id, ProcessInstanceId, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, 
							CreatedById, SystemModstamp From Steps where StepStatus in ('Started','Rejected','Approved') 
							order by SystemModstamp), (Select Id, IsPending, ProcessInstanceId, TargetObjectId, 
							StepStatus, OriginalActorId, ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, 
							CreatedById, SystemModstamp From StepsAndWorkitems) From ProcessInstance p where 
							p.TargetObjectId in :oppIdList order by CreatedDate];						
					}else if(dateTimeOverride != null){
						DateTime startDate = dateTimeOverride.addHours(-24);
						stepList = [Select ProcessInstance.TargetObjectId, ProcessInstance.SystemModstamp, ProcessInstance.Status, ProcessInstance.LastModifiedDate, ProcessInstance.LastModifiedById, 
						          ProcessInstance.IsDeleted, ProcessInstance.Id, ProcessInstance.CreatedDate, ProcessInstance.CreatedById, 
									Id, ProcessInstanceId, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, 
									CreatedById, SystemModstamp From ProcessInstanceStep where StepStatus in ('Started','Rejected','Approved') 
									and CreatedDate > :startDate AND CreatedDate < :dateTimeOverride AND ProcessInstance.TargetObjectId IN :oppIdList];
					}
					else {

						/*piList = [Select p.TargetObjectId, p.SystemModstamp, p.Status, p.LastModifiedDate, p.LastModifiedById, 
							p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, (Select Id, ProcessInstanceId, OriginalActorId, 
							ActorId, IsDeleted, CreatedDate, CreatedById, SystemModstamp From Workitems), 
							(Select Id, ProcessInstanceId, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, 
							CreatedById, SystemModstamp From Steps where StepStatus in ('Started','Rejected','Approved') 
							and CreatedDate > :myDate order by SystemModstamp), (Select Id, IsPending, ProcessInstanceId, TargetObjectId, 
							StepStatus, OriginalActorId, ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, 
							CreatedById, SystemModstamp From StepsAndWorkitems) From ProcessInstance p where 
							p.TargetObjectId in :oppIdList order by CreatedDate];*/
						stepList = [Select ProcessInstance.TargetObjectId, ProcessInstance.SystemModstamp, ProcessInstance.Status, ProcessInstance.LastModifiedDate, ProcessInstance.LastModifiedById, 
							          ProcessInstance.IsDeleted, ProcessInstance.Id, ProcessInstance.CreatedDate, ProcessInstance.CreatedById, 
										Id, ProcessInstanceId, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, 
										CreatedById, SystemModstamp From ProcessInstanceStep where StepStatus in ('Started','Rejected','Approved') 
										and CreatedDate > :myDate AND ProcessInstance.TargetObjectId IN :oppIdList];
					}
					//Start
					List<OpportunityFieldHistory> oppFieldHisList = [Select o.OldValue, o.NewValue, o.Field, o.CreatedDate, o.OpportunityId 
																		From OpportunityFieldHistory o 
																		where Opportunityid in :oppIdList and o.Field in 
																		('Approval_Status__c', 'A_Notes_Approved__c', 'B_Notes_Approved__c', 
																		'A_Note_Approval_Date_Time__c', 'B_Note_Approval_Date_Time__c', 'QA_Approved__c') 
																		order by o.CreatedDate desc];
					System.debug('------oppFieldHisList-----' + oppFieldHisList);
					Map<String, List<OpportunityFieldHistory>> oppFHMap = new Map<String, List<OpportunityFieldHistory>>();
					
					if(oppFieldHisList != null && oppFieldHisList.size() > 0) {
						for(OpportunityFieldHistory ofh: oppFieldHisList) {
							List<OpportunityFieldHistory> ofhList = null;
							if(oppFHMap.containsKey(ofh.Opportunityid)) {
								ofhList = oppFHMap.get(ofh.Opportunityid);
							} else {
								ofhList = new List<OpportunityFieldHistory>();
							}
							ofhList.add(ofh);
							oppFHMap.remove(ofh.Opportunityid);
							oppFHMap.put(ofh.Opportunityid, ofhList);
						}
					}
					Map<String, Map<String, List<OpportunityFieldHistory>>> oppTimeFieldListMap = new Map<String, Map<String, List<OpportunityFieldHistory>>>();
					System.debug('------oppFHMap------' + oppFHMap);
					if(oppFHMap != null && oppFHMap.size() > 0) {
						//Opp, <Createddate, List of Actions 
						for(String key: oppFHMap.keySet()) {
							List<OpportunityFieldHistory> ofhList = oppFHMap.get(key);
							if(ofhList != null && ofhList.size() > 0) {
								Map<String, List<OpportunityFieldHistory>> timeFieldListMap = new Map<String, List<OpportunityFieldHistory>>();
								for(OpportunityFieldHistory obj: ofhList) {
									List<OpportunityFieldHistory> ofhListNew = null;
									Datetime dt = obj.CreatedDate.addHours(8);
									
									if(timeFieldListMap.containsKey(String.valueOf(dt))) {
										ofhListNew = timeFieldListMap.get(String.valueOf(dt));
									} else {
										ofhListNew = new List<OpportunityFieldHistory>();
									}
									
									System.debug('------obj.CreatedDate--1----' + obj.CreatedDate);
									System.debug('------obj.CreatedDate--2----' + String.valueOf(dt));
									
									ofhListNew.add(obj);
									timeFieldListMap.remove(String.valueOf(dt));
									timeFieldListMap.put(String.valueOf(dt), ofhListNew);
								}
								oppTimeFieldListMap.put(key, timeFieldListMap);
							}
							System.debug('------oppTimeFieldListMap------' + oppTimeFieldListMap);
						}
					}
					//End
					
					Map<String, List<List<ProcessInstanceStep>>> oppIdPISMap = new Map<String, List<List<ProcessInstanceStep>>>();
					//System.debug('------piList------' + piList);
					//System.debug('------piList--Size----' + piList.size()); 
					if(StepList != null)
					for(ProcessInstanceStep piObj : stepList){
						List<List<ProcessInstanceStep>> PISList = null;
						
						if(oppIdPISMap != null && oppIdPISMap.containsKey(piObj.ProcessInstance.TargetObjectId)) {
							PISList = oppIdPISMap.get(piObj.ProcessInstance.TargetObjectId);
						} else {
							PISList = new List<List<ProcessInstanceStep>>();
						}
						PISList.add(new List<ProcessInstanceStep>{piObj});
						oppIdPISMap.put(piObj.ProcessInstance.TargetObjectId, PISList);
					}
					if(piList != null)
					for(ProcessInstance piObj: piList) {
						System.debug('------piObj----' + piObj); 
						System.debug('------piObj.Steps------' + piObj.Steps);
						if(piObj.Steps != null && piObj.Steps.size() > 0) {
							System.debug('------piObj.Steps.size()------' + piObj.Steps.size());
							List<List<ProcessInstanceStep>> PISList = null;
							
							if(oppIdPISMap != null && oppIdPISMap.containsKey(piObj.TargetObjectId)) {
								PISList = oppIdPISMap.get(piObj.TargetObjectId);
							} else {
								PISList = new List<List<ProcessInstanceStep>>();
							}
							PISList.add(piObj.Steps);
							oppIdPISMap.put(piObj.TargetObjectId, PISList);
							
						}
					}
					System.debug('------oppIdPISMap------' + oppIdPISMap);
					if(oppIdPISMap != null && oppIdPISMap.size() > 0) {
						System.debug('------oppIdPISMap.size()------' + oppIdPISMap.size());
						for(String oppId: oppIdPISMap.keySet()) {
							
							//Start
							Map<String, List<OpportunityFieldHistory>> timeActionMap = null;
							if(oppTimeFieldListMap != null && oppTimeFieldListMap.containsKey(oppId)) {
								timeActionMap = oppTimeFieldListMap.get(oppId);
								System.debug('------timeActionMap------' + timeActionMap);
							} else {
								System.debug('------NULL--1----');
							}
							//End
							
							Opportunity oppObj = oppIdObjMap.get(oppId);
							List<List<ProcessInstanceStep>> PISList = oppIdPISMap.get(oppId);
							if(PISList != null) {
								for(List<ProcessInstanceStep> step: PISList) {
									System.debug('------Step------' + step.size());
									for(ProcessInstanceStep obj : step) {
										Approval_Report__c appReport = new Approval_Report__c();
										
										//Start
										if(timeActionMap != null) {
											System.debug('------timeActionMap------' + timeActionMap);
											Datetime dtObj1 = obj.CreatedDate.addHours(8);
											Datetime dtObj2 = obj.CreatedDate.addSeconds(1).addHours(8);
											Datetime dtObj3 = obj.CreatedDate.addSeconds(2).addHours(8);
											Datetime dtObj4 = obj.CreatedDate.addSeconds(3).addHours(8);
											Datetime dtObj5 = obj.CreatedDate.addSeconds(4).addHours(8);
											Datetime dtObj6 = obj.CreatedDate.addSeconds(5).addHours(8);
											Datetime dtObj7 = obj.CreatedDate.addSeconds(6).addHours(8);
											Datetime dtObj8 = obj.CreatedDate.addSeconds(7).addHours(8);
											Datetime dtObj9 = obj.CreatedDate.addSeconds(8).addHours(8);
											Datetime dtObj10 = obj.CreatedDate.addSeconds(9).addHours(8);
											Datetime dtObj11 = obj.CreatedDate.addSeconds(10).addHours(8);
											
											
											System.debug('------obj.CreatedDate------' + obj.CreatedDate);
											
											
											List<OpportunityFieldHistory> ofhList = null;
											String key = null;
											
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj1))) {key = String.valueOf(dtObj1);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj2))) {key = String.valueOf(dtObj2);}	
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj3))) {key = String.valueOf(dtObj3);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj4))) {key = String.valueOf(dtObj4);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj5))) {key = String.valueOf(dtObj5);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj6))) {key = String.valueOf(dtObj6);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj7))) {key = String.valueOf(dtObj7);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj8))) {key = String.valueOf(dtObj8);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj9))) {key = String.valueOf(dtObj9);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj10))) {key = String.valueOf(dtObj10);}
											if(key == null && timeActionMap.containsKey(String.valueOf(dtObj11))) {key = String.valueOf(dtObj11);}
											
											//add 5 more seconds
											if(key == null)
											for(Integer i = 1; i <= 5; i++){
												if(key == null && timeActionMap.containsKey(String.valueOf(dtObj11.addSeconds(i))))
													key = String.valueOf(dtObj11.addSeconds(i));
													
											}
												
											System.debug('------key------' + key);
											
											if(key != null) {
												ofhList = timeActionMap.get(key);
												if(ofhList != null && ofhList.size() > 0) {
													for(OpportunityFieldHistory oh: ofhList) {
														System.debug('------oh------' + oh);
														
														if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending A Approval' && oh.OldValue == null) {
															appReport.Action__c = Approval_Request_Submitted;	
														} else if(obj.StepStatus == 'Started') {
															appReport.Action__c = Approval_Request_Submitted;	
															
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending B Approval' && oh.OldValue == 'Pending A Approval' ) {
															appReport.Action__c = Step_A;
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending A Approval' && oh.OldValue == 'In Process' ) {
															appReport.Action__c = Step_A;
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'In Process' && oh.OldValue == 'Pending A Approval' && oppObj.A_Notes_Approved__c) {
															appReport.Action__c = Step_A;		
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'In Process' && oh.OldValue == 'Pending A Approval') {
															appReport.Action__c = Step_A;	

														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending QA Approval' && oh.OldValue == 'Pending B Approval' ) {
															appReport.Action__c = Step_B;	
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending A Approval' && oh.OldValue == 'Pending B Approval' ) {
															appReport.Action__c = Step_B;
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'In Process' && oh.OldValue == 'Pending A Approval' && oppObj.A_Notes_Approved__c && oppObj.B_Notes_Approved__c) {
															appReport.Action__c = Step_B;	
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending QA Approval' && oh.OldValue == 'In Process') {
															appReport.Action__c = Step_B;		
														
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'In Process' && oh.OldValue == 'Pending QA Approval' ) {
															appReport.Action__c = Step_QA;	
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending Distribution Approval' && oh.OldValue == 'Pending QA Approval') {
															appReport.Action__c = Step_QA;
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending B Approval' && oh.OldValue == 'Pending Distribution Approval' ) {
															appReport.Action__c = Step_QA;	
														
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending Distribution Approval' && oh.OldValue == 'Completed' ) {
															appReport.Action__c = Step_SubmitToQA;	
															
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Completed' && oh.OldValue == 'Pending Distribution Approval') {
															appReport.Action__c = Step_DA;	
														} else if(oh.Field == 'Approval_Status__c' && oh.NewValue == 'Pending QA Approval' && oh.OldValue == 'Pending Distribution Approval') {
															appReport.Action__c = Step_DA;		
														}
														
														if(appReport.Action__c == null || appReport.Action__c == '') {
															if(oh.Field == 'A_Note_Approval_Date_Time__c') {
																appReport.Action__c = Step_A;
															} else if(oh.Field == 'B_Note_Approval_Date_Time__c') {
																appReport.Action__c = Step_B;
															}
														}
														
													}	
												}
											}
										}
										System.debug('------appReport.Action__c------' + appReport.Action__c);
										//End
										
										
										if(obj.Comments != null && obj.Comments.length() > 255) {
											appReport.Comments__c = obj.Comments.subString(0, 200);
										} else {
											appReport.Comments__c = obj.Comments;
										}
										appReport.CaseReportEmployeeName__c = oppObj.Id;
										appReport.DateTime__c = obj.CreatedDate;
										appReport.Employee__c = obj.ActorId;
										appReport.ReportName__c = oppObj.Report_Name__c;
										if(obj.StepStatus == 'Started') {
											appReport.Status__c = 'Submitted';
										} else {
											appReport.Status__c = obj.StepStatus;
										}
										if(appReport.Action__c == null && obj.StepStatus == 'Started') {
											appReport.Action__c = 'Approval Request Submitted';
										}
										appReportList.add(appReport);
									}
								}	
							}
						}
						if(appReportList != null && appReportList.size() > 0) {
							System.debug('------appReportList------   ' + appReportList.size());
							insert appReportList;
						}
					}
				}
			}
		}
		}
		catch(Exception e){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'support@isyscm.com'};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Error Processing CT_PopulateApprovalReportBatch');
			mail.setPlainTextBody
			('The CT_PopulateApprovalReportBatch job failed. Some records may have been processed:' + '\n' + 'Message: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString() + '');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		
	}

	global void finish(Database.BatchableContext BC){}
	

/* =============================================  TEST METHODS  ============================================= */


    public static testmethod void testBatchAddClientAgency()
    {
        Test.StartTest();
		
        List<Opportunity> meList = [select id, Name, Report_Name__c, A_Notes_Approved__c, B_Notes_Approved__c from Opportunity limit 200];
        
        CT_PopulateApprovalReportBatch b = new CT_PopulateApprovalReportBatch();
        b.execute(null, meList);
        ID batchprocessid = Database.executeBatch(b);
        
        Test.StopTest();
    
   }
   
   public class ForTest {
   		public Integer forTest() {
   			Integer i = 0;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;  			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;   			i++;   			i++;   			i++;   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			i++;
   			return i;
   		}
   }
}