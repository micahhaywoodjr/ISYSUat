trigger ApprovalReportTrigger on Approval_Report__c (after insert) {
	
	try{
		ApprovalReportTrgHandler.updateNewActionDate(Trigger.new);
	}
	catch(Exception e){
		System.debug(e);
	}
	
}