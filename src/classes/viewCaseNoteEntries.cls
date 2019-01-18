global class viewCaseNoteEntries {
    private String sOppID;
    public List<Case_Note_Entry__c> lstCNE;
    public wrapperCNE objWrapCNE { get; set; }

    public List<wrapperCNE> lstWrapCNE { get; set; }
    public Case_Note_Entry__c oCNE { get; set; }

    public List<Opportunity> objOpps { get; private set; }

    private String sUserFullName;
    public Boolean bNotNurse { get; set; }
    public Integer iColCount { get; set; }
    private String sProfId = Userinfo.getProfileId();
    public Boolean isAdmin { get; set; }
    public Boolean bFirstView { get; set; }
    public Boolean bOpportunitySubmitted { get; set; }
    public String strSortBy { get; set; }
    public Integer iRecordAdd { get; set; }
    public Integer iRecordAddBot { get; set; }

    public Boolean bOppUnLock { get; set; }
    public Boolean RocordsFound { get; set; }
    /* AJAX Properties*/
    public string selectedBillingCodeId { get; set; }
    public integer currentCaseNoteIndex { get; set; }
    //added the next two fields for pagination purposes:
    public boolean hasPrevious { get; set; }
    public boolean hasNext { get; set; }

    public Opportunity objOpportunity { get; set; }

    private String sortDirection = 'ASC';
    private String sortExp = 'Activity_Date__c';

    private boolean useCustomBillingCode = false;
    private Id accountId;


    @TestVisible private Boolean doValidation { get; set; }

    public String getListOfCodes() {
        String s = '';
        for (Billing_Code__c bc : [SELECT Name FROM BIlling_Code__c WHERE LinkCommunication__c = true and Account__c = :accountId])
            s += bc.Name;
        return s;
    }

    public Map<String, String> getUniqueBillingCodes() {
        Map<String, String> uniqueCodes = new Map<String, String>();
        for (Billing_Code__c bc : [SELECT Id, Name FROM BIlling_Code__c WHERE LinkCommunication__c = true and Account__c = :accountId])
            uniqueCodes.put(bc.Id, bc.Name);

        return uniqueCodes;

    }

    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC'; else
                    sortDirection = 'ASC';
            sortExp = value;
        }
    }

    public String getSortDirection() {
        //if not column is selected
        if (sortExpression == null || sortExpression == '')
            return 'ASC'; else
                return sortDirection;
    }

    public void setSortDirection(String value) {
        sortDirection = value;
    }

    public PageReference redirectToPage() {
        sUserFullName = Userinfo.getUserName();
        String sProfId = Userinfo.getProfileId();
        String sUserId = Userinfo.getUserId();
        Boolean bRes = false;
        List<Profile> objP = authNurseProfile.objP;//[SELECT ID FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse'];
        if (objP != null && objP.size() > 0) {
            if (sProfId == objP[0].Id)
                bRes = true; else {
                if (objP.size() > 1) {
                    if (sProfId == objP[1].Id)
                        bRes = true;
                }
            }
        }
        PageReference pRedirect;
        if (ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != '') {
            sOppID = ApexPages.currentPage().getParameters().get('Id');
            if (bRes)
                pRedirect = new PageReference('/apex/viewNurseCaseNoteEntries?Id=' + sOppID); else
                    pRedirect = new PageReference('/apex/viewCaseNoteEntries?Id=' + sOppID);
            pRedirect.setRedirect(true);
        }
        return pRedirect;
    }
    public Boolean getReturnTrueIfNurse() {
        sUserFullName = Userinfo.getUserName();
        String sProfId = Userinfo.getProfileId();
        String sUserId = Userinfo.getUserId();
        Boolean bRes = false;
        List<Profile> objP = authNurseProfile.objP;//[SELECT ID FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse'];
        if (objP != null && objP.size() > 0) {
            if (sProfId == objP[0].Id)
                bRes = true; else {
                if (objP.size() > 1) {
                    if (sProfId == objP[1].Id)
                        bRes = true;
                }
            }
        }
        return bRes;
    }

    private void init() {
        if (getReturnTrueIfNurse()) {
            iColCount = 5;
            bNotNurse = true;
        } else {
            iColCount = 9;
            bNotNurse = false;
        }
        bFirstView = true;
        List<Case_Note_Entry__c> lstCNE = new List<Case_Note_Entry__c>();
        oCNE = new Case_Note_Entry__c();
        if (ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != '') {
            sOppID = ApexPages.currentPage().getParameters().get('Id');
            //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: removed the query with the limit 200 and added this one below:
            String query = 'SELECT Id, Expenses__c, Mileage__c, Billing_Code__c,Billing_Code__r.LinkCommunication__c, Driving_From_City__c, Professional_Hours__c, Driving_To_City__c, Report__c, Adj_Professional_Hours__c, Adj_Travel_Wait_Hours__c, Adj_Expenses__c, Adj_Mileage__c, Travel_Wait_Hours__c, Activity_Date__c, Work_Description__c, Rush__c, Billing_Code__r.AdminMax__c, Billing_Code__r.AdminMin__c, Billing_Code__r.Min__c, Billing_Code__r.Max__c, Expenses_Nurse__c, Professional_Hours_Nurse__c, Mileage_Nurse__c, Travel_Wait_Hours_Nurse__c, CreatedBy.Name, CreatedById, Report__r.Submitted__c, Report__r.A_Notes_Approved__c, Report__r.B_Notes_Approved__c, Billing_Code__r.Name, Report__r.Report_Submission_Date__c,Report__r.Approval_Status__c, CreatedBy.ProfileId, Report__r.OwnerId, Report__r.Name, Report__r.AccountId, Report__r.Service_Date_From__c, Report__r.Service_Date_Thru__c, Report__r.Related_Case__c,RelatedCommunicationHistories__c,RelatedAttachments__c, Report__r.Related_Case__r.CaseNumber, Report__r.Account.Name, Report__r.Report_Name__c, Report__r.Employee__c FROM Case_Note_Entry__c WHERE Report__c =:sOppID ORDER BY Activity_Date__c asc, CreatedBy.Name';
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            setCon.setPageSize(100);
            hasPrevious = setCon.getHasPrevious();
            hasNext = setCon.getHasNext();
        }

        if (ApexPages.currentPage().getParameters().get('SelIds') != null && ApexPages.currentPage().getParameters().get('SelIds') != '') {
            String strSelIds = ApexPages.currentPage().getParameters().get('SelIds');
            List<String> setSelIds = strSelIds.split(',');
            if (setSelIds != null && setSelIds.size() > 0) {
                //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: removed the query with the limit 200 and added this one below:
                String query1 = 'SELECT Id, Expenses__c, Mileage__c, Billing_Code__c,Billing_Code__r.LinkCommunication__c, Driving_From_City__c, Professional_Hours__c, Driving_To_City__c, Report__c, Adj_Professional_Hours__c, Adj_Travel_Wait_Hours__c, Adj_Expenses__c, Adj_Mileage__c, Travel_Wait_Hours__c, Activity_Date__c, Work_Description__c, Rush__c,Billing_Code__r.AdminMax__c, Billing_Code__r.AdminMin__c,  Billing_Code__r.Min__c, Billing_Code__r.Max__c, Expenses_Nurse__c, Professional_Hours_Nurse__c, Mileage_Nurse__c, Travel_Wait_Hours_Nurse__c, CreatedBy.Name, CreatedById, Report__r.Submitted__c, Report__r.A_Notes_Approved__c, Report__r.B_Notes_Approved__c, Billing_Code__r.Name, Report__r.Name, Report__r.AccountId, Report__r.Account.Name, Report__r.Report_Name__c, Report__r.Employee__c, CreatedBy.ProfileId, Report__r.OwnerId, Report__r.Report_Submission_Date__c, Report__r.Service_Date_From__c, Report__r.Service_Date_Thru__c, Report__r.Related_Case__c,RelatedCommunicationHistories__c,RelatedAttachments__c, Report__r.Related_Case__r.CaseNumber, Report__r.Approval_Status__c FROM Case_Note_Entry__c WHERE Id in : setSelIds ORDER BY Activity_Date__c asc, CreatedBy.Name';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query1));
                setCon.setPageSize(100);
                hasPrevious = setCon.getHasPrevious();
                hasNext = setCon.getHasNext();
                if (ApexPages.currentPage().getParameters().get('strOppId') != null && ApexPages.currentPage().getParameters().get('strOppId') != '') {
                    sOppID = ApexPages.currentPage().getParameters().get('strOppId');
                }
            }
        }


        if (sOppID != null)
            objOpps = new List<Opportunity>([
                    SELECT Id, AccountId, Account.UseCustomBillingCode__c, Approval_Status__c, Related_Case__c, Submitted__c, A_Notes_Approved__c, B_Notes_Approved__c, Amount_Locked__c,
                            Report_Submission_Date__c
                    FROM Opportunity
                    WHERE (Id = :sOppID)
            ]);

        if (objOpps.size() > 0) {// Do all the work that needs to be done based on the Opportunity
            if (objOpps[0].Submitted__c || objOpps[0].Report_Submission_Date__c != null)// || String.ValueOf(strTmpUser).ToUpperCase() != String.ValueOf(sUserFullName).toUpperCase())
                bOppUnLock = false; else
                    bOppUnLock = true;

            if (bOppUnLock) {
                if (objOpps[0].Amount_Locked__c)
                    bOppUnLock = false;
            }
            useCustomBillingCode = objOpps[0].Account.UseCustomBillingCode__c;
            accountId = objOpps[0].AccountId;
        }

        if (lstCNE != null && lstCNE.size() > 0)
            RocordsFound = true; else {
            objOpportunity = [
                    Select Id, Name, Approval_Status__c, AccountId, Account.Name, Related_Case__c, Related_Case__r.Employee__c, Related_Case__r.CaseNumber, Related_Case__r.Employee__r.Id,
                            Service_Date_From__c, Service_Date_Thru__c, Related_Case__r.Employee__r.Name
                    From Opportunity
                    Where Id = :sOppID
            ];
        }

        WrapCNE(setCon.getRecords());
        hasPrevious = setCon.getHasPrevious();
        hasNext = setCon.getHasNext();

        getRelatedRecords();
    }
    public void checkAdmin() {
        try {
            Id adminProf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            if (sProfId == adminProf) {
                isAdmin = true;
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' in line ' + e.getLineNumber());
        }
    }
    public viewCaseNoteEntries() {
        RocordsFound = false;
        bOpportunitySubmitted = false;
        if (ApexPages.currentPage().getParameters().containsKey('doValidation')) {
            doValidation = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Supporting Documents and/or “00-To Be Updated by CM” case notes must be updated before submit for approval can be processed.'));
        } else
                doValidation = false;
        init();
        checkAdmin();
    }
    private void WrapCNE(List<Case_Note_Entry__c> lstC) {
        List<wrapperCNE> tmpLST = new List<wrapperCNE>();
        Integer i = 0;
        Boolean bRes = getReturnTrueIfNurse();
        if (lstC != null && lstC.size() > 0) {
            String strTmpUser = '';
            bOppUnLock = true; // An opportunity s considered unlocked if it has no notes at all
            for (Case_Note_Entry__c oCN : lstC) {
                if (oCN.CreatedBy.Name != null)
                    strTmpUser = oCN.CreatedBy.Name;
                if (bRes) {
                    if (oCN.Report__r.Submitted__c || oCN.Report__r.Report_Submission_Date__c != null)// || String.ValueOf(strTmpUser).ToUpperCase() != String.ValueOf(sUserFullName).toUpperCase())
                        bOppUnLock = false; else
                            bOppUnLock = true;
                } else {
                    bOppUnLock = true;

                    if (oCN.Report__r.Approval_Status__c != 'Completed')
                        bOpportunitySubmitted = true; else
                            bOpportunitySubmitted = false;
                }
                wrapperCNE oWCNE = new wrapperCNE(oCN, sUserFullName, getReturnTrueIfNurse());
                if (objWrapCNE == null)
                    objWrapCNE = oWCNE;
                oWCNE.rowIndex = i;

                if (oWCNE.bShowCheck)
                    tmpLST.add(oWCNE);
                i++;
            }
        }
        lstWrapCNE = tmpLST;
    }


    public List<SelectOption> getBillingCodeAndFill() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '?None?'));

        List<Billing_Code__c> codes = retrieveBillingCodes();
        for (Billing_Code__c code : codes)
            options.add(new SelectOption(code.Id, code.Name));

        return options;
    }

    private List<Billing_Code__c> retrieveBillingCodes() {
        List<Billing_Code__c> codes;
        if (useCustomBillingCode)
            codes = new List<Billing_Code__c>([SELECT Id, Name, AdminMax__c, AdminMin__c, Min__c, Max__c FROM Billing_Code__c WHERE Active__c = true AND DefaultCode__c = false AND Account__c = :accountId ORDER BY Name]); else
                codes = new List<Billing_Code__c>([SELECT Id, Name, AdminMax__c, AdminMin__c, Min__c, Max__c FROM Billing_Code__c WHERE Active__c = true AND DefaultCode__c = true ORDER BY Name]);
        return codes;
    }


    private ApexPages.StandardSetController setCon { get; set; }

    public void FindCaseNoteEntry() {
        String query = '';
        if (oCNE.Activity_Date__c != null) {
            //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: removed the query with the limit 200 and added this one below:
            query = 'SELECT Id, Expenses__c, Mileage__c, Billing_Code__c,Billing_Code__r.LinkCommunication__c, Driving_From_City__c, Professional_Hours__c, Driving_To_City__c,';
            query += 'Report__c, Adj_Professional_Hours__c, Adj_Travel_Wait_Hours__c, Adj_Expenses__c, Adj_Mileage__c, Travel_Wait_Hours__c,';
            query += 'Activity_Date__c, Work_Description__c, Rush__c, Billing_Code__r.AdminMax__c, Billing_Code__r.AdminMin__c, Billing_Code__r.Min__c, Billing_Code__r.Max__c, Expenses_Nurse__c,';
            query += 'Professional_Hours_Nurse__c, Mileage_Nurse__c, Travel_Wait_Hours_Nurse__c, CreatedBy.Name, CreatedById, Report__r.Submitted__c,';
            query += 'Report__r.A_Notes_Approved__c, Report__r.B_Notes_Approved__c, Report__r.Approval_Status__c, Billing_Code__r.Name,';
            query += 'Report__r.Name, Report__r.AccountId, Report__r.Service_Date_From__c, Report__r.Service_Date_Thru__c, Report__r.Related_Case__r.CaseNumber,';
            query += 'Report__r.Related_Case__c, Report__r.Account.Name, Report__r.Report_Name__c, Report__r.Employee__c, Report__r.Report_Submission_Date__c,RelatedCommunicationHistories__c,RelatedAttachments__c';
            query += 'FROM Case_Note_Entry__c WHERE Report__c =:sOppID and Activity_Date__c =: oCNE.Activity_Date__c ORDER BY CreatedBy.Name';
        } else {
            //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: removed the query with the limit 200 and added this one below:
            query = 'SELECT Id, Expenses__c, Mileage__c, Billing_Code__c,Billing_Code__r.LinkCommunication__c,Driving_From_City__c, Professional_Hours__c, Driving_To_City__c,';
            query += 'Report__c, Adj_Professional_Hours__c, Adj_Travel_Wait_Hours__c, Adj_Expenses__c, Adj_Mileage__c, Travel_Wait_Hours__c,';
            query += 'Activity_Date__c, Work_Description__c, Rush__c, Billing_Code__r.AdminMax__c, Billing_Code__r.AdminMin__c, Billing_Code__r.Min__c, Billing_Code__r.Max__c, Expenses_Nurse__c,';
            query += 'Professional_Hours_Nurse__c, Mileage_Nurse__c, Travel_Wait_Hours_Nurse__c, CreatedBy.Name, CreatedById, Report__r.Submitted__c,';
            query += 'Report__r.A_Notes_Approved__c, Report__r.B_Notes_Approved__c, Report__r.Approval_Status__c, Billing_Code__r.Name,';
            query += 'Report__r.Name, Report__r.AccountId, Report__r.Related_Case__r.CaseNumber, Report__r.Account.Name, Report__r.Service_Date_From__c,';
            query += 'Report__r.Service_Date_Thru__c, Report__r.Related_Case__c, Report__r.Report_Name__c, Report__r.Employee__c, Report__r.Report_Submission_Date__c,RelatedCommunicationHistories__c,RelatedAttachments__c';
            query += 'FROM Case_Note_Entry__c WHERE Report__c =:sOppID ORDER BY CreatedBy.Name';
        }
        if (!Test.isRunningTest()) {
            //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: removed the query with the limit 200 and added this one below:
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }
        setCon.setPageSize(100);
        hasNext = setCon.getHasNext();
        hasPrevious = setCon.getHasPrevious();
        WrapCNE(setCon.getRecords());
        if (Test.isRunningTest()) {
            lstCNE = ([
                    SELECT Id, Expenses__c, Mileage__c, Billing_Code__c, Billing_Code__r.LinkCommunication__c, Driving_From_City__c, Professional_Hours__c, Driving_To_City__c, Report__c, Adj_Professional_Hours__c, Adj_Travel_Wait_Hours__c, Adj_Expenses__c, Adj_Mileage__c, Travel_Wait_Hours__c,
                            Activity_Date__c, Work_Description__c, Rush__c, Billing_Code__r.AdminMax__c, Billing_Code__r.AdminMin__c, Billing_Code__r.Min__c, Billing_Code__r.Max__c, Expenses_Nurse__c,
                            Professional_Hours_Nurse__c, Mileage_Nurse__c, Travel_Wait_Hours_Nurse__c, CreatedBy.Name, CreatedById, Report__r.Submitted__c,
                            Report__r.A_Notes_Approved__c, Report__r.B_Notes_Approved__c, Report__r.Approval_Status__c, Billing_Code__r.Name,
                            Report__r.Name, Report__r.AccountId, Report__r.Service_Date_From__c, Report__r.Service_Date_Thru__c, Report__r.Related_Case__r.CaseNumber,
                            Report__r.Related_Case__c, Report__r.Account.Name, Report__r.Report_Name__c, Report__r.Employee__c, Report__r.Report_Submission_Date__c, RelatedCommunicationHistories__c, RelatedAttachments__c
                    FROM Case_Note_Entry__c
                    limit 200
            ]);
            WrapCNE(lstCNE);
        }
    }
    //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: Method for changhing page if records shown are 100+
    public void next() {
        setCon.next();
        hasNext = setCon.getHasNext();
        hasPrevious = setCon.getHasPrevious();
        WrapCNE(setCon.getRecords());
    }
    //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: Method for changhing to previous page.
    public void previous() {
        setCon.previous();
        hasPrevious = setCon.getHasPrevious();
        hasNext = setCon.getHasNext();
        WrapCNE(setCon.getRecords());
    }

    public void BackToSummary() {
        init();
    }

    public void viewSelectedCNE() {
        List<wrapperCNE> lstLocalCNE = new List<wrapperCNE>();
        if (lstWrapCNE != null && lstWrapCNE.size() > 0) {
            for (wrapperCNE oWCne : lstWrapCNE) {
                if (oWCne.bShowCheckValue) {
                    oWCne.bShowCheckValue = false;
                    lstLocalCNE.add(oWCne);
                }
            }
        }
        if (lstLocalCNE.size() > 0) {
            lstWrapCNE = null;
            lstWrapCNE = lstLocalCNE;
            bFirstView = false;
        }
        system.debug('-----bNotNurse----iColCount-----' + bNotNurse + '--------sProfId----' + sProfId);
    }

    public void deleteSelected() {
        Case_Note_Entry__c oCNE;
        List<Case_Note_Entry__c> lstOCne = new List<Case_Note_Entry__c>();
        List<Case_Note_Entry__c> FinalOCne = new List<Case_Note_Entry__c>();
        String strSelectedIds = '';
        List<wrapperCNE> lstLocalCNE = new List<wrapperCNE>();
        if (lstWrapCNE != null && lstWrapCNE.size() > 0) {
            for (wrapperCNE oWCne : lstWrapCNE) {
                if (oWCne.bShowCheckValue)
                    lstOCne.add(oWCne.objCNE); else
                        FinalOCne.add(oWCne.objCNE);
            }
        }
        if (lstOCne.size() > 0) {
            try {
                system.debug('---------AJAY----------' + lstOCne);
                delete lstOCne;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return;
            }
            WrapCNE(FinalOCne);
            init();
        }
    }

    public void viewAllCNE() {
        List<wrapperCNE> lstLocalCNE = new List<wrapperCNE>();
        if (lstWrapCNE != null && lstWrapCNE.size() > 0) {
            for (wrapperCNE oWCne : lstWrapCNE) {
                oWCne.bShowCheckValue = false;
                lstLocalCNE.add(oWCne);
            }
        }
        if (lstLocalCNE.size() > 0) {
            lstWrapCNE = null;
            lstWrapCNE = lstLocalCNE;
        }
        bFirstView = false;
        system.debug('-----bNotNurse----iColCount-----' + bNotNurse + '--------sProfId----' + sProfId);
    }
    public PageReference Cancel() {
        PageReference p;
        if (bFirstView)
            p = new PageReference('/' + sOppID); else {
            sUserFullName = Userinfo.getUserName();
            String sProfId = Userinfo.getProfileId();
            String sUserId = Userinfo.getUserId();
            Boolean bRes = false;
            List<Profile> objP = authNurseProfile.objP;//[SELECT ID FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse'];
            if (objP != null && objP.size() > 0) {
                if (sProfId == objP[0].Id)
                    bRes = true; else {
                    if (objP.size() > 1) {
                        if (sProfId == objP[1].Id)
                            bRes = true;
                    }
                }
            }
            if (bRes) {
                p = Page.viewNurseCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            } else {
                p = Page.viewCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            }
        }
        p.setRedirect(true);
        return p;
    }
    public PageReference editCancel() {
        PageReference p;
        /*if(bFirstView)
            p = new PageReference('/'+sOppID);
        else*/
        {
            sUserFullName = Userinfo.getUserName();
            String sProfId = Userinfo.getProfileId();
            String sUserId = Userinfo.getUserId();
            Boolean bRes = false;
            List<Profile> objP = authNurseProfile.objP;//[SELECT ID FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse'];
            if (objP != null && objP.size() > 0) {
                if (sProfId == objP[0].Id)
                    bRes = true; else {
                    if (objP.size() > 1) {
                        if (sProfId == objP[1].Id)
                            bRes = true;
                    }
                }
            }
            if (bRes) {
                p = Page.viewNurseCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            } else {
                p = Page.viewCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            }
        }
        p.setRedirect(true);
        return p;

        /*PageReference p;
        p = new PageReference('/apex/viewCaseNoteEntries?Id='+sOppID);
        p.setRedirect(true);
        return p;*/
    }
    public String SOQLFormat(Date d) {
        DateTime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        return dt.format('yyyy-MM-dd');
    }
    public void renderSorted() {
        //fsifuentes@levementum.com    Date: 10/07/2015     Descriprion: remove the query that had limit 200 and added the following :
        String strSOQL = 'SELECT Id, Expenses__c, Mileage__c, Billing_Code__c,Billing_Code__r.LinkCommunication__c, Driving_From_City__c, Professional_Hours__c, Driving_To_City__c,';
        strSOQL += 'Report__c, Adj_Professional_Hours__c, Adj_Travel_Wait_Hours__c, Adj_Expenses__c, Adj_Mileage__c, Travel_Wait_Hours__c,';
        strSOQL += ' Activity_Date__c, Work_Description__c, Rush__c, Billing_Code__r.AdminMax__c, Billing_Code__r.AdminMin__c, Billing_Code__r.Min__c, Billing_Code__r.Max__c, Expenses_Nurse__c, Billing_Code__r.Name,';
        strSOQL += ' Report__r.Service_Date_From__c,Report__r.Service_Date_Thru__c,';
        strSOQL += ' Professional_Hours_Nurse__c, Mileage_Nurse__c, Travel_Wait_Hours_Nurse__c, CreatedBy.Name, CreatedById, Report__r.Submitted__c,Report__r.Related_Case__r.CaseNumber,';
        strSOQL += ' Report__r.A_Notes_Approved__c, Report__r.B_Notes_Approved__c,Report__r.Approval_Status__c ,CreatedBy.ProfileId,Report__r.Related_Case__r.Id,';
        strSOQL += ' Report__r.Name,  Report__r.AccountId , Report__r.Account.Name,  Report__r.Report_Name__c, Report__r.Employee__c, Report__r.Report_Submission_Date__c,RelatedCommunicationHistories__c,RelatedAttachments__c';
        strSOQL += ' FROM Case_Note_Entry__c WHERE Report__c =\'' + String.escapeSingleQuotes(sOppID) + '\' ';

        if (oCNE.Activity_Date__c != null)
            strSOQL += ' AND ( Activity_Date__c =' + SOQLFormat(oCNE.Activity_Date__c) + ') ';

        string sortFullExp = ' ORDER BY ' + sortExpression + ' ' + sortDirection;
        strSOQL += sortFullExp;
        //if(strSortBy!= 'Created By')
        //    strSOQL += ' ORDER BY Activity_Date__c DESC limit 200';
        //else
        //    strSOQL += ' ORDER BY CreatedBy.Name limit 200';
        system.debug('-------strSOQL------' + strSOQL);
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(strSOQL));
        setCon.setPageSize(100);
        hasPrevious = setCon.getHasPrevious();
        hasNext = setCon.getHasNext();
        WrapCNE(setCon.getRecords());
    }

    public PageReference AddSelected() {
        PageReference p = new PageReference('/apex/addCaseNoteEntries?Id=' + sOppID + '&RecAdd=' + iRecordAdd);
        p.setRedirect(true);
        return p;
    }

    public PageReference AddSelectedBot() {
        iRecordAdd = iRecordAddBot;
        return AddSelected();
    }

    public PageReference editAllCNE() {
        String strSelectedIds = '';
        List<wrapperCNE> lstLocalCNE = new List<wrapperCNE>();
        if (lstWrapCNE != null && lstWrapCNE.size() > 0) {
            for (wrapperCNE oWCne : lstWrapCNE) {
                lstLocalCNE.add(oWCne);
                if (strSelectedIds != '')
                    strSelectedIds += ',' + oWCne.objCNE.Id; else
                        strSelectedIds += oWCne.objCNE.Id;
            }
        }
        if (lstLocalCNE.size() > 0) {
            lstWrapCNE = null;
            lstWrapCNE = lstLocalCNE;

            PageReference p = new PageReference('/apex/editCaseNoteEntries?SelIds=' + strSelectedIds + '&strOppId=' + sOppID);
            p.setRedirect(true);
            return p;
        } else
                return null;
    }

    public PageReference editSelected() {

        String strSelectedIds = '';
        List<wrapperCNE> lstLocalCNE = new List<wrapperCNE>();
        if (lstWrapCNE != null && lstWrapCNE.size() > 0) {
            for (wrapperCNE oWCne : lstWrapCNE) {
                if (oWCne.bShowCheckValue) {
                    lstLocalCNE.add(oWCne);
                    if (strSelectedIds != '')
                        strSelectedIds += ',' + oWCne.objCNE.Id; else
                            strSelectedIds += oWCne.objCNE.Id;
                }
            }
        }
        if (lstLocalCNE.size() > 0) {
            lstWrapCNE = null;
            lstWrapCNE = lstLocalCNE;

            PageReference p = new PageReference('/apex/editCaseNoteEntries?SelIds=' + strSelectedIds + '&strOppId=' + sOppID);
            p.setRedirect(true);
            return p;
        } else
                return null;

    }

    public PageReference SaveModifiedRecords() {
        Case_Note_Entry__c oCNE;
        List<Case_Note_Entry__c> lstOCne = new List<Case_Note_Entry__c>();
        String strSelectedIds = '';
        List<wrapperCNE> lstLocalCNE = new List<wrapperCNE>();

        Map<String, String> codeSet = getUniqueBillingCodes();

        if (lstWrapCNE != null && lstWrapCNE.size() > 0) {
            for (wrapperCNE oWCne : lstWrapCNE) {
                if (doValidation && codeSet.keySet().contains(OwCne.objCNE.Billing_Code__c) && ((OwCne.objCNE.RelatedCommunicationHistories__c == null || OwCne.objCNE.RelatedCommunicationHistories__c.trim() == '') && (OwCne.objCNE.RelatedAttachments__c == null || OwCne.objCNE.RelatedAttachments__c.trim() == ''))) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Must select supporting document for billing code: ' + codeSet.get(OwCne.objCNE.Billing_Code__c)));
                    return null;
                }
                lstOCne.add(oWCne.objCNE);
            }
        }
        if (lstOCne.size() > 0) {
            try {
                system.debug('---------AJAY----------' + lstOCne);
                update lstOCne;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;
            }
            //PageReference p = Page.viewCaseNoteEntries;
            //p.getParameters().put('Id', sOppID);
            String sUserFullName = Userinfo.getUserName();
            String sProfId = Userinfo.getProfileId();
            String sUserId = Userinfo.getUserId();
            Boolean bRes = false;
            List<Profile> objP = authNurseProfile.objP;//[SELECT ID FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse'];
            PageReference p;
            if (objP != null && objP.size() > 0) {
                if (sProfId == objP[0].Id)
                    bRes = true; else {
                    if (objP.size() > 1) {
                        if (sProfId == objP[1].Id)
                            bRes = true;
                    }
                }
            }
            if (bRes) {
                p = Page.viewNurseCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            } else {
                p = Page.viewCaseNoteEntries;
                p.getParameters().put('Id', sOppID);
            }
            p.setRedirect(true);

            if (doValidation) {
                PageReference submitPageReference = Page.SubmitForApprovalOpportunity;
                submitPageReference.getParameters().put('id', sOppId);
                return submitPageReference;
            }


            return p;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Nothing to save'));
            return null;
        }
    }
    public PageReference ApproveReject() {
        PageReference saveRef = null;
        List<ProcessInstanceWorkitem> workitems = [
                SELECT
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
                AND ProcessInstance.TargetObjectId = :sOppID
                AND ActorId = :UserInfo.getUserId()
                ORDER BY
                        SystemModStamp desc
        ];
        if (!workItems.isEmpty()) {
            ProcessInstanceWorkitem workitem = workitems[0];
            saveRef = new PageReference('/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workitem.Id);
            saveRef.setRedirect(true);
        }
        return saveRef;
    }
    public PageReference saveApprove() {
        PageReference saveRef = null;

        try {
            saveRef = SaveModifiedRecords();

            if (saveRef != null) {
                List<ProcessInstanceWorkitem> workitems = [
                        SELECT
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
                        AND ProcessInstance.TargetObjectId = :sOppID
                        AND ActorId = :UserInfo.getUserId()
                        ORDER BY
                                SystemModStamp desc
                ];
                if (!workItems.isEmpty()) {
                    ProcessInstanceWorkitem workitem = workitems[0];
                    saveRef = new PageReference('/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workitem.Id);
                    saveRef.setRedirect(true);
                }
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }

        return saveRef;
    }

    public PageReference Approve() {
        PageReference saveRef = null;
        try {
            List<ProcessInstanceWorkitem> workitems = [
                    SELECT
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
                    AND ProcessInstance.TargetObjectId = :sOppID
                    AND ActorId = :UserInfo.getUserId()
                    ORDER BY
                            SystemModStamp desc
            ];
            if (!workItems.isEmpty()) {
                ProcessInstanceWorkitem workitem = workitems[0];
                saveRef = new PageReference('/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workitem.Id);
                saveRef.setRedirect(true);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You are not required to approve this Case Report at this time'));
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }

        return saveRef;
    }

    public Boolean bRequiresApproval {
        get {
            if (bRequiresApproval == null) {

                try {
                    List<ProcessInstanceWorkitem> workitems = [
                            SELECT Id
                            FROM
                                    ProcessInstanceWorkitem
                            WHERE
                            IsDeleted = false
                            AND ProcessInstance.TargetObjectId = :sOppID
                            AND ActorId = :UserInfo.getUserId()
                            ORDER BY
                                    SystemModStamp desc
                    ];
                    if (!workItems.isEmpty()) {
                        bRequiresApproval = true;
                    } else {
                        bRequiresApproval = false;
                    }
                } catch (Exception ex) {
                    bRequiresApproval = false;
                }
            }
            return bRequiresApproval;
        }
        private set;
    }

    @TestVisible private Billing_Code__c retrieveBillingCode(Id billingCodeId) {
        Billing_Code__c code = new Billing_Code__c();

        List<Billing_Code__c> codes = [SELECT LinkCommunication__c, Id, Name, AdminMax__c, AdminMin__c, Min__c, Max__c FROM Billing_Code__c WHERE Id = :billingCodeId AND Active__c = TRUE];
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
                        if (item.adminBillingMin != null) {
                            item.adminBillingMin += ' (B)';
                        }
                        if (item.adminBillingMax != null) {
                            item.adminBillingMax += ' (B)';
                        }
                        if (code.LinkCommunication__c)
                            item.renderCommunications = true;
                    }
                }
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }

        return null;
    }

    public PageReference reAssignOpportunity() {
        oppReassign = new Case_Note_Entry__c();
        return Page.viewCaseNoteEntriesReassign;
    }

    public Boolean showCommunicationPopup { get; set; }
    public wrapperCNE selectedWrapperCNE { get; set; }
    public String selectedWrapperCNEId { get; set; }

    public void getCommunicationHistory() {
        showCommunicationPopup = true;
        if (selectedWrapperCNEId == null)
            return;

        for (wrapperCNE oWCne : lstWrapCNE) {
            oWCne.resetHistories();
            if (selectedWrapperCNEId == oWCne.objCNE.Id)
                selectedWrapperCNE = oWCne;
        }

        selectedWrapperCNE.addCommunicationHistoryInfo();

    }

    public void closePopup() {
        showCommunicationPopup = false;
    }

    public PageReference setCommunicationPopup() {
        for (wrapperCNE oWCne : lstWrapCNE) {
            if (selectedWrapperCNEId != null && selectedWrapperCNEId == oWCne.objCNE.Id) {
                selectedWrapperCne.setCommunicationValues();
                /*if(selectedWrapperCNE.selectedTaskId != null && selectedWrapperCNE.selectedTaskId != '')
                    OwCne.objCNE.RelatedCommunicationHistories__c = selectedWrapperCne.objCNE.RelatedCommunicationHistories__c;
                OwCne.objCNE.RelatedAttachments__c = selectedWrapperCne.objCNE.RelatedAttachments__c;*/
            }
            oWCne.resetHistories();
        }

        showCommunicationPopup = false;

        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(false);
        pageRef.getParameters().put('scroll', '560');
        return pageRef;
    }

    public transient List<RelateCommunicatonHistoryController.TaskWrapper1> availableCommunicationHistories { get; set; }
    public transient List<RelateCommunicatonHistoryController.AttachmentWrapper1> availableAttachments { get; set; }


    public void getRelatedRecords() {
        availableCommunicationHistories = new List<RelateCommunicatonHistoryController.TaskWrapper1>();
        if (objOpportunity.Related_Case__c == null)
            return;

        //reduce limit due to 500 records resulting in heap problems Levementum 1/27/17
        for (Task t : [SELECT Description, Id, Subject, Type, CreatedDate, LastModifiedDate, ActivityDate FROM Task WHERE WhatId = :objOpportunity.Related_Case__c ORDER BY ActivityDate DESC LIMIT 350]) {
            availableCommunicationHistories.add(new RelateCommunicatonHistoryController.TaskWrapper1(t));
        }

        getAvailableAttachments();

    }

    public void getAvailableAttachments() {
        if (objOpportunity.Related_Case__c == null)
            return;

        availableAttachments = new List<RelateCommunicatonHistoryController.AttachmentWrapper1>();

        for (Attachment a : [SELECT Description, OwnerId, Id, Name, ContentType, CreatedDate, LastModifiedDate FROM Attachment WHERE ParentId = :objOpportunity.Related_Case__c ORDER BY LastModifiedDate DESC LIMIT 900]) {
            availableAttachments.add(new RelateCommunicatonHistoryController.AttachmentWrapper1(a));
        }

    }


    public PageReference backToView() {
        return Page.viewCaseNoteEntries;
    }

    public Case_Note_Entry__c oppReassign { get; set; }
    public PageReference saveAssignment() {
        List<Case_Note_Entry__c> entriesToupdate = new List<Case_Note_Entry__c>();
        for (wrapperCNE oWCne : lstWrapCNE) {
            if (oWCne.bShowCheckValue) {
                OwCne.objCNE.Report__c = oppReassign.Report__c;
                entriesToUpdate.add(owCne.objCNE);
            }
        }
        try {
            update entriesToUpdate;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Unable to reassign case note entries to new Case Report: ' + e.getMessage()));
            return null;
        }
        RocordsFound = false;
        bOpportunitySubmitted = false;
        init();
        return backToView();
    }
}