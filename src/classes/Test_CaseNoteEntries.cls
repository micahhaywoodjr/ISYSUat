@isTest
private class Test_CaseNoteEntries
{
	static testMethod void viewCaseEntriesTest() {
		List<Opportunity> oOpp = [Select Id from Opportunity limit 2];
		ApexPages.currentPage().getParameters().put('Id',oOpp[0].Id);
		ApexPages.currentPage().getParameters().put('doValidation','true');
		viewCaseNoteEntries controller = new viewCaseNoteEntries();
		controller.viewAllCNE();
		controller.oCNE.Activity_Date__c = Date.Parse('2/2/2010');
		controller.FindCaseNoteEntry();
		controller.oCNE.Activity_Date__c = null;
		controller.FindCaseNoteEntry();
		controller.editAllCNE();
		controller.renderSorted();
		controller.strSortBy = 'Activity Date';
		controller.renderSorted();
		for(wrapperCNE oW : controller.lstWrapCNE)
		{
			oW.bShowCheckValue = true;
			break;
		}
		controller.viewSelectedCNE();
		controller.deleteSelected();
		for(wrapperCNE oW : controller.lstWrapCNE)
		{
			OW.bShowCheckValue = true;
			break;
		}
		controller.editSelected();
		controller.doValidation = true;
		controller.SaveModifiedRecords();
		controller.Cancel();

		ApexPages.currentPage().getParameters().put('Id',oOpp[0].Id);
		controller = new viewCaseNoteEntries();
		controller.viewAllCNE();
		controller.oCNE.Activity_Date__c = Date.Parse('2/2/2010');
		controller.FindCaseNoteEntry();
		controller.oCNE.Activity_Date__c = null;
		controller.FindCaseNoteEntry();
		controller.BackToSummary();
		controller.ApproveReject();
		controller.redirectToPage();
		controller.billingCodeChanged();
		controller.getBillingCodeAndFill();
		controller.getReturnTrueIfNurse();
		controller.saveApprove();
		controller.next();
		controller.previous();
		controller.getListOfCodes();
		controller.SOQLFormat(Date.today());
		controller.AddSelected();
		controller.getSortDirection();
		controller.editCancel();
		controller.AddSelectedBot();
		controller.Approve();
		controller.saveAssignment();
		controller.backToView();
		controller.setCommunicationPopup();
		controller.closePopup();
		controller.getCommunicationHistory();
		controller.reAssignOpportunity();
		controller.setSortDirection('String value');
		controller.SaveModifiedRecords();
		ApexPages.currentPage().getParameters().put('SelIds',oOpp[0].Id + ',' + oOpp[0].Id);
		ApexPages.currentPage().getParameters().put('strOppId',oOpp[0].Id);
		viewCaseNoteEntries controller1 = new viewCaseNoteEntries();
		controller1.SaveModifiedRecords();
		controller1.selectedBillingCodeId  = 'test';
		controller1.bFirstView = true;
		controller1.Cancel();
		controller1.availableAttachments  = new List<RelateCommunicatonHistoryController.AttachmentWrapper1>();
		controller1.availableCommunicationHistories = new LIst<RelateCommunicatonHistoryController.TaskWrapper1>();
		Boolean thisBoolean = controller1.bRequiresApproval;
	}

	static testMethod void addCaseEntriesTest() {
		Account a = new Account(Name='Test');
		insert a;
		Opportunity opp = new Opportunity(AccountId=a.Id,name='Test Opportunity 1.0', Amount=0.0, closedate=system.today(),stageName ='Submitted', Service_Date_Thru__c=system.today());
		insert opp;

		Billing_Code__c bill= new Billing_Code__c(name ='01 Test Report',DefaultCode__c=true,Active__c=true);
		insert bill;

		BillingCodeProfileAccess__c b = new BillingCodeProfileAccess__c();
		b.Name = '3';
		b.ProfileId__c = UserInfo.getProfileId().subString(0,15);
		b.BillingCode__c = '01 Test Report';
		insert b;
		List<Opportunity> oOpp = [Select Id from Opportunity limit 1];
		ApexPages.currentPage().getParameters().put('Id',oOpp[0].Id);
		ApexPages.currentPage().getParameters().put('RecAdd','10');
		addCaseNoteEntries controller = new addCaseNoteEntries();
		List<Billing_Code__c> oBill = [Select Id from Billing_Code__c limit 2];
		for(wrapperCNE oW : controller.lstWrapCNE)
		{
			oW.objCNE.Activity_Date__c = Date.Parse('02/11/2010');
			oW.objCNE.Billing_Code__c = oBill[0].id;
			oW.objCNE.Professional_Hours__c = 0.1;
			break;
		}

		Set<String> billingCodesVisible = new Set<String>();
		for(SelectOption so : controller.getBillingCodeAndFill()){
			billingCodesVisible.add(so.getLabel());
		}
		controller.SaveCaseNoteEntry();
		controller.Cancel();
		viewCaseNoteEntries controller1 = new viewCaseNoteEntries();
		controller1.retrieveBillingCode(b.Id);

		controller.getListOfCodes();
		controller.billingCodeChanged();
		controller.getCommunicationHistory();
		controller.closePopup();
		controller.setCommunicationPopup();
		User testUser = controller.objUser;
		Boolean testBoolean = controller.isAdmin;
		controller.retrieveBillingCode(b.Id);


		System.assert(!billingCodesVisible.contains('01 Test Report'));
	}
}