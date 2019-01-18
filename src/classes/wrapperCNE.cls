global class wrapperCNE
{
    public Boolean bShowCheck{get;set;}
    public Boolean bEditCheck{get;set;}

    public Boolean bShowCheckValue{get;set;}
    public Boolean bLock{get;set;}
    public Case_Note_Entry__c objCNE{get;set;}
    public Boolean showMinMaxValues{get;set;}
    public String billingMin{get;set;}
    public String billingMax{get;set;}
    public String adminBillingMin {get; set;}
    public String adminBillingMax {get; set;}
    public Integer rowIndex{get;set;}

    public Boolean bSubmittedByNurse{get;set;}
    public Boolean bSubmittedByA{get;set;}
    public Boolean bSubmittedByB{get;set;}

    public static Id CustomNurseProfileId;
    public static Id CustomSrNurseProfileId;

    public Map<String,String> attachmentLinks {get;set;}
    public Map<String,String> communicationLinks {get;set;}
    public List<AttachmentLinkWrapper> allAttachments {get;set;}
    public List<AttachmentLinkWrapper> allCommunications {get;set;}

    public RelateCommunicatonHistoryController relatedCommunication {get;set;}
    public Boolean hasAttachment {get; set;}

    public transient List<RelateCommunicatonHistoryController.TaskWrapper1> availableCommunicationHistories {get;set;}
    public transient List<RelateCommunicatonHistoryController.AttachmentWrapper1> availableAttachments {get;set;}
    private Task selectedTask {get;set;}
    public String selectedTaskId {get;set;}
    public String selectedTaskSubject {get;set;}
    public Boolean renderCommunications {get;set;}

    static {
        List<Profile> objP = new List<Profile>([SELECT ID, Name FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse']);
        if(objP.size() > 0)
        {
            for(Profile oP : objP)
            {
                if(oP.Name == 'Custom - Nurse')
                    CustomNurseProfileId = oP.Id;
                if(oP.Name == 'Custom - Sr Nurse')
                    CustomSrNurseProfileId = oP.Id;
            }
        }
    }

    public void resetHistories(){
        availableCommunicationHistories = new List<RelateCommunicatonHistoryController.TaskWrapper1>();
        availableAttachments = new List<RelateCommunicatonHistoryController.AttachmentWrapper1>();
    }

    public wrapperCNE(Case_Note_Entry__c oCNE, String sUserFullName, Boolean bNurse)
    {
        renderCommunications = false;
        objCNE = oCNE;
        if(objCNE.Billing_Code__c != null && objCNE.Billing_Code__r.LinkCommunication__c == true)
            renderCommunications = true;
        string strTmpUser = '';
        bSubmittedByNurse = false;
        bSubmittedByA = false;
        bSubmittedByB = false;
        relatedCommunication = new RelateCommunicatonHistoryController(objCNE);
        attachmentLinks = relatedCommunication.links;
        communicationLinks = relatedCommunication.getcommunicationLinks();
        allAttachments = new List<AttachmentLinkWrapper>();
        allCommunications = new List<AttachmentLinkWrapper>();

        for(String s : attachmentLinks.keySet()){
            allAttachments.add(new AttachmentLinkWrapper(s,attachmentLinks.get(s)));
        }

        for(String s: communicationLinks.keySet()){
            allCommunications.add(new AttachmentLinkWrapper(s,communicationLinks.get(s)));
        }
        if(bNurse)
        {
            if (UserInfo.getProfileId() == wrapperCNE.CustomNurseProfileId || UserInfo.getProfileId() == wrapperCNE.CustomSrNurseProfileId)
            {
                if (objCNE.CreatedById == UserInfo.getUserId())
                {
                    bShowCheck = true;
                    bEditCheck = true;
                }
                else if (objCNE.CreatedBy.ProfileId == wrapperCNE.CustomNurseProfileId || objCNE.CreatedBy.ProfileId == wrapperCNE.CustomSrNurseProfileId )
                {
                    //CG UPDATED 8/20/18 bShowCheck = true;
                    bShowCheck = false;
                    bEditCheck = false;
                }
                else  {
                    bShowCheck = false;
                    bEditCheck = false;
                }
            }
            else {
                bShowCheck = true;
                bEditCheck = true;
            }

            if(objCNE!=null && objCNE.Report__c != null)
            {
                if(objCNE.Report__r.Submitted__c)
                    bSubmittedByNurse = true;
                if(objCNE.Report__r.A_Notes_Approved__c)
                {
                    bSubmittedByNurse = true;
                    bSubmittedByA = true;
                }
                if(objCNE.Report__r.B_Notes_Approved__c)
                {
                    bSubmittedByNurse = true;
                    bSubmittedByA = true;
                    bSubmittedByB = true;
                }
            }
        }
        else {
            bShowCheck = true;
            bEditCheck = true;

            if(objCNE != null && objCNE.Report__c != null)
            {
                if(objCNE.Report__r.Submitted__c)
                    bSubmittedByNurse = true;
                if(objCNE.Report__r.A_Notes_Approved__c)
                {
                    bSubmittedByNurse = true;
                    bSubmittedByA = true;
                }
                if(objCNE.Report__r.B_Notes_Approved__c)
                {
                    bSubmittedByA = true;
                    bSubmittedByB = true;
                }
            }
        }

        bShowCheckValue = false;

        billingMax = String.ValueOf(oCNE.Billing_Code__r.Max__c);
        billingMin = String.ValueOf(oCNE.Billing_Code__r.Min__c);
        adminBillingMax = String.ValueOf(oCNE.Billing_Code__r.AdminMax__c);
        adminBillingMin = String.ValueOf(oCNE.Billing_Code__r.AdminMin__c);
        if(adminBillingMin != null)
        {
            adminBillingMin += ' (B)';
        }
        if(adminBillingMax != null)
        {
            adminBillingMax += ' (B)';
        }
        if((objCNE.RelatedAttachments__c != null && objCNE.RelatedAttachments__c != '') ||  (objCNE.RelatedCommunicationHistories__c != null && objCNE.RelatedCommunicationHistories__c != ''))
        {
            hasAttachment = true;
        }
    }


    public void getRelatedRecords(){
        availableCommunicationHistories = new List<RelateCommunicatonHistoryController.TaskWrapper1>();
        if(objCNE.Report__r.Related_Case__c == null && relatedCaseId == null)
            return;
        if(relatedCaseId == null)
            relatedCaseId = objCNE.Report__r.Related_Case__c;

        for(Task t : [SELECT Id,Subject,Type,CreatedDate,LastModifiedDate,ActivityDate FROM Task WHERE WhatId = :relatedCaseId ORDER BY ActivityDate DESC]){
            availableCommunicationHistories.add(new RelateCommunicatonHistoryController.TaskWrapper1(t));
        }


    }

    public void getAvailableAttachments(){
        if(objCNE.Report__r.Related_Case__c == null && relatedCaseId == null)
            return;
        if(relatedCaseId == null)
            relatedCaseId = objCNE.Report__r.Related_Case__c;

        availableAttachments = new List<RelateCommunicatonHistoryController.AttachmentWrapper1>();

        for(Attachment a : [SELECT Description,OwnerId,Id,Name,ContentType,CreatedDate FROM Attachment WHERE ParentId = :relatedCaseId ORDER BY CreatedDate DESC]){
            availableAttachments.add(new RelateCommunicatonHistoryController.AttachmentWrapper1(a));
        }

    }

    public String relatedCaseId {get;set;}

    public void addCommunicationHistoryInfo(String relatedCaseId){
        this.relatedCaseId = relatedCaseId;
        addCommunicationHistoryInfo();
    }

    public void addCommunicationHistoryInfo(){
        getRelatedRecords();
        getAvailableAttachments();


        Set<String> commIds = new Set<String>();

        for(String s: communicationLinks.keySet()){
            commIds.add(s.replace('/',''));
        }

        System.debug('objCNE.RelatedCommunicationHistory: ' + objCNE.RelatedCommunicationHistories__c);
        for(RelateCommunicatonHistoryController.TaskWrapper1 t : availableCommunicationHistories){
            if(commIds.contains(t.a.Id))
                t.isSelected = true;
        }

        Set<String> attIds = new Set<String>();

        for(String s: attachmentLinks.keySet()){
            attIds.add(s.replace('/',''));
        }

        if(availableAttachments != null)
            for(RelateCommunicatonHistoryController.AttachmentWrapper1 a: availableAttachments){
                if(attIds.contains(a.a.Id))
                    a.isSelected = true;
            }
    }



    public void setCommunicationValues(){

        System.debug('selectedTaskId: ' + selectedTaskId);
        objCNE.RelatedCommunicationHistories__c = '';
        if(availableCommunicationHistories != null){
            for(RelateCommunicatonHistoryController.TaskWrapper1 t : availableCommunicationHistories){
                if(t.isSelected){
                    objCNE.RelatedCommunicationHistories__c += t.a.Id + ';;' + t.a.Subject + ',,';
                }
            }
        }
        objCNE.RelatedAttachments__c = '';
        String relatedAttachments = '';
        if(AvailableAttachments != null)
            for(RelateCommunicatonHistoryController.AttachmentWrapper1 att : availableAttachments){
                if(att.isSelected){
                    relatedAttachments += att.a.Id + ';;' + att.a.Name + ',,';
                }
            }
        if(relatedAttachments != null)
            ObjCNE.RelatedAttachments__c = relatedAttachments.replaceAll('null','');
        if(objCNE.RelatedCommunicationHistories__c != null)
            objCNE.RelatedCommunicationHistories__c = objCNE.RelatedCommunicationHistories__c.replaceAll('null','');
        relatedCommunication = new RelateCommunicatonHistoryController(objCNE);
        attachmentLinks = relatedCommunication.links;
        communicationLinks = relatedCommunication.getCommunicationLinks();
        allAttachments = new List<AttachmentLinkWrapper>();
        allCommunications = new List<AttachmentLinkWrapper>();


        if(attachmentLinks != null)
            for(String s : attachmentLinks.keySet()){
                allAttachments.add(new AttachmentLinkWrapper(s,attachmentLinks.get(s)));
            }

        if(communicationLinks != null)
            for(String s : communicationLinks.keySet()){
                allcommunications.add(new AttachmentLinkWrapper(s,communicationLinks.get(s)));
            }
    }

    public class AttachmentLinkWrapper{
        public String attId {get;set;}
        public String attName {get;set;}
        public AttachmentLinkWrapper(String attId, String attName){
            this.attId = attId;
            this.attName = attName;
        }
    }

}