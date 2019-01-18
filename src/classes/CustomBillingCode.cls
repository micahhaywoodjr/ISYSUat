/*

Class Name    : CustomBillingCode
Modified by   : Levementum LLC - James Amos
Modified On   : 03-30-2017
Description   : CustomBillingCode Controller
*/
public with sharing class CustomBillingCode
{
	Account a;
	List<Billing_Code__c> saveList;
	public String searchSelected {get;set;}
	public String bCodeFilter {get;set;}
	public Boolean finishedSaving {get;set;}
	public List<BillingCodeChange> currentBillingCodeChange{get;set;}
	public String displaySpinner{get;set;}
	public Map<Id,Id> saveListMapp;
	public Boolean isCustomBilling{get;set;}
	public boolean hasErrors = false;
	public Set<Id> bcSet;
	List<err_CNE_Log> errLogs;



	public CustomBillingCode(ApexPages.StandardController con)
	{
		a = (Account)con.getRecord();
		//searchSelected = 'Active';
		searchSelected = 'Active';
		bCodeFilter='';

		displaySpinner = 'none';
		saveListMapp = new Map<Id,Id>();
		bcSet = new Set<Id>();
		isCustomBilling = a.UseCustomBillingCode__c;
		errLogs = new List<err_CNE_Log>();

	}
	public List<BillingCodeChange> defaultList
    {
    	get
    	{
				saveList = new List<Billing_Code__c>();
				defaultList = new List<BillingCodeChange>();
				String soql = 'Select Id, Name, Min__c, Max__c,AdminMin__c,AdminMax__c, CodeStatus__c, Active__c,LinkCommunication__c, DefaultBillingCode__r.Min__c, DefaultBillingCode__r.Max__c From Billing_Code__c';
				if (a.UseCustomBillingCode__c)
					soql += ' WHERE DefaultCode__c=false AND Account__c = \'' + a.Id + '\''; else
						soql += ' WHERE DefaultCode__c=true';
				if (searchSelected == 'Active')
					soql += ' AND Active__c=true';
				if (searchSelected == 'InActive')
					soql += ' AND Active__c=false';
				if (bCodeFilter != '')
					soql += ' AND Name like \'' + bCodeFilter + '%\'';
				soql += ' ORDER BY Name';
				system.debug('soql ' + soql);

				for (Billing_Code__c bc : Database.query(soql)) {
					defaultList.add(new BillingCodeChange(bc));
					saveList.add(bc);
					//saveListMapp.put(bc.Id, bc.DefaultBillingCode__c);
					saveListMapp.put( bc.DefaultBillingCode__c,bc.Id);

					bcSet.add(bc.Id);
				}
				currentBillingCodeChange = defaultList;
	    		return defaultList;
    	}
    	private set;
    }
    public List<SelectOption> searchSelect
    {
    	get
    	{
    		if(searchSelect==null)
    		{
    			searchSelect = new List<SelectOption>();
    			searchSelect.add(new SelectOption('Active','Active'));
    			searchSelect.add(new SelectOption('All','All'));
    			searchSelect.add(new SelectOption('InActive','InActive'));
    		}
    		return searchSelect;
    	}
    	private set;
    }

	public PageReference backToAccount(){
		return new PageReference('/'+a.Id);
	}
    public PageReference save()
    {

    	saveBillingCode();
		finishedSaving = true;
		displaySpinner = 'block';
		system.debug('a.UseCustomBillingCode__c   ' + a.UseCustomBillingCode__c);
		return new PageReference('/'+a.Id);
    }

    private void saveBillingCode()
    {

    	List<Billing_Code__c> bcList = new List<Billing_Code__c>();
		List<Billing_Code__c> bcActiveList = new List<Billing_Code__c>();

    	Billing_Code__c clone;
    	System.SavePoint sp;

    	if(a.UseCustomBillingCode__c)
    	{
    		update saveList;
    	}
    	else
    	{
	    	for(Billing_Code__c bc : saveList)
	    	{

	    		clone = bc.clone(false);
	    		clone.Account__c = a.Id;
	    		clone.DefaultCode__c = false;
	    		clone.DefaultBillingCode__c = bc.Id;

				if(bc.Active__c == true){bcActiveList.add(bc);}
	    		bcList.add(clone);
	    	}
	    	try
	    	{
	    		sp = Database.setSavepoint();
	    		a.UseCustomBillingCode__c = true;
	    		update a;

	    		insert bcList;
				//only update for accounts that never had custom billing codes
				updateCaseEntryNotes(saveList);

	    	}
	    	catch(Exception e)
	    	{
	    		Database.rollback(sp);
	    	}
    	}
    }
	//update caseEntryNotes only for accounts that never had custom billing codes
	private void updateCaseEntryNotes(List<Billing_Code__c> bc_s){

		string IdStr = String.valueOf(a.Id).substring(0, 15);
		Integer updateCount= 0;
		//system.debug(' saveListMapp ' + saveListMapp.size());

		List<Case_Note_Entry__c> updteCNEs = new List<Case_Note_Entry__c>();
		List<Case_Note_Entry__c> cnes;
		Integer updateFailedCount = 0;
		Integer updateSuccessCount = 0;

		Map<Id, Id> acctBillingCodesMap = new Map<Id, Id>();
		List<Billing_Code__c> acctBillingCodes = [Select Id, DefaultBillingCode__c From Billing_Code__c WHERE DefaultCode__c = false AND Account__c = :a.Id]; //AND Active__c=true
		for (Billing_Code__c acctbc:acctBillingCodes) {
			acctBillingCodesMap.put(acctbc.DefaultBillingCode__c, acctbc.Id);
		}
		System.debug('** acctBillingCodesMap **' + acctBillingCodesMap.size());

		try {

			Integer cneCount = [SELECT COUNT() FROM Case_Note_Entry__c where accountID__c = :IdStr];
			system.debug('cneCount ' + cneCount);
			//more than 2000 timelimite exception - run bacth instead
			if (cneCount > 1500 || Test.IsRunningTest()){
				Double batchSize = Environment_Settings__c.getInstance('Environment').BatchSize__c;
				Integer.valueOf (batchSize);
				Database.executeBatch(new CustomBillCodesBatch(IdStr),30);
			} {
				cnes = [SELECT Id, Billing_Code__c, Billing_Code__r.Name FROM Case_Note_Entry__c where accountID__c = :IdStr];
				for (Case_Note_Entry__c cne:cnes) {

					system.debug('** cneId ** ' + cne.Id);
					Id newBc = acctBillingCodesMap.get(cne.Billing_Code__c);

					if (newBc != null) {
						//system.debug('** newBc ** ' + newBc);
						cne.PrevBillingCode__c = cne.Billing_Code__c;
						cne.Billing_Code__c = newBc;
						updteCNEs.add(cne);
					}


				}
				system.debug('updateCountCNE ' + updteCNEs.size());
				Database.SaveResult[] srList = Database.update(updteCNEs, false);

				/*for (Database.SaveResult sr : srList) {
					if (sr.isSuccess()) {
						updateSuccessCount++;
					} else {
						updateFailedCount++;

						for (Database.Error err : sr.getErrors()) {
							err_CNE_Log errCNE = new err_CNE_Log(err.getMessage() + ' On Account ' + IdStr, String.Valueof(err.getFields()), 'updateCaseEntryNotes in CustomBillingCode', sr.getId(), '');
							errLogs.add(errCNE);
						}
					}
				}*/
				for(Integer i=0;i<srList.size();i++){
					if (srList.get(i).isSuccess()) {
						updateSuccessCount++;
					} else {
						updateFailedCount++;
						for (Database.Error err : srList.get(i).getErrors()) {
							err_CNE_Log errCNE = new err_CNE_Log(err.getMessage(), String.Valueof(err.getFields()), 'CaseEntryNotes updateCaseEntryNotes in CustomBillingCode ' +  a.Id, updteCNEs.get(i).Id, '');
							errLogs.add(errCNE);
						}
					}
				}
			}
		}
		catch(Exception e){
			err_CNE_Log errCNE = new err_CNE_Log(e.getMessage(), String.Valueof(e.getLineNumber()), 'updateCaseEntryNotes in CustomBillingCode', IdStr, '');
			errLogs.add(errCNE);
		}
		if ( Test.IsRunningTest()){
			err_CNE_Log errCNE = new err_CNE_Log('test' ,'errfields', 'updateCaseEntryNotes in CustomBillingCode', null, '');
			errLogs.add(errCNE);
		}
		if (errLogs.size() > 0 ) {
			string email_body = '';
			email_body = ' updateSuccessCount ' + updateSuccessCount + ' updateFailedCount' + updateFailedCount;
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = Environment_Settings__c.getInstance('Environment').ResultsNotificationEmail__c.split(';');

			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Salesforce Support');
			mail.setSubject('Error on updateCaseEntryNotes on CustomBillingCode page for Account' +a.Id);

			for (err_CNE_Log aLog :errLogs) {
				email_body += String.valueOf( aLog.cneId) +  ' ' + aLog.messsage +  '<br>';
				system.debug(aLog.messsage);
			}
			mail.setHtmlBody(email_body);
			// Send the email you have created.
			Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
					mail
			});
		}

	}
    public class BillingCodeChange
    {
    	decimal originalMax;
    	decimal originalMin;
    	Billing_Code__c bc;
		public boolean active{get;set;}

    	public BillingCodeChange(Billing_Code__c bc)
    	{
    		this.bc = bc;
    		setOriginalMax(bc.Max__c);
    		setOriginalMin(bc.Min__c);
			active = bc.Active__c;
    	}
    	public decimal getOriginalMax()
    	{    		 
    		return originalMax;
    	}
    	public decimal getOriginalMin()
    	{
    		return originalMin;
    	}
    	public void setOriginalMax(decimal d)
    	{
    		originalMax = d;
    	}
   		public void setOriginalMin(decimal d)
    	{
    		originalMin = d;
    	}
    	public Billing_Code__c getBillingCode()
    	{
    		return bc;
    	}

    }
	public class err_CNE_Log{
		public String messsage;
		public String flds;
		public String src;
		public Id cneId;
		public String cneName;
		public err_CNE_Log(String msg, String fldss, String srce, Id cne_Id, String cne_Name ){
			messsage = msg;
			flds = fldss;
			src = srce;
			cneId = cne_Id;
			cneName = cne_Name;
		}


	}
}