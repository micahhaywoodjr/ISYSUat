public class bulkNoteAddController {
    private final Set<string> RUSH_RATE_NOT_ALLOWED_PROFILES = new Set<String>{'Custom - Nurse'};
    private final integer PAGE_SIZE = 10;
    
    /* AJAX Support Properties*/
    public string selectedBillingCodeId {get;set;}
    public integer currentCaseNoteIndex {get;set;}
    
    public boolean showPageNavigation {
   		get {
   			return caseNotes.size() > PAGE_SIZE;
   		}
   	}
   	
   	public boolean allowMovePrev {
   		get {
   			return pageIndex != 0;
   		}
   	}
   	
   	public boolean allowMoveNext {
   		get {
   			integer nextStartIndex = (pageIndex + 1) * PAGE_SIZE;
   			return caseNotes.size() >= nextStartIndex;
   		}
   	}   
   	
   	public List<CaseNoteItem> pageData {
   		get {
   			if (caseNotes.size() <= PAGE_SIZE) {
   				return caseNotes;
   			}
   			else {
	   			List<CaseNoteItem> data = new List<CaseNoteItem>();

	   			integer bookmark = pageIndex * PAGE_SIZE;
	   			integer remaining = caseNotes.size() - bookmark;
	   			integer max = bookmark + PAGE_SIZE;
	   			
	   			for (integer i = bookmark; i < max; i++) {
	   				if (i >= caseNotes.size()) break;
	   				data.add(caseNotes[i]);	
	   			}
	   			
	   			return data;
   			}
   		}
   	}
   	
    /* Properties */
    public Opportunity parentOpportunity {get;set;}
    public List<CaseNoteItem> caseNotes {get;set;}
    public List<SelectOption> billingCodeOptions {get;set;}
    public boolean editMode {get; set;}
    public boolean auditMode {get; set;}
   	public integer pageIndex {get;set;}
   	public boolean allowRush {get;set;}
   	public string subtitle {get;set;}
   	public boolean hasEntries {get;set;}
   	public boolean allowSaveAndApprove {get;set;}
   	
   	public bulkNoteAddController() {
    	//Initialize
    	parentOpportunity = new Opportunity();
    	caseNotes = new List<CaseNoteItem>();
    	billingCodeOptions = new List<SelectOption>();
    	pageIndex = 0;
    	allowRush = false;
    	selectedBillingCodeId = null;
    	currentCaseNoteIndex = -1;
    	hasEntries = false;
    	allowSaveAndApprove = false;
    	
    	auditMode = getURLParamById('audit', '0') == '1' ? true : false;
		editMode = getURLParamById('edit', '0') == '1' ? true : false;
    	
    	allowSaveAndApprove = auditMode;
    	
    	if (auditMode && editMode) {
    		subtitle = 'Audit Case Note Entries';
    	}
    	else if (editMode && !auditMode) {
    		subtitle = 'Edit Case Note Entries';
    	}
    	else {
    		subtitle = 'Add Case Note Entries';
    	}
    	
    	//Lookup parent opportunity
    	Id opportunityId = getURLParamById('id',null);
    	if (opportunityId != null) {
    		List<Opportunity> results = [SELECT Id, Name FROM Opportunity WHERE Id =:opportunityId];
    		if (!results.isEmpty()) {
    			parentOpportunity = results[0];
    		}	
    	}
    	
    	//Build Billing Code Options
    	billingCodeOptions = buildBillingCodeSelectOptions();
    	
    	//Retrieve Case Notes
    	if (parentOpportunity.Id != null) {
    		if (editMode) {
    			caseNotes = retrieveCaseNoteItems(parentOpportunity.Id);
    		}
    		else {
    			caseNotes = buildNewCaseNoteItems(PAGE_SIZE);
    		}
    	}
    	
    	hasEntries = !caseNotes.isEmpty();
    	
    	//Determine rush rate permissions
		List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id=:UserInfo.getProfileId() AND Name NOT IN :RUSH_RATE_NOT_ALLOWED_PROFILES];
		allowRush = !profiles.isEmpty();
    }
    
   	public PageReference billingCodeChanged() {
   		try {
	   		if (currentCaseNoteIndex >= 0 && selectedBillingCodeId != null) {
	   			CaseNoteItem item = caseNotes[currentCaseNoteIndex];
	   			item.showMinMaxValues = false;
	   			
	   			if (selectedBillingCodeId.length() > 0) {
		   			Billing_Code__c code = retrieveBillingCode(selectedBillingCodeId);
		   			if (code.Id != null) {
		   				item.showMinMaxValues = true;
		   				item.billingMin = code.Min__c;
		   				item.billingMax = code.Max__c;
		   			}
	   			}
	   		}
   		}
   		catch (Exception ex) {
   			ApexPages.addMessages(ex);
   		}
   		
   		return null;
   	}
   	
   	public PageReference addNotes() {
   		PageReference addRef = null;
   		
   		try {
   			string params = '?id=' + parentOpportunity.Id;
   			if (auditMode) {
   				params += '&audit=1';
   			}
	   			
   			addRef = new PageReference('/apex/bulkNoteAdd' + params);
   			addRef.setRedirect(true);
   		}
   		catch( Exception ex ) {
        	ApexPages.addMessages(ex);
        }
       
        return addRef;
   	}
   	
    public PageReference save() {
    	PageReference saveRef = null;
    	try {
	        Case_Note_Entry__c[] to_add = new Case_Note_Entry__c[] {};
	       	
	       	boolean hasErrors = false;
	       	
	        for( CaseNoteItem item : caseNotes ) {
	        	Case_Note_Entry__c tmp = item.entry;
	        	
	            if( tmp.Billing_Code__c != null) {
	            	to_add.add( tmp );
	            
		            if (tmp.Activity_Date__c == null) {
		            	tmp.Activity_Date__c.addError('Activity Date is required.');
		            	hasErrors = true;
		            }
	            }
	        }
	        
	        if (!hasErrors) {
	            upsert to_add;
		        
		        saveRef = new pageReference('/'+ parentOpportunity.Id);
		        saveRef.setredirect(true);
	        }
        } 
        catch( Exception ex ) {
        	ApexPages.addMessages(ex);
        }
       
        return saveRef; 
    }
   
   	public PageReference saveNew() {
   		PageReference saveRef = null;
   		
   		try {
   			saveRef = save();
	   		
	   		if (saveRef != null) {
	   			string params = '?id=' + parentOpportunity.Id;
	   			if (auditMode) {
	   				params += '&audit=1';
	   			}
	   			
	   			saveRef = new PageReference('/apex/bulkNoteAdd' + params);
	   			saveRef.setRedirect(true);
	   		}
   		}
   		catch( Exception ex ) {
        	ApexPages.addMessages(ex);
        }
       
        return saveRef; 
   	}
   	public PageReference saveApprove() {
   		PageReference saveRef = null;
   		
   		try {
   			saveRef = save();
	   		
	   		if (saveRef != null) {
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
													AND ProcessInstance.TargetObjectId =: parentOpportunity.Id
													AND ActorId =: UserInfo.getUserId() 
												ORDER BY
													SystemModStamp desc];
				if (!workItems.isEmpty()) {
	   				ProcessInstanceWorkitem workitem = workitems[0];
	   				saveRef = new PageReference('/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workitem.Id);
	   				saveRef.setRedirect(true);
				}
	   		}
   		}
   		catch( Exception ex ) {
        	ApexPages.addMessages(ex);
        }
       
        return saveRef; 
   	}
    public PageReference cancel() {
    	PageReference cancelRef = null;
    	
    	try {
    		if (parentOpportunity.Id != null) {
    			cancelRef = new PageReference('/' + parentOpportunity.Id);
    			cancelRef.setRedirect(true);	
    		} 
    	}
    	catch (Exception ex) {
    		ApexPages.addMessages(ex);
    	}
    	
    	return cancelRef;
    }
    
    public PageReference movePrev() {
    	try {
    		pageIndex = pageIndex == 0 ? 0 : pageIndex - 1;
    	}
    	catch (Exception ex) {
    		ApexPages.addMessages(ex);
    	}    
    	
    	return null;
    }
    
    public PageReference moveNext() {
	    try {
	    	pageIndex++;
    	}
    	catch (Exception ex) {
    		ApexPages.addMessages(ex);
    	}
    	
    	return null;
    }
    
    private List<SelectOption> buildBillingCodeSelectOptions() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('','–None–'));
    	
    	List<Billing_Code__c> codes = retrieveBillingCodes();
    	for (Billing_Code__c code : codes) {
    		options.add(new SelectOption(code.Id,code.Name)); 	
    	}
    	
    	return options;	
    }
    
    private Billing_Code__c retrieveBillingCode(Id billingCodeId) {
    	Billing_Code__c code = new Billing_Code__c();
    	
    	List<Billing_Code__c> codes =[SELECT Id, Name, Min__c, Max__c FROM Billing_Code__c WHERE Id =: billingCodeId];
    	if (!codes.isEmpty()) {
    		code = codes[0];
    	}
    	
    	return code;
    }
    
    private List<Billing_Code__c> retrieveBillingCodes() {
    	List<Billing_Code__c> codes =[SELECT Id, Name, Min__c, Max__c FROM Billing_Code__c ORDER BY Name];
    	
    	return codes;
    }
    
    private List<CaseNoteItem> buildNewCaseNoteItems(integer count) {
    	List<CaseNoteItem> notes = new List<CaseNoteItem>();
    	
    	for (integer i=0; i < count; i++) {
    		CaseNoteItem item = new CaseNoteItem();
    		item.rowIndex = i;
    		item.entry = new Case_Note_Entry__c();
    		item.entry.Report__c = parentOpportunity.Id;
    		
    		notes.add(item);	
    	}
    	
    	return notes;
    }
    private List<CaseNoteItem> retrieveCaseNoteItems(Id opportunityId) {
    	List<CaseNoteItem> notes = new List<CaseNoteItem>();
    	
    	List<Case_Note_Entry__c> data = [SELECT Id, 
    		Expenses__c,
			Mileage__c,
			Billing_Code__c,
			Driving_From_City__c,
			Professional_Hours__c,
			Driving_To_City__c,
			Report__c,
			Adj_Professional_Hours__c,
			Adj_Travel_Wait_Hours__c,
			Adj_Expenses__c,
			Adj_Mileage__c,
			Travel_Wait_Hours__c,
			Activity_Date__c,
			Work_Description__c,
			Rush__c,
			Billing_Code__r.Min__c,
			Billing_Code__r.Max__c,
			Expenses_Nurse__c,
			Professional_Hours_Nurse__c,
			Mileage_Nurse__c,
			Travel_Wait_Hours_Nurse__c
    		FROM Case_Note_Entry__c WHERE Report__c =:opportunityId ORDER BY Activity_Date__c];
    		
    	if (!data.isEmpty()) {
    		integer index = 0;
    		
    		for (Case_Note_Entry__c note : data) {
    			CaseNoteItem item = new CaseNoteItem();
    			item.entry = note;
    			item.rowIndex = index++;
    			
    			if (note.Billing_Code__c != null) {
    				item.showMinMaxValues = true;
    				item.billingMin = note.Billing_Code__r.Min__c;
    				item.billingMax = note.Billing_Code__r.Max__c;
    			}
    			
    			if (editMode && !auditMode) {
    				boolean exclude = note.Expenses_Nurse__c == null 
    					&& note.Professional_Hours_Nurse__c == null
    					&& note.Mileage_Nurse__c == null
    					&& note.Travel_Wait_Hours_Nurse__c == null;
    				
    				if (!exclude) notes.add(item);
    			}
    			else {
    				notes.add(item);
    			}
    		}
    	}
    	return notes;
    }
    
    private String getURLParamById(String paramId, String defaultValue) {
        if (ApexPages.currentPage().getParameters() == null) {
            return defaultValue;
        } else {
            String value = ApexPages.currentPage().getParameters().get(paramId);
            return (value == null) ? defaultValue : value; 
        }
    }

}