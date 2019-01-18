public with sharing class addCaseNoteEntries
{
    private String sOppID;
    public List<Case_Note_Entry__c> lstCNE;
    public List<wrapperCNE> lstWrapCNE{get;set;}
    public Case_Note_Entry__c oCNE{get;set;}
    public Opportunity objOpp{get;set;}
    public String sUserFullName{get;set;}
    public Boolean bNotNurse{get;set;}
    public Integer iColCount{get;set;}
    //public Boolean bFirstView{get;set;} //added by RT
    public User objUser{get;set;}
    private String sProfId = Userinfo.getProfileId();
    String sUserId = Userinfo.getUserId();
    public Boolean isAdmin {get; set;}
    private boolean useCustomBillingCode=false;
    private Id accountId;

    /* AJAX Support Properties*/
    public string selectedBillingCodeId {get;set;}
    public integer currentCaseNoteIndex {get;set;}


    Map<String,Set<String>> billingProfileMap {get;set;}

    private List<Profile> objP;

    private Boolean doValidation {get;set;}

    public String getListOfCodes(){
        String s = '';
        for(Billing_Code__c bc : [SELECT Name FROM BIlling_Code__c WHERE LinkCommunication__c = true and Account__c = :accountId])
            s += bc.Name;
        return s;
    }

    public Map<String,String> getUniqueBillingCodes(){
        Map<String,String> uniqueCodes = new Map<String,String>();
        for(Billing_Code__c bc : [SELECT Id,Name FROM BIlling_Code__c WHERE LinkCommunication__c = true and Account__c = :accountId])
            uniqueCodes.put(bc.Id,bc.Name);

        return uniqueCodes;

    }

    public Boolean getReturnTrueIfNurse()
    {
        bNotNurse = null;
        if(bNotNurse==null)
        {
            system.debug('----------1.---------AJAY------------Profile Id---------'+sProfId);

            Boolean bRes = false;
            if(objP!=null && objP.size()>0)
            {
                system.debug('----------2.---------AJAY------------NURSE---------'+objP[0].Id);
                if(sProfId == objP[0].Id)
                    bRes = true;
                if(objP.size()>1)
                {
                    if(sProfId ==  objP[1].Id)
                        bRes = true;
                }
            }
            system.debug('----------3.---------AJAY------------return Val ---------'+bRes);
            return bRes;
        }
        else
            return bNotNurse;
    }


    //AWILKINSON 4-27-2015 Map to filter billing codes by profile.
    public void getBillingProfileMap(){
        billingProfileMap = new Map<String,Set<String>>();

        for(BillingCodeProfileAccess__c b : BillingCodeProfileAccess__c.getAll().values()){
            if(!billingProfileMap.containsKey(b.ProfileId__c)){
                billingProfileMap.put(b.ProfileId__c,new Set<String>{b.BillingCode__c});
            }
            else
                billingProfileMap.get(b.ProfileId__c).add(b.BillingCode__c);
        }
    }

    public addCaseNoteEntries()
    {
        sUserFullName = Userinfo.getUserName();
        objP = new List<Profile>([SELECT ID FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse']);

        if(getReturnTrueIfNurse())
        {
            iColCount = 5;
            bNotNurse = true;
        }
        else
        {
            iColCount = 9;
            bNotNurse = false;
        }

        if(objP!=null && objP.size()>0)
        {
            if(sProfId ==  objP[0].Id)
            {
                iColCount = 5;
                bNotNurse = false;
            }
            else
            {
                if(objP.size()>1)
                {
                    if(sProfId ==  objP[1].Id)
                    {
                        iColCount = 5;
                        bNotNurse = false;
                    }
                }
            }
        }

        List<Case_Note_Entry__c> lstCNE = new List<Case_Note_Entry__c>();

        if(ApexPages.currentPage().getParameters().get('Id')!=null && ApexPages.currentPage().getParameters().get('Id')!='')
        {
            sOppID = ApexPages.currentPage().getParameters().get('Id');
            oCNE = new Case_Note_Entry__c();
            Integer iTotalRec = 200;
            objOpp = [SELECT Name, Account.UseCustomBillingCode__c, AccountId, Account.Name, Service_Date_From__c, Service_Date_Thru__c,
                      Related_Case__r.CaseNumber, Employee__c,Related_Case__c From Opportunity WHERE Id =: sOppID];
            useCustomBillingCode=objOpp.Account.UseCustomBillingCode__c;
            accountId=objOpp.AccountId;
            system.debug('----Ajay----'+objOpp);
            if(ApexPages.currentPage().getParameters().get('RecAdd')!=null && ApexPages.currentPage().getParameters().get('RecAdd')!='')
            {
                iTotalRec = Integer.ValueOf(ApexPages.currentPage().getParameters().get('RecAdd'));
            }
            for(Integer i = 0 ; i < iTotalRec ; i++)
            {
                oCNE = new Case_Note_Entry__c();
                oCNE.Report__c = sOppId;
                oCNE.Activity_Date__c = null;
                lstCNE.add(oCNE);
            }
            WrapCNE(lstCNE);
        }
        getBillingProfileMap();
        doValidation = false;

        getRelatedRecords();
        checkAdmin();
    }
    public void checkAdmin()
    {
        try
        {
            Id adminProf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            if(sProfId == adminProf)
            {
                isAdmin = true;
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage() + ' in line '+ e.getLineNumber());
        }
    }
    private void WrapCNE(List<Case_Note_Entry__c> lstC)
    {
        List<wrapperCNE> tmpLST = new List<wrapperCNE>();
        Integer i = 0;
        if(lstC!=null && lstC.size()>0)
        {
            for(Case_Note_Entry__c oCN : lstC)
            {
                wrapperCNE oWCNE = new wrapperCNE(oCN, sUserFullName, getReturnTrueIfNurse());
                oWCNE.rowIndex = i;
                tmpLST.add(oWCNE);
                i++;
            }
        }
        lstWrapCNE = tmpLST;
    }


    public List<SelectOption> getBillingCodeAndFill()
    {
        Set<String> billingCodesToHide = billingProfileMap.get(UserInfo.getProfileId().subString(0,15));
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','None'));
        List<Billing_Code__c> codes = retrieveBillingCodes();
        for (Billing_Code__c code : codes) {
            if(billingCodesToHide == null || !billingCodesToHide.contains(code.Name))
                options.add(new SelectOption(code.Id,code.Name));
        }
        return options;
    }

    private List<Billing_Code__c> retrieveBillingCodes()
    {
        //List<Billing_Code__c> codes =[SELECT Id, Name, Min__c, Max__c FROM Billing_Code__c WHERE Active__c = TRUE ORDER BY Name];
        //return codes;

        List<Billing_Code__c> codes;
        if(useCustomBillingCode)
            codes = new List<Billing_Code__c>([SELECT Id, Name, AdminMax__c, AdminMin__c, Min__c, Max__c FROM Billing_Code__c WHERE Active__c=true AND DefaultCode__c=false AND Account__c=:accountId ORDER BY Name]);
            else
                codes = new List<Billing_Code__c>([SELECT Id, Name, AdminMax__c, AdminMin__c, Min__c, Max__c FROM Billing_Code__c WHERE Active__c=true AND DefaultCode__c=true ORDER BY Name]);
                return codes;
    }
    @TestVisible
    private Billing_Code__c retrieveBillingCode(Id billingCodeId) {
        system.debug('------billingCodeId-------'+billingCodeId);
        Billing_Code__c code = new Billing_Code__c();

        List<Billing_Code__c> codes =[SELECT LinkCommunication__c,Id, Name, AdminMax__c, AdminMin__c,  Min__c, Max__c FROM Billing_Code__c WHERE Id =: billingCodeId AND Active__c = TRUE];
        if (!codes.isEmpty()) {
            code = codes[0];
        }

        return code;
    }

    public PageReference billingCodeChanged() {
        try {

            if (currentCaseNoteIndex >= 0 && selectedBillingCodeId != null) {
                wrapperCNE item = lstWrapCNE[currentCaseNoteIndex];
                item.showMinMaxValues = false;
                item.renderCommunications = false;
                if (selectedBillingCodeId.length() > 0) {
                    Billing_Code__c code = retrieveBillingCode(selectedBillingCodeId);
                    if (code.Id != null) {
                        item.showMinMaxValues = true;
                        item.billingMin = String.ValueOf(code.Min__c);
                        item.billingMax = String.ValueOf(code.Max__c);
                        item.adminBillingMin = String.ValueOf(code.AdminMin__c);
                        item.adminBillingMax = String.ValueOf(code.AdminMax__c);
                        if(item.adminBillingMin != null)
                        {
                            item.adminBillingMin += ' (B)';
                        }
                        if(item.adminBillingMax != null)
                        {
                            item.adminBillingMax += ' (B)';
                        }
                        if(code.LinkCommunication__c == true)
                            item.renderCommunications = true;
                    }
                }
            }
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }

        return null;
    }
    /*
    public class wrapperCNE
    {
        public Boolean bShowCheck{get;set;}
        public Boolean bShowCheckValue{get;set;}
        public Case_Note_Entry__c objCNE{get;set;}
        public wrapperCNE(Case_Note_Entry__c oCNE, String sUserFullName)
        {
            objCNE = oCNE;
            string strTmpUser = '';
            if(oCNE.CreatedBy.Name!=null)
              strTmpUser = oCNE.CreatedBy.Name;
            if(oCNE.Report__r.Submitted__c)// || String.ValueOf(strTmpUser).ToUpperCase() != String.ValueOf(sUserFullName).toUpperCase())
                bShowCheck = false;
            else
                bShowCheck = true;
            //bShowCheck = true;
            bShowCheckValue = false;
        }
    }*/

    public PageReference SaveCaseNoteEntry(){
        Case_Note_Entry__c oCNE;
        List<Case_Note_Entry__c> lstOCne = new List<Case_Note_Entry__c>();
        List<wrapperCNE> lstLocalCNE = new List<wrapperCNE>();
        Boolean bValidateWorkDesc = false;
        Map<String,String> codeSet = getUniqueBillingCodes();
        if(lstWrapCNE!=null && lstWrapCNE.size()>0)
        {
            for(wrapperCNE oWCne : lstWrapCNE)
            {

                if(oWCne.objCNE.Activity_Date__c!=null && oWCne.objCNE.Billing_Code__c!=null)
                {
                    if(oWCne.objCNE.Work_Description__c==null || oWCne.objCNE.Work_Description__c=='')
                    {
                        bValidateWorkDesc = true;
                        break;
                    }
                    else
                        lstOCne.add(oWCne.objCNE);
                }
            }
        }
        if(bValidateWorkDesc)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide detailed activity in the Case Note Description box.'));
            return null;
        }
        if(lstOCne.size()>0)
        {
            try{
                insert lstOCne;
            }catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }

            PageReference p ;
            if(getReturnTrueIfNurse())
                p = Page.viewNurseCaseNoteEntries;
            else
                p = Page.viewCaseNoteEntries;
            p.getParameters().put('Id', sOppID);
            p.setRedirect(true);
            return p;
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Nothing to save'));
            return null;
        }
    }
    public PageReference Cancel(){

        PageReference p;
        /*if(bFirstView)
            p = new PageReference('/'+sOppID);
        else*/
        {

            Boolean bRes = false;
            if(objP!=null && objP.size()>0)
            {
                if(sProfId == objP[0].Id)
                    bRes = true;
                else
                {
                    if(objP.size()>1)
                    {
                        if(sProfId ==  objP[1].Id)
                            bRes = true;
                    }
                }
            }
            if(bRes) {
                p = Page.viewNurseCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            }
            else {
                p = Page.viewCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            }
        }
        p.setRedirect(true);
        return p;

        /*PageReference p = Page.viewCaseNoteEntries;
        p.getParameters().put('Id', sOppID);
        p.setRedirect(true);
        return p;*/
    }


    public Boolean showCommunicationPopup {get;set;}
    public wrapperCNE selectedWrapperCNE {get;set;}
    public String selectedWrapperCNEId {get;set;}

    public void getCommunicationHistory(){
        showCommunicationPopup = true;
        if(selectedWrapperCNEId == null)
            return;

        for(wrapperCNE oWCne : lstWrapCNE)
        {
            if(selectedWrapperCNEId == String.valueOf(oWCne.rowIndex))
                selectedWrapperCNE = oWCne;
        }

        selectedWrapperCNE.addCommunicationHistoryInfo(objOpp.Related_Case__c);

    }

    public void closePopup(){
        showCommunicationPopup = false;
    }

    public void setCommunicationPopup(){
        for(wrapperCNE oWCne : lstWrapCNE)
        {
            if(selectedWrapperCNEId != null && selectedWrapperCNEId == String.valueOf(oWCne.rowIndex)){
                selectedWrapperCne.setCommunicationValues();
                /*if(selectedWrapperCNE.selectedTaskId != null && selectedWrapperCNE.selectedTaskId != '')
                    OwCne.objCNE.RelatedCommunicationHistories__c = selectedWrapperCne.objCNE.RelatedCommunicationHistories__c;
                OwCne.objCNE.RelatedAttachments__c = selectedWrapperCne.objCNE.RelatedAttachments__c;*/
            }

        }

        showCommunicationPopup = false;
    }

    public transient List<RelateCommunicatonHistoryController.TaskWrapper1> availableCommunicationHistories {get;set;}
    public transient List<RelateCommunicatonHistoryController.AttachmentWrapper1> availableAttachments {get;set;}



    public void getRelatedRecords(){
        availableCommunicationHistories = new List<RelateCommunicatonHistoryController.TaskWrapper1>();
        if(objOpp.Related_Case__c == null)
            return;

        for(Task t : [SELECT Description,Id,Subject,Type,CreatedDate,LastModifiedDate,ActivityDate FROM Task WHERE WhatId = :objOpp.Related_Case__c ORDER BY ActivityDate DESC LIMIT 350]){
            availableCommunicationHistories.add(new RelateCommunicatonHistoryController.TaskWrapper1(t));
        }

        getAvailableAttachments();

    }

    public void getAvailableAttachments(){
        if(objOpp.Related_Case__c == null)
            return;

        availableAttachments = new List<RelateCommunicatonHistoryController.AttachmentWrapper1>();

        for(Attachment a : [SELECT Description,OwnerId,Id,Name,ContentType,CreatedDate,LastModifiedDate FROM Attachment WHERE ParentId = :objOpp.Related_Case__c ORDER BY LastModifiedDate DESC LIMIT 900]){
            availableAttachments.add(new RelateCommunicatonHistoryController.AttachmentWrapper1(a));
        }

    }
}