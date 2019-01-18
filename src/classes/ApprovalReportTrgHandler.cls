public with sharing class ApprovalReportTrgHandler {
	
	
	
	public static void updateNewActionDate(List<Approval_Report__c> newList){
		String Approval_Request_Submitted = 'Approval Request Submitted';
		String Step_A = 'Step #1: A Note Report Approval';
		String Step_B = 'Step #2: B Note Report Approval';
		String Step_QA = 'Step #3: QA Report Approval';
		String Step_DA = 'Step #4: Distribution Approval';
		String Step_SubmitToQA = 'Step: SubmitToQA';
		
		Map<String,Integer> stepOrderMap = new Map<String,Integer>();
		stepOrderMap.put(Approval_Request_Submitted,0);
		stepOrderMap.put(Step_A,1);
		stepOrderMap.put(Step_B,2);
		stepOrderMap.put(Step_QA,3);
		stepOrderMap.put(Step_DA,4);
		stepOrderMap.put(Step_SubmitToQA,5);
		
		Map<Integer,String> orderStepMap = new Map<Integer,String>();
		orderStepMap.put(0,Approval_Request_Submitted);
		orderStepMap.put(1,Step_A);
		orderStepMap.put(2,Step_B);
		orderStepMap.put(3,Step_QA);
		orderStepMap.put(4,Step_DA);
		orderStepMap.put(5,Step_SubmitToQA);
		
		
		Set<Id> oppIds = new Set<Id>();
		Set<Id> approvalIds = new Set<Id>();
		for(Approval_Report__c ar : newList){
			oppIds.add(ar.CaseReportEmployeeName__c);
			approvalIds.add(ar.Id);
		}
		
		Map<Id,Approval_Report__c> approvalReportMap = new Map<Id,Approval_Report__c>();
		Map<Id,Map<String,Approval_Report__c>> approvalReportStringMap = new Map<Id,Map<String,Approval_Report__c>>();
		for(Approval_Report__c ar : [SELECT Id,NewActionDate__c,Action__c,CaseReportEmployeeName__c,DateTime__c FROM Approval_Report__c WHERE CaseReportEmployeeName__c IN: oppIds]){
			if(!approvalReportStringMap.containsKey(ar.CaseReportEmployeeName__c))
				approvalReportStringMap.put(ar.CaseReportEmployeeName__c,new Map<String,Approval_Report__c>());
				
			if(!approvalReportStringMap.get(ar.CaseReportEmployeeName__c).containsKey(ar.Action__c))
				approvalReportStringMap.get(ar.CaseReportEmployeeName__c).put(ar.Action__c,ar);
			else if(approvalReportStringMap.get(ar.CaseReportEmployeeName__c).containsKey(ar.Action__c) &&
					approvalReportStringMap.get(ar.CaseReportEmployeeName__c).get(ar.Action__c).DateTime__c < ar.DateTime__c)
				approvalReportStringMap.get(ar.CaseReportEmployeeName__c).put(ar.Action__c,ar);
				
			/*
			if(approvalIds.contains(ar.Id))
				continue;
			if(!approvalReportMap.containsKey(ar.CaseReportEmployeeName__c))
				approvalReportMap.put(ar.CaseReportEmployeeName__c,ar);
			else if(approvalReportMap.containsKey(ar.CaseReportEmployeeName__c) && ar.DateTime__c > approvalReportMap.get(ar.CaseReportEmployeeName__c).DateTime__c)
				approvalReportMap.put(ar.CaseReportEmployeeName__c,ar);*/
		}
		
		List<Approval_Report__c> approvalsToUpdate = new List<Approval_Report__c>();
		
		for(Approval_Report__c ar : newList){
			/*if(approvalReportMap.containsKey(ar.CaseReportEmployeeName__c)){
				Approval_Report__c oldReport = approvalReportMap.get(ar.CaseReportEmployeeName__c);
				oldReport.NewActionDate__c = ar.DateTime__c;
				approvalsToUpdate.add(oldReport);
			}*/
			
			if(approvalReportStringMap.containsKey(ar.CaseReportEmployeeName__c)){
				Map<String,Approval_Report__c> innerApprovals = approvalReportStringMap.get(ar.CaseReportEmployeeName__c);
				
				Integer startingStep = -1;
				if(stepOrderMap.containsKey(ar.Action__c))
					startingStep = stepOrderMap.get(ar.Action__c);
				else
					continue;
				
				System.debug('startingStep:' + startingStep);
				System.debug('ar.Action__c' + ar.Action__c);
				
				if(startingStep > 0 && startingStep != 5){
					Integer previousStep = --startingStep;
					System.debug('previousStep:' + previousStep);
					String actionToUse = orderStepMap.get(previousStep);
					System.debug('actionToUse:' + actionToUse);
					System.debug('innerApprovals:' + innerApprovals);
					if(innerApprovals.containsKey(actionToUse)){
						Approval_Report__c appReport = innerApprovals.get(actionToUse);
						appReport.NewActionDate__c = ar.DateTime__c;
						approvalsToUpdate.add(appReport);
					}
				}
				else
					continue;
				
			}
		}
		
		try{
			update approvalsToUpdate;
		}
		catch(Exception e){
			System.debug(e);
		}
	}
	
}