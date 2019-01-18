public without sharing class selectHealthcareProvider
{
    final String CLASSNAME = '\n\n**** selectHealthcareProvider.METHODNAME()';
    
    // querystring variables
    String strOppId;
    String strButType;
    String strHPVisitId;
    
    Boolean bEditMode;
    String strPath;
    
    list<Healthcare_Provider__c> HealthcareProviderList;
    list<RecordType> AppointmentVisitRecordTypeList;
    list<Contact> lstContact;
    list<Account> lstAccContact;
    list<Opportunity> oOpp;

    public list<wrapHP> HealthcareProviderWrapperList{get;set;}
    public list<wrapContact> ContactWrapperList{get;set;}
    public list<wrapAccount> AccountWrapperList{get;set;}
    
    public boolean bShowHP{get;set;}
    public boolean bShowEmp{get;set;}
    public boolean bShowNoResultMsg{get;set;}
    
    public Contact objContact{get;set;}
    public String strContactName{get;set;}
    public boolean bShowContact{get;set;}
    public String strRecNewStandard {get;set;}
    //public String strRecStandard{get;set;}
    //public String strRecSentry{get;set;}
    
    public CT_HealthcareProviderHelper helper {get; private set;}

    //@author : CloudTrigger, Inc.
    //@date : 
    //@description :  this method is the class constructor 
    //@paramaters : none
    //@returns : nothing
    public selectHealthcareProvider()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'selectHealthcareProvider') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');

        helper = CT_HealthcareProviderHelper.NewHelper(); // NEW 3-12-2012
        
        if(ApexPages.currentPage().getParameters().get('OppId')!=null && ApexPages.currentPage().getParameters().get('OppId')!='')
           strOppId = ApexPages.currentPage().getParameters().get('OppId');
        if(ApexPages.currentPage().getParameters().get('butType')!=null && ApexPages.currentPage().getParameters().get('butType')!='')
           strButType = ApexPages.currentPage().getParameters().get('butType');
        
        init();
        
        if(ApexPages.currentPage().getParameters().get('HpId')!=null && ApexPages.currentPage().getParameters().get('HpId')!='')
        {
           strHPVisitId = ApexPages.currentPage().getParameters().get('HpId');
           bEditMode = true;
        }   

        if(strOppId!=null && strOppId!='' && AppointmentVisitRecordTypeList.size()>0)
        {
            popHealthcareProviders();
            popAccountEmployees();
        }
    }

    //@author : CloudTrigger, Inc.
    //@date : 
    //@description :this method initializes several class-level variable including the three (3) *wrapper* lists,
    //              the Contact object, the Contact list, and multiple boolean variables, as well as getting the 
    //              two RecordType IDs for the 'Standard' and 'Sentry' Appointment_Visit__c RecordTypes
    //@paramaters : none
    //@returns : nothing
    //@called by : selectHealthcareProvider() (the constructor) 
    public void init()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'init');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        
        objContact = new Contact();
        AppointmentVisitRecordTypeList = new list<RecordType>([select Id, Name from RecordType Where sObjectType='Appointment_Visit__c']);
        
        if(CT_Utility.ValidateList(AppointmentVisitRecordTypeList))
        {
            for(RecordType RecType : AppointmentVisitRecordTypeList)
            {
                if(RecType.Name.contains('New'))
                    strRecNewStandard = RecType.ID;
                     if(RecType.Name.contains('Standard'))
                    strRecNewStandard = RecType.Id;
                if(RecType.Name.contains('Sentry'))
                    strRecNewStandard = RecType.Id;
                /*if(RecType.Name.contains('Standard'))
                    strRecStandard = RecType.Id;
                if(RecType.Name.contains('Sentry'))
                    strRecSentry = RecType.Id;  */
            }
        }
        strPath = '';
        bShowHP = false;
        lstContact = new list<Contact>();
        bShowContact = false;
        bEditMode = false;
        bShowNoResultMsg = false;
        bShowEmp = false;
        
        HealthcareProviderWrapperList = new list<wrapHP>();
        ContactWrapperList = new list<wrapContact>();
        AccountWrapperList = new list<wrapAccount>();
        
    }

    //@author : CloudTrigger, Inc.
    //@date : 
    //@description :  this method handles the CLICK event for the "Search for Contact" button 
    //@paramaters : none
    //@returns : nothing
    public void ButtonClickEventSearchForContact()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'ButtonClickEventSearchForContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        String strPath = '';
        
        String strSOQL = 'Select Id, Title, Phone, Nick_Names__c, Name, LastName, FirstName, Email, AccountId, MailingCity From Contact ';
        String strWhere = '';
        if(strContactName!=null && strContactName!='')
            strWhere = ' (FirstName like \'%'+strContactName+'%\' Or LastName like \'%'+strContactName+'%\')';
        
        if(objContact.MailingCity!=null)
        {
            if(strWhere!='')
               strWhere += ' And ';
            strWhere += ' MailingCity like \'%'+objContact.MailingCity+'%\'';
        }
        
        if(strWhere!='')
            strSOQL += ' Where '+strWhere;
        strSOQL += ' Order by Name limit 200';  
        
        // Query for Contacts that match the search criteria
        system.debug(LoggingLevel.INFO, METHODNAME+ ' :; SOQL :' + strSOQL + '\n\n');
        lstContact = database.query(strSOQL);

        
        ContactWrapperList = new list<wrapContact>();

        if(CT_Utility.ValidateList(lstContact))
        { 
            for(Contact oContact : lstContact)
            {
                strPath = '/apex/CT_CreateAppointmentVisit?OppId='+strOppId+'&ContId=@@CONTACT_ID';
                if( strButType != '' ) strPath = strPath + '&butType=' + strButType;
                
                wrapContact ContactWrapper = new wrapContact();
                ContactWrapper.oContact = oContact;
                
                strPath = strPath.replace('@@CONTACT_ID',oContact.Id);
                ContactWrapper.sPath = strPath;
                system.debug(LoggingLevel.INFO, METHODNAME+ ' :: ContactWrapper.sPath = ' + ContactWrapper.sPath + '\n\n');
                ContactWrapperList.add(ContactWrapper);
            }
        }
        
        if(ContactWrapperList.size()>0)
        {
            bShowContact = true;
            bShowNoResultMsg = false;
        }
        else
        {
            bShowNoResultMsg = true;
            bShowContact = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'No Results Found.');
            ApexPages.addMessage(msg);
        }   
    }

    //@author : CloudTrigger, Inc.
    //@date : 
    //@description :  this method handles the CLICK event of the "Cancel" button
    //@paramaters : none
    //@returns : PageReference
    public PageReference ButtonClickEventCancel()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'ButtonClickEventCancel');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        PageReference p = new PageReference('/'+strOppId);
        p.setRedirect(true);
        return p;
    }
    
    //@author : CloudTrigger, Inc.
    //@date : 
    //@description :  this method handles the CLICK event of the "Continue" button
    //@paramaters : none
    //@returns : PageReference
    public PageReference ButtonClickEventContinue()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'ButtonClickEventContinue');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        String strPath = '';
        if(strOppId!=null && strOppId!='' && AppointmentVisitRecordTypeList.size()>0 && oOpp!=null && oOpp.size()>0)
        {
            if(!bEditMode)
            {
                // get a list of Primary Healthcare Providers based on Opportunity ID (should be ONLY ONE Primary)
                list<Healthcare_Provider__c> PrimaryHealthcareProviderList = helper.GetPrimaryHealthcareProviderListByOpportunityId(strOppId);

                strPath = '/apex/CT_CreateAppointmentVisit?OppId='+strOppId+'&ContId=@@CONTACT_ID';
                if( strButType != '' ) strPath = strPath + '&butType=' + strButType;
                
                if(PrimaryHealthcareProviderList.size()==1)
                {
                    String contId = PrimaryHealthcareProviderList[0].Contact__r.Id;
                    strPath = strPath.replace('@@CONTACT_ID', contId);
                }
            }
            else
                strPath = '/'+strHPVisitId+'/e?retURL='+strOppId;
        }
        
        PageReference p;
        if(ct_Utility.StringIsNullOrEmpty(strPath)==false && strPath.contains('@@CONTACT_ID')==false)
        {
            p = new PageReference(strPath);
        }
        else if(strOppId!=null && strOppId!='')
            p = new PageReference('/'+strOppId);
        p.setRedirect(true);
        return p;
    }

    //@author : CloudTrigger, Inc.
    //@date : 
    //@description :this method retrieves a list of Person Accounts / Employees related to a
    //              specific Opportunity (Opportunity.Employee__c) in order to show on the screen 
    //@paramaters : none
    //@returns : nothing
    //@called by : selectHealthcareProvider() (the constructor) 
    public void popAccountEmployees()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'popAccountEmployees');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        
        String strPath = '/apex/CT_CreateAppointmentVisit?OppId='+strOppId+'&ContId=@@CONTACT_ID';
        
        String strSOQL = 'Select FirstName, LastName, Name, Phone, Personal_Email__pc, PersonContactId, PersonTitle, PersonMailingCity From Account Where Id =\''+ oOpp[0].Employee__c +'\'';
        
        system.debug(LoggingLevel.INFO, METHODNAME + ' :: ====================== '+strSOQL);
        lstAccContact = database.query(strSOQL);
        
        if(CT_Utility.ValidateList(lstAccContact))
        {
            AccountWrapperList = new list<wrapAccount>();
            for(Account oAcc : lstAccContact)
            {
                wrapAccount AccountWrapper = new wrapAccount();
                AccountWrapper.oAccount = oAcc;
                strPath = strPath.replace('@@CONTACT_ID',oAcc.PersonContactId);
                
                if(strButType!=null && strButType!='') strPath = strPath + '&butType=' + strButType;
                
                AccountWrapper.sPath = strPath;
                AccountWrapperList.add(AccountWrapper);
            }
        }
        //if(lstWrapAccContact!=null && lstWrapAccContact.size()>0)
            bShowEmp = true;
    }

    //@author : CloudTrigger, Inc.
    //@date : 
    //@description :this method retrieves a list of Healthcare Providers related to 
    //              Cases related to a specific Opportunity in order to show on the screen
    //@paramaters : none
    //@returns : nothing
    //@called by : selectHealthcareProvider() (the constructor) 
    public void popHealthcareProviders()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'popHealthcareProviders');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        
        oOpp = helper.GetOpportunityListByOpportunityId(strOppId);
        
        if(CT_Utility.ValidateList(oOpp))
        {
            // get a list of Healthcare Providers based on Opportunity ID
            HealthcareProviderList = helper.GetHealthcareProviderListByOpportunityId(strOppId);
                
            if(CT_Utility.ValidateList(HealthcareProviderList))
            {
                String tmpLinkPath = '';
                for(Healthcare_Provider__c thisHealthcareProvider : HealthcareProviderList)
                {
                    // instantiate the Healthcare Provider wrapper object
                    wrapHP HealthcareProviderWrapper = new wrapHP();
                    
                    String sPath = '/apex/CT_CreateAppointmentVisit?OppId='+strOppId+'&ContId='+thisHealthcareProvider.Contact__r.Id;
                    if(strButType!=null && strButType!='')
                        sPath = sPath + '&butType=' + strButType;
                    HealthcareProviderWrapper.sPath = sPath;
                    HealthcareProviderWrapper.HealthcareProvider = thisHealthcareProvider;
                    
                    // add object to list
                    HealthcareProviderWrapperList.add(HealthcareProviderWrapper);
                }
            }
            if(CT_Utility.ValidateList(HealthcareProviderWrapperList))
                bShowHP = true;
        }
    }

    public class wrapContact
    {
        public String sPath{get;set;}
        public Contact oContact{get;set;}
        public wrapContact(){}
    }
    public class wrapAccount
    {
        public String sPath{get;set;}
        public Account oAccount{get;set;}
        public wrapAccount(){}
    }
    public class wrapHP
    {
        public String sPath{get;set;}
        public Healthcare_Provider__c HealthcareProvider{get;set;}
        public wrapHP(){}
    }
    
    
    //------------ TEST COVERAGE METHOD-----------------------------
    
    public static testMethod void testThisClass()
    {
        Test.startTest();
        list<Opportunity> oOpp = [Select Id, Related_Case__c From Opportunity Where Related_Case__c in 
            (Select Case__c From Healthcare_Provider__c Where Case__c <> null) limit 1];
        ApexPages.currentPage().getParameters().put('OppId', oOpp[0].Id);   
        selectHealthcareProvider controller = new selectHealthcareProvider();
        list<Healthcare_Provider__c> oHP = [Select Id from Healthcare_Provider__c Where Case__c in (
            Select Related_Case__c From Opportunity Where Id =: oOpp[0].Id)]; 
        ApexPages.currentPage().getParameters().put('HpId', oHP[0].Id);   
        controller = new selectHealthcareProvider();
        controller.init();
        controller.strContactName = 'A.';
        controller.ButtonClickEventSearchForContact();
        controller.objContact.MailingCity = 'A';
        controller.ButtonClickEventSearchForContact();
        controller.ButtonClickEventContinue();
        controller.ButtonClickEventCancel();
        Test.stopTest();
    }
    //--------------------------------------------------------------
}