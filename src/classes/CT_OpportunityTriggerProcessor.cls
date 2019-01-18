//@author : CloudTrigger Inc.
//@date : 3/12/2012
//@description : class that supports the 'CT_*TriggerHandler' class; it provides the methods called from those classes
public without sharing class CT_OpportunityTriggerProcessor
{
    private final String CLASSNAME = '\n\n**** CT_OpportunityTriggerProcessor.METHODNAME()';
    private String UserProfileName{get; private set;}
    private User CurrentUser{get; private set;}

    //@author : CloudTrigger Inc.
    //@date : 3/12/2012
    //@description : static method that instantiates a new instance of the class & sets the user's profile name member variable
    //@paramaters : a string - the profile name for the current user
    //@returns : a new instance of the CT_OpportunityTriggerProcessor class
    public static CT_OpportunityTriggerProcessor NewOpportunityTriggerProcessor(String pUserProfileName, String pUserId)
    {
        CT_OpportunityTriggerProcessor newHelper = new CT_OpportunityTriggerProcessor(pUserProfileName, pUserId);
        return newHelper;
    }
    
    //@author : CloudTrigger Inc.
    //@date : 3/12/2012
    //@description : static method that instantiates a new instance of the class
    //paramaters : nothing
    //@returns : a new instance of the CT_OpportunityTriggerProcessor class
    public static CT_OpportunityTriggerProcessor NewOpportunityTriggerProcessor(String pUserId)
    {
        CT_OpportunityTriggerProcessor newHelper = new CT_OpportunityTriggerProcessor('', pUserId);
        return newHelper;
    }

    //@author : CloudTrigger, Inc.
    //@date : 3/12/2012
    //@description :  this method is the class constructor; it also sets the record type ID variables 
    //@paramaters : the Profile Name and Id of the current User
    //@returns : a new instance of the CT_OpportunityTriggerProcessor class
    private CT_OpportunityTriggerProcessor(String pUserProfileName, String pUserId)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'CT_OpportunityTriggerProcessor') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        UserProfileName = pUserProfileName;
        CurrentUser = [SELECT Id FROM User WHERE Id=:pUserId];

    }
    
    //@author : CloudTrigger, Inc.
    //@date : 3/12/2012
    //@description :  this method 
    //@paramaters : a collection of Opportunities that have just been INSERTED or UPDATED
    //@returns : nothing
    //@called by:   CT_OpportunityTriggerHandler.OnBeforeUpdate()
    public void LockCaseNoteRates(Opportunity[] pUpdatedOpportunities, map<ID, Opportunity> pOpportunityOldMap, map<ID, Opportunity> pOpportunityNewMap)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'LockCaseNoteRates');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');

        // NOTE: THIS CODE BELOW IS FROM THE "LockCaseNoteRates.trigger" TRIGGER
        // THE CODE HAS BEEN COPIED & PASTED HERE
        // ALL NEW/CHANGED CODED IS NOTED

        //Get Related Account Ids
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : pUpdatedOpportunities) {
            if (opp.AccountId != null) accountIds.add(opp.AccountId);
        }
        
        //Determine if opportunity amount needs to be locked based on stage
        map<Id, Account> accounts = new map<Id, Account>([SELECT Id,Travel_Wait_Rate__c, Professional_Rate__c, Mileage_Rate__c, Rush_Mileage_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c FROM Account WHERE Id IN :accountIds]);
        
        for (Opportunity opp : pUpdatedOpportunities)
        {
            Opportunity oldOpp = pOpportunityOldMap.get(opp.Id);
            
            if (opp.StageName != 'In Process') {
                
                if (opp.Amount_Locked__c == false) {
                    opp.Amount_Locked__c = true;
                    opp.Amount = opp.Report_Total_Amount_Transfer_Field__c;
                    
                    if (accounts.containsKey(opp.AccountId)) {
                        Account a = accounts.get(opp.AccountId);
                        opp.Account_Travel_Wait_Rate__c = a.Travel_Wait_Rate__c;
                        opp.Account_Professional_Rate__c = a.Professional_Rate__c;
                        opp.Account_Mileage_Rate__c = a.Mileage_Rate__c;
                        opp.Account_Rush_Mileage_Rate__c = a.Rush_Mileage_Rate__c;
                        opp.Account_Rush_Travel_Wait_Rate__c = a.Rush_Travel_Wait_Rate__c;
                        opp.Account_Rush_Professional_Rate__c = a.Rush_Professional_Rate__c;
                    }
                }
            }
        }

    }
    
    //@author : CloudTrigger, Inc.
    //@date : 3/12/2012
    //@description :  this method 
    //@paramaters : a collection of Opportunities that have just been INSERTED or UPDATED
    //@returns : nothing
    //@called by:   CT_OpportunityTriggerHandler.OnAfterUpdate()
    //              CT_OpportunityTriggerHandler.OnAfterInsert()
    public void ManageCaseNoteEntryActivityDate(Opportunity[] pOpportunities, map<ID, Opportunity> pOpportunityNewMap)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'ManageCaseNoteEntryActivityDate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');

        // NOTE: THIS CODE BELOW IS FROM THE "updateActivityDate.trigger" TRIGGER
        // THE CODE HAS BEEN COPIED & PASTED HERE
        // ALL NEW/CHANGED CODED IS NOTED

        Set<Id> oppIds = new Set<Id>();
        
        for(Opportunity opp:pOpportunities)
        {
            if(opp.stageName == 'Submitted' && opp.Service_Date_Thru__c != null){
                oppIds.add(opp.Id);
            }    
        }
        
        if(oppIds.size() > 0)
        {
            list<Case_Note_Entry__c> cList = new list<Case_Note_Entry__c>();
            
            for(Case_Note_Entry__c c:[select Billing_Code__c, Activity_Date__c, Billing_Code__r.name, Report__c from Case_Note_Entry__c where Report__c in: oppIds])
            {
                try{
                    if(c.Billing_Code__r.name.startswith('0') || c.Billing_Code__r.name.startswith('1')){
                        c.Activity_Date__c = pOpportunityNewMap.get(c.Report__c).Service_Date_Thru__c;
                        cList.add(c);
                    }    
                    
                    if(cList.size() == 200){
                        update cList;
                        cList.clear();
                    }
                }catch(Exception ex){}
            }
            
            if(cList.size() > 0){
                update cList;
            }
        }

    }


/* =============================================  TEST METHODS  ============================================= */

    private static testMethod void test_CT_OpportunityTriggerProcessor_New_1()
    {
        CT_OpportunityTriggerProcessor helper = null;
        helper = CT_OpportunityTriggerProcessor.NewOpportunityTriggerProcessor('',UserInfo.getUserId());
        system.assert(helper != null);
    }

    private static testMethod void test_CT_OpportunityTriggerProcessor_New_2()
    {
        CT_OpportunityTriggerProcessor helper = null;
        helper = CT_OpportunityTriggerProcessor.NewOpportunityTriggerProcessor(UserInfo.getUserId());
        system.assert(helper != null);
    }


}