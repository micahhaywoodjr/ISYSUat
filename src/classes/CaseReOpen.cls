public without sharing class CaseReOpen 
{
	Case c;
	public CaseReOpen(ApexPages.StandardController con)
	{
		c = (Case)con.getRecord();
	}
	public PageReference reOpenCase()
	{
		if(!hasChild())
		{
			c = [Select c.OriginalCase__c, c.Zip__c, c.Vocational_Assessment__c, c.UR_Vendor__c, c.Type, c.Reason, c.Treating_Physician__c, c.Treating_Physician_Zip__c, c.Treating_Physician_State__c, 
			c.Treating_Physician_City__c, c.Treating_Physician_Address__c, c.Total_Case_Time_Open__c, c.Task_Assignment__c, 
			c.TTD_Yes__c, c.TTD_No__c, c.TTD_Explanation__c, c.SystemModstamp, c.SuppliedPhone, c.SuppliedName, c.SuppliedEmail, c.SuppliedCompany, c.Supervised_by__c, 
			c.Status, c.State__c, c.Specialty__c, c.Senior_Mentor__c, c.Salesforce_ID__c, c.S_S_N_Web__c, c.SSN__c, c.Rush__c, c.Rush_Indicator__c, 
			c.Restrictions_unchanged_comment__c, c.Restrictions_unchanged_because__c, c.Remain_U_C_w_o_Modifications__c, c.Remain_U_C_w_Modifications__c, c.Region__c, 
			c.Referral_Date__c, c.RecordTypeId, c.Received_from_CR_Rep_via__c, c.Rate__c, c.RTW_Comments__c, c.QB_Service_Item__c, c.Priority, 
			c.Primary_Language__c, c.Primary_Campaign__c, c.PrimaryProvidersNumber__c, c.Preferred_Provider_Optional__c, c.Preferred_Method_of_Communication__c, 
			c.Phone_Treating_Physician__c, c.Phone_Employer__c, c.Phone_Employee_Attorney__c, c.Phone_Defense__c, c.ParentId, c.P_S_Target_Date__c, 
			c.P_S_PTP_Discussion__c, c.PLEASE_PROVIDE_REASONS_FOR_REFERRAL__c, c.OwnerId, c.OwnerAtCaseClose__c, c.Other_Special_Instructions__c, 
			c.Origin, c.Occupation__c, c.Nature_and_History_of_Injury__c, c.NCM_Telephonic__c, c.NCM_Onsite__c, c.NCM_Long_Term_Disability__c, c.NCM_Catastrophic__c, 
			c.Motivation_to_RTW__c, c.Medical_Records_to_be_Provided_By__c, c.Light_Duty_Modified_Work__c, c.Life_Care_Plans__c, c.Legal_Jurisdiction__c, c.Last_Report_Aging__c,  
			c.Labor_Market_Survey__c, c.Jurisdiction__c, c.Job_Evaluation_Available__c, c.Job_Analysis__c, c.Internal_Assignment_Comments__c, c.OwnerAtCaseClose__r.Id,
			c.Initial_Intake__c, c.Id, c.ISYS_File__c, c.ICD9_Code__c, c.HasSelfServiceComments, c.HasCommentsUnreadByOwner, c.File_Number_Autonumber__c, c.Fax__c, 
			c.Fax_Treating_Physician__c, c.Fax_Employer__c, c.Expedited_Activity__c, c.Ergonomic_Evaluation__c, c.End_Result__c, c.Enclosures__c, c.Employer__c, 
			c.Employer_Zip__c, c.Employer_State__c, c.Employer_City__c, c.Employer_Address__c, c.Employer_Account_Record__c, c.Employee__c, c.Employee_Zip__c, 
			c.Employee_State__c, c.Employee_Phone__c, c.Employee_Gender__c, c.Employee_City__c, c.Employee_Case_Trakker__c, c.Employee_Address__c, c.Email_Employer__c, 
			c.Days_from_injury_to_referral_date__c, c.Days_from_Injury_to_Referral_Date2__c, c.DateofIssue__c, c.Date_of_injury_MM_DD_YYYY__c, 
			c.Date_of_Next_Appointment__c, c.Date_of_Last_Report__c, c.Date_of_Birth__c, c.Date_Received__c, c.Customer_Guidelines__c, c.Current_Work_Status__c, 
			c.Current_Treatment__c, c.Current_Prognosis__c, c.Current_Diagnosis__c, c.Correct_Closure_Date__c, c.Contact_Person__c, c.ContactId, c.Comments_PTP__c, c.Comments_Employer__c, c.Comments_Employee__c, c.Comments_Attorneys__c, c.Claimant__c, 
			c.Claim_Time__c, c.Claim_Number__c, c.City__c, c.Category_of_Complaint__c, c.Cases_Closed_Current_Year__c, c.CaseNumber, c.CC_Reports_To__c, c.AvailableCMs__c, 
			c.Attorney_Representation__c, c.Attorney_Present__c, c.Attorney_Employee__c, c.Attorney_Employee_Contact_Record__c, c.Attorney_Defense__c, 
			c.Attorney_Defense_Zip__c, c.Attorney_Defense_State__c, c.Attorney_Defense_Contact_Record__c, c.Attorney_Defense_City__c, c.Attorney_Defense_Address__c, 
			c.Attorney_Applicant_Zip__c, c.Attorney_Applicant_State__c, c.Attorney_Applicant_City__c, c.Attorney_Applicant_Address__c, c.Assignment_Region__c, 
			c.AssignmentRegion__c, c.AreaNumber__c, c.Approval_for_NCM__c, c.Approval_Date__c, c.Alternate_Contact_Number__c, c.Address_Treating_Physician__c, 
			c.Address_Referring_Company__c, c.Address_Employer__c, c.Address_Employee__c, 
			c.AccountId, (Select Id, Name, LastActivityDate, Admission_Date__c, Discharge_Date__c, Surgery_Type_Reason_for_Hospital_Visit__c, Status__c, Type__c, Case__c From Surgeries_Hospitalizations__r), (Select Id, Name, Case__c, Contact__c, Specialty__c, Phone__c, Primary__c, City_Of_Primary_Treater__c, Mailing_Address__c, Inactive__c, Area__c, Region__c, ProviderStatus__c, AreaCode__c, AreaRegion__c From Other_Healthcare_Providers__r WHERE ProviderStatus__c='Active'), (Select Id, CasesId, ContactId, Role From CaseContactRoles) From Case c WHERE c.Id=:c.Id];
			Case newCase = c.clone(false);
			newCase.Referral_Date__c=Date.today();
			newCase.Reason=null;
			newCase.Status='Re-Opened';
			newCase.ParentId=c.Id;			
			if(c.OwnerAtCaseClose__c!=null)
				newCase.OwnerId=c.OwnerAtCaseClose__r.Id;
			else
				newCase.OwnerId=c.OwnerId;			
			newCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cases-Reopen Referrals').getRecordTypeId();
			newCase.Date_of_Last_Report__c=null;
			newCase.OwnerAtCaseClose__c=null;
			//check to see if this case is the original case if so, set the value to it, otherwise clone will handle
			if(c.OriginalCase__c==null)
				newCase.OriginalCase__c=c.Id;		
			insert newCase;
			
			List<Surgery_Hospitalization__c> shList = new List<Surgery_Hospitalization__c>();
			Surgery_Hospitalization__c shClone;
			for(Surgery_Hospitalization__c sh : c.Surgeries_Hospitalizations__r)
			{
				shClone = sh.clone(false);
				shClone.Case__c=newCase.Id;
				shList.add(shClone);
			}
				
			if(shList.size()>0)
				insert shList;
			
			List<CaseContactRole> ccrList = new List<CaseContactRole>();
			CaseContactRole ccrClone;
			for(CaseContactRole ccr : c.CaseContactRoles)
			{
				ccrClone = ccr.clone(false);
				ccrClone.CasesId=newCase.Id;
				ccrList.add(ccrClone);
			}
			if(ccrList.size()>0)
				insert ccrList;
			List<Healthcare_Provider__c> hcpList = new List<Healthcare_Provider__c>();
			Healthcare_Provider__c hcpClone;
			for(Healthcare_Provider__c hcp : c.Other_Healthcare_Providers__r)	
			{
				hcpClone = hcp.clone(false);
				hcpClone.Case__c=newCase.Id;
				hcpList.add(hcpClone);
			}
			if(hcpList.size()>0)
				insert hcpList;
			CaseTeamMember ctm =null;			
			if(c.OwnerAtCaseClose__c!=null)
			{
				integer countOf = [SELECT COUNT() FROM CaseTeamMember WHERE ParentId=:c.Id AND MemberId=:c.OwnerAtCaseClose__c];
				if(countOf==0)
					ctm = new CaseTeamMember(MemberId=c.OwnerAtCaseClose__c,ParentId=c.Id,TeamRoleId=[SELECT Id From CaseTeamRole WHERE Name='Primary Case Manager'].Id);
			}
			
			if(ctm!=null)
				insert ctm;
			return new PageReference('/'+newCase.Id+'/e?retURL='+newCase.Id);
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This case already has a child case associated with it.'));
			return null;
		}
	}
	private boolean hasChild()
	{
		boolean hasChild=false;
		List<Case> cList = new List<Case>([SELECT Id FROM Case WHERE ParentId=:c.Id limit 1]);
		if(cList.size()>0)
			hasChild=true;
		return hasChild;
	}
}