public class OpportunityApprovalQueueController {
	private final string GROUP_A_APPROVALS = 'Pending A Approval';
	private final string GROUP_B_APPROVALS = 'Pending B Approval';
	private final string GROUP_QA_APPROVALS = 'Pending QA Approval';
	private final string GROUP_DISTRIBUTION_APPROVALS = 'Pending Distribution Approval';
	
	public List<ApprovalEntry> AApprovals {get; set;}
	public List<ApprovalEntry> BApprovals {get; set;}
	public List<ApprovalEntry> QAApprovals {get; set;}
	public List<ApprovalEntry> DistributionApprovals {get; set;}
	public boolean isWebTab {get;set;}
	
	public OpportunityApprovalQueueController() {
		AApprovals = new List<ApprovalEntry>();
		BApprovals = new List<ApprovalEntry>();
		QAApprovals = new List<ApprovalEntry>();
		DistributionApprovals = new List<ApprovalEntry>();		
		
		isWebTab = false;
	}

	public PageReference initializeController() {
		try {
			buildApprovalQueueData();
			
			string mode = ApexPages.currentPage().getParameters().get('mode');
			if (mode == 'webtab') {
				isWebTab = true;
			}
		}
		catch (Exception ex) {
			ApexPages.addMessages(ex);
		}
		
		return null;
	}
	
	private void buildApprovalQueueData() {
		AApprovals = new List<ApprovalEntry>();
		BApprovals = new List<ApprovalEntry>();
		QAApprovals = new List<ApprovalEntry>();
		DistributionApprovals = new List<ApprovalEntry>();
		
		Set<Id> oppIds = new Set<Id>();
		Set<Id> processIds = new Set<Id>();
		//Query process work items and build opp id array
		List<ProcessInstanceWorkitem> workitems = [SELECT 
														ActorId, 
														Id, 
														IsDeleted, 
														OriginalActorId, 
														ProcessInstanceId, 
														Actor.Name, 
														OriginalActor.Name, 
														ProcessInstance.Status, 
														ProcessInstance.TargetObjectId 
													FROM 
														ProcessInstanceWorkitem
													WHERE
														IsDeleted = false
														AND ActorId =: UserInfo.getUserId() 
													ORDER BY
														SystemModStamp desc];
		
		Map<Id, ProcessInstanceWorkitem> workItemMap = new Map<Id, ProcessInstanceWorkitem>();
		
		for (ProcessInstanceWorkitem wi : workitems) {
			string oppId = wi.ProcessInstance.TargetObjectId;
			
			if (oppId.startsWith('006')) {
				oppIds.add(oppId);
				processIds.add(wi.ProcessInstanceId);
				
				workItemMap.put(oppId, wi);
			}
		}
		
		Map<Id, ProcessInstanceStep> mapSteps = new Map<Id, ProcessInstanceStep>();
		for (List<ProcessInstanceStep> steps : [SELECT ActorId, Actor.Name, Id, ProcessInstanceId, SystemModStamp FROM ProcessInstanceStep WHERE ProcessInstanceId IN :processIds ORDER BY ProcessInstanceId, SystemModStamp DESC]) {
			for (ProcessInstanceStep step : steps) {
				if(!mapSteps.containsKey(step.ProcessInstanceId)) {
					mapSteps.put(step.ProcessInstanceId, step); 
				}
			}
		}
		
		//Build Opportunity Map
		List<Opportunity> listOpps = [SELECT 
										Name,
										A_Notes_Approved__c, 
										AccountId, 
										B_Notes_Approved__c, 
										Id, 
										In_Review__c, 
										Priority__c, 
										QA_Approved__c, 
										Approval_Status__c,
										Report_Merge_Approved__c, 
										Service_Date_Thru__c, 
										Account.Name,
										RecordTypeId
									FROM 
										Opportunity
									WHERE
										Id IN :oppIds
									ORDER BY
										Priority__c DESC,
										Service_Date_Thru__c];
		
		//Group approvals by approval stage
		for (Opportunity opp : listOpps) {
			ProcessInstanceWorkitem workitem = workItemMap.get(opp.Id);
			
			ApprovalEntry entry = new ApprovalEntry();
			entry.OppEntry = opp;
			entry.ProcessWorkItem = workitem;
			if (mapSteps.containsKey(workitem.ProcessInstanceId)) {
				ProcessInstanceStep step = mapSteps.get(workitem.ProcessInstanceId);
				
				entry.ApproverId = step.ActorId;
				entry.ApproverName = step.Actor.Name;
			}
			else
			{
				entry.ApproverId = UserInfo.getUserId();
				entry.ApproverName = 'Unknown';
			}
			
			if (opp.Approval_Status__c == GROUP_A_APPROVALS) {
				AApprovals.add(entry);
			}
			else if (opp.Approval_Status__c == GROUP_B_APPROVALS) {
				BApprovals.add(entry);
			}
			else if (opp.Approval_Status__c == GROUP_QA_APPROVALS) {
				QAApprovals.add(entry);
			}
			else if (opp.Approval_Status__c == GROUP_DISTRIBUTION_APPROVALS) {
				DistributionApprovals.add(entry);
			}
			else {
				AApprovals.add(entry);
			}
		}
	}
	
	public class ApprovalEntry {
		public Id ApproverId {get;set;}
		public String ApproverName {get;set;}
		public Opportunity OppEntry {get; set;}
		public ProcessInstanceWorkitem ProcessWorkItem {get; set;}
		
		public boolean InReview {
			get {
				if (OppEntry.In_Review__c == null) {
					return false;
				}
				else {
					string reviewText = OppEntry.In_Review__c.toLowerCase();
					if (reviewText == 'no') {
						return false;
					}
					else if (reviewText == 'yes') {
						return true;
					}
					else {
						return false;
					}
				}
			} 
		}
		
		public ApprovalEntry() {
			ApproverId = null;
			ApproverName = '';
			OppEntry = new Opportunity();
			ProcessWorkItem = new ProcessInstanceWorkitem();
		}
	}	
}