public with sharing class CT_OpportunityTriggerHandler extends CT_BaseTriggerHandler implements CT_ITriggerHandler.IOpportunityTriggerHandler
{
    final String CLASSNAME = '\n\n**** CT_OpportunityTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private CT_OpportunityTriggerProcessor processor;

    //@author : CloudTrigger, Inc.
    //@date : 3/10/2012
    //@description : the class constructor method
    //@paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
    //@returns : nothing
    //@sample call : CT_ITriggerHandler.IOpportunityTriggerHandler handler = new CT_OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
    public CT_OpportunityTriggerHandler(boolean isExecuting, integer pTriggerSize)
    {
        TriggerIsExecuting = isExecuting;
        BatchSize = pTriggerSize;
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        processor = CT_OpportunityTriggerProcessor.NewOpportunityTriggerProcessor(currentUserProfile.Name, UserInfo.getUserId());
    }

    //@author : CloudTrigger, Inc.
    //@date : 3/10/2012
    //@description :  this method handles the 'after insert' event for the trigger; 
    //@paramaters : an array of "post-insert" Opportunities, and a collection of "post-insert" Opportunity key/value pairs
    //@returns : nothing
    public void OnAfterInsert(Opportunity[] pNewOpportunities, map<ID, Opportunity> pOpportunityNewMap)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext))
            {
                // NOTE: THIS LINE OF CODE BELOW REPLACES THE "updateActivityDate.trigger" TRIGGER
                processor.ManageCaseNoteEntryActivityDate(pNewOpportunities, pOpportunityNewMap);
            }
        }
        catch(Exception ex)
        {
            if(ex instanceof CT_BaseApplicationException)
                throw ex;
            else
                throw CT_BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }

    }
    
    //@author : CloudTrigger, Inc.
    //@date : 3/10/2012
    //@description :  this method handles the 'after update' event for the trigger; 
    //@paramaters : an array of "pre-update" Opportunities, an array of "post-update" Opportunities, a collection of "pre-update" Opportunity key/value pairs, and a collection of "post-update" Opportunity key/value pairs
    //@returns : nothing
    public void OnAfterUpdate(Opportunity[] pOldOpportunities, Opportunity[] pUpdatedOpportunities, map<ID, Opportunity> pOpportunityOldMap, map<ID, Opportunity> pOpportunityNewMap)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');

        //try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext))
            {
                // NOTE: THIS LINE OF CODE BELOW REPLACES THE "updateActivityDate.trigger" TRIGGER
                processor.ManageCaseNoteEntryActivityDate(pUpdatedOpportunities, pOpportunityNewMap);
                
                // NOTE: THIS CODE BELOW IS FROM THE "OpportunityAfterUpdate.trigger" TRIGGER
                // THE CODE HAS BEEN COPIED & PASTED
                // ALL NEW/CHANGED CODED IS NOTED

                list<Opportunity> lstOpportunity = pUpdatedOpportunities;//Trigger.New;
                if(lstOpportunity!=null && lstOpportunity.size()>0)
                {
                    Set<String> setAccountIds = new Set<String>();
                    Set<String> setOppIds = new Set<String>();
                    Set<Id> oppOwnerChangedSet = new Set<Id>();
                    
                    //Set<Id> oppRtIdSet = new Set<Id>();
                    Map<Id,Id> oppRtMap = new Map<Id,Id>();
                    for (OpportunityRecordTypes__c oppRt : OpportunityRecordTypes__c.getAll().values())
                    {
                        //oppRtIdSet.add(oppRt.RecordTypeId__c);
                        oppRtMap.put(oppRt.RecordTypeId__c,oppRt.ConvertedRecordTypeID__c);
                    }
                    List<Opportunity> updateOppList = new List<Opportunity>();
                    List<Opportunity> clonedOppList = new List<Opportunity>();
                    Opportunity opp;
                    Opportunity clonedOpp;
                    for(Opportunity oOpp : lstOpportunity)
                    {
                        Boolean AmountLockedChanged = (oOpp.Amount_Locked__c != pOpportunityOldMap.get(oOpp.Id).Amount_Locked__c);  // NEW 3/10/2012
                        Boolean JurisdictionChanged = (oOpp.QBJurisdiction__c != pOpportunityOldMap.get(oOpp.Id).QBJurisdiction__c);  // NEW 3/10/2012
                        system.debug(LoggingLevel.INFO, METHODNAME + '\nJurisdictionChanged = '+JurisdictionChanged+'\nAmountLockedChanged = '+AmountLockedChanged+'\n\n');
                        if(AmountLockedChanged || JurisdictionChanged)  // NEW 3/10/2012
                        {
                            setAccountIds.add(oOpp.AccountId);
                            if(oOpp.Id!=null)
                               setOppIds.add(oOpp.Id);
                        }
                        if(oOpp.OwnerId != pOpportunityOldMap.get(oOpp.Id).OwnerId)
                            oppOwnerChangedSet.add(oOpp.Id);
                        
                        //check to see if we need to create another Opp                     
                        if(oOpp.AutoCreate__c && !oOpp.OpportunityCreated__c && oOpp.StageName=='Submitted' && pOpportunityOldMap.get(oOpp.Id).StageName=='In Process' && oppRtMap.containsKey(oOpp.RecordTypeId))
                        {
                            opp = new Opportunity(
                                Id=oOpp.Id,Name=oOpp.Name,
                                RecordTypeId=oOpp.RecordTypeId,
                                OwnerId=oOpp.OwnerId,
                                Related_Case__c=oOpp.Related_Case__c,
                                Employee__c=oOpp.Employee__c,
                                AccountId=oOpp.AccountId,
                                Service_Date_Thru__c=oOpp.Service_Date_Thru__c,
                                OpportunityCreated__c=true,
                                StageName='Submitted');                         
                            updateOppList.add(opp);
                            
                            clonedOpp = opp.clone();
                            clonedOpp.StageName='In Process';
                            clonedOpp.Service_Date_From__c=null;
                            if(opp.Service_Date_Thru__c!=null)
                                clonedOpp.Service_Date_Thru__c=opp.Service_Date_Thru__c.addDays(30);
                            else
                                clonedOpp.Service_Date_Thru__c=Date.today().addDays(30);
                            clonedOpp.CloseDate=clonedOpp.Service_Date_Thru__c;
                            clonedOpp.AutoCreate__c=true;
                            clonedOpp.OpportunityCreated__c=false;
                            clonedOpp.RecordTypeId = oppRtMap.get(oOpp.RecordTypeId);
                            clonedOppList.add(clonedOpp);
                        }
                    }
                    
                    if(clonedOppList.size()>0)
                        insert clonedOppList;
                    if(updateOppList.size()>0)
                        update updateOppList;
                    
                    if(setOppIds.size()>0)
                    {
                        list<Opportunity> lstOpp = new list<Opportunity>([Select Travel_Wait_Rate__c, Approval_Status__c
                                                                        , Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c 
                                                                        , Rush_Mileage_Rate__c, Professional_Rate__c, Mileage_Rate__c
                                                                        , AccountId, Amount_Locked__c, QBJurisdiction__c
                                                                        , Rate__c  // NEW 3/10/2012
                                                                        From Opportunity Where Id in : setOppIds]);
                        
                        list<Rate_Card__c> lstRC = new list<Rate_Card__c>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
                            Rush_Mileage_Rate__c, Professional_Rate__c, Mileage_Rate__c, Account__c, Name From Rate_Card__c Where Account__c in : setAccountIds]);
                            
                        map<String, Rate_Card__c> mapAccRC = new map<String, Rate_Card__c>();
                        for(Rate_Card__c RateCard : lstRC)
                            mapAccRC.put(RateCard.Account__c+'~'+RateCard.Name, RateCard);
                        
                        for(Opportunity oOpp : lstOpp)
                        {
                            if(!oOpp.Amount_Locked__c)
                            {
                                Rate_Card__c RateCard = mapAccRC.get(oOpp.AccountId+'~'+oOpp.Rate__c); // NEW 3/10/2012
                                //Rate_Card__c RateCard = mapAccRC.get(oOpp.AccountId+'~'+oOpp.QBJurisdiction__c);
                                
                                if(RateCard != null)
                                {
                                    oOpp.Travel_Wait_Rate__c        = RateCard.Travel_Wait_Rate__c;
                                    oOpp.Rush_Travel_Wait_Rate__c   = RateCard.Rush_Travel_Wait_Rate__c;
                                    oOpp.Rush_Professional_Rate__c  = RateCard.Rush_Professional_Rate__c;
                                    oOpp.Rush_Mileage_Rate__c       = RateCard.Rush_Mileage_Rate__c;
                                    oOpp.Professional_Rate__c       = RateCard.Professional_Rate__c;
                                    oOpp.Mileage_Rate__c            = RateCard.Mileage_Rate__c;
                                }
                            }
                        }
                        
                        if(lstOpp.size()>0){
                            system.debug(LoggingLevel.INFO, METHODNAME + ' :: about to UPDATE a list of Opportunities with '+lstOpp.size()+' Opportunities in it.\n\n');
                            update lstOpp;
                        }
                    }
                    if(!oppOwnerChangedSet.isEmpty())
                    {
                        for(List<Case_Note_Entry__c> cneList : [SELECT Id FROM Case_Note_Entry__c WHERE Billing_Code__r.Active__c=true AND Report__c in :oppOwnerChangedSet])
                            update cneList;
                    }
                    
                }

            }
        /*}
        catch(Exception ex)
        {
            if(ex instanceof CT_BaseApplicationException)
                throw ex;
            else
                throw CT_BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
    }

    //@author : CloudTrigger, Inc.
    //@date : 3/10/2012
    //@description :  this method handles the 'before insert' event for the trigger; 
    //@paramaters : an array of ...
    //@returns : nothing
    public void OnBeforeInsert(Opportunity[] pNewOpportunities)
    {
       
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext))
            {
                // NOTE: THIS CODE BELOW IS FROM THE "OpportunityBeforeInsert.trigger" TRIGGER
                // THE ORIGINAL CODE HAS BEEN COPIED & PASTED
                // ALL NEW CODE IS NOTED

                list<Opportunity> lstOpportunity = pNewOpportunities;//Trigger.New;
                if(lstOpportunity!=null && lstOpportunity.size()>0)
                {
                    Set<String> setAccountIds = new Set<String>();
                    Set<String> setCaseIds = new Set<String>();
                    for(Opportunity oOpp : lstOpportunity)
                    {
                        setAccountIds.add(oOpp.AccountId);
                        if(oOpp.Related_Case__c!=null)
                           setCaseIds.add(oOpp.Related_Case__c);
                    }
                    
                    if(setCaseIds.size()>0)
                    {
                        //System.debug('CG: ' + setCaseIds);
                        map<String, Case> mapAccCase = new map<String, Case>([Select Id
                                                                            , Jurisdiction__c
                                                                            , Rate__c  // NEW 3-10-2012
                                                                            from Case Where Id in : setCaseIds]);
                        //System.debug('CG: ' + mapAccCase);
                        
                        // determine Opportunity's Jurisdiction from the related Case's Jurisdiction and 
                        // Opportunity's Rate from the related Case's Rate (new 3-10-2012)
                        for(Opportunity Oppty : lstOpportunity){
                             
                            Oppty.QBJurisdiction__c = mapAccCase.get(Oppty.Related_Case__c).Jurisdiction__c;
                            Oppty.Rate__c = mapAccCase.get(Oppty.Related_Case__c).Rate__c; // NEW 3-10-2012
                        }
                        
                        list<Rate_Card__c> lstRC = new list<Rate_Card__c>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
                            Rush_Mileage_Rate__c, Professional_Rate__c, Mileage_Rate__c, Account__c, Name From Rate_Card__c Where Account__c in : setAccountIds]);
                            
                        map<String, Rate_Card__c> mapAccRC = new map<String, Rate_Card__c>();
                        for(Rate_Card__c oRC : lstRC)
                            mapAccRC.put(oRC.Account__c+'~'+oRC.Name, oRC);
                        
                        for(Opportunity Oppty : lstOpportunity)
                        {
                            Rate_Card__c RateCard = mapAccRC.get(Oppty.AccountId+'~'+Oppty.Rate__c); // NEW 3-10-2012
                            //Rate_Card__c RateCard = mapAccRC.get(Oppty.AccountId+'~'+Oppty.QBJurisdiction__c);
                            
                            if(RateCard!=null)
                            {
                                Oppty.Travel_Wait_Rate__c = RateCard.Travel_Wait_Rate__c;
                                Oppty.Rush_Travel_Wait_Rate__c = RateCard.Rush_Travel_Wait_Rate__c;
                                Oppty.Rush_Professional_Rate__c = RateCard.Rush_Professional_Rate__c;
                                Oppty.Rush_Mileage_Rate__c = RateCard.Rush_Mileage_Rate__c;
                                Oppty.Professional_Rate__c = RateCard.Professional_Rate__c;
                                Oppty.Mileage_Rate__c = RateCard.Mileage_Rate__c;
                            }
                        }
                    }
                }

            }
        }
        catch(Exception ex)
        {
            if(ex instanceof CT_BaseApplicationException)
                throw ex;
            else
                throw CT_BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
    
    //@author : CloudTrigger, Inc.
    //@date : 3/12/2012
    //@description :  this method handles the 'before update' event for the trigger; 
    //@paramaters : an array of "pre-update" Opportunities, an array of "post-update" Opportunities, a collection of "pre-update" Opportunity key/value pairs, and a collection of "post-update" Opportunity key/value pairs
    //@returns : nothing
    public void OnBeforeUpdate(Opportunity[] pOldOpportunities, Opportunity[] pUpdatedOpportunities, map<ID, Opportunity> pOpportunityOldMap, map<ID, Opportunity> pOpportunityNewMap)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext))
            {
                // NOTE: THIS LINE OF CODE BELOW REPLACES THE "LockCaseNoteRates.trigger" TRIGGER
                processor.LockCaseNoteRates(pUpdatedOpportunities, pOpportunityOldMap, pOpportunityNewMap);
            }
        }
        catch(Exception ex)
        {
            if(ex instanceof CT_BaseApplicationException)
                throw ex;
            else
                throw CT_BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }

    }
    
/* =============================================  TEST METHODS  ============================================= */

    private static testMethod void test_CT_OpportunityTriggerHandler_New_1()
    {
        CT_ITriggerHandler.IOpportunityTriggerHandler handler = null;
        handler = new CT_OpportunityTriggerHandler(true, 1);
        system.assert(handler != null);
    }

    private static testMethod void test_CT_OpportunityTriggerHandler()
    {
        Account a = new Account(Name='TEST_ACCOUNT');
        insert a;
        Case c = new Case(AccountId=a.Id, Employee_Case_Trakker__c='TEST_Employee_Case_Trakker', Jurisdiction__c='TEST_Jurisdiction');
        insert c;
        Rate_Card__c rc = new Rate_Card__c();
        rc.Travel_Wait_Rate__c=1.11;
        rc.Rush_Travel_Wait_Rate__c=1.11;
        rc.Rush_Professional_Rate__c=1.11; 
        rc.Rush_Mileage_Rate__c=1.11;
        rc.Professional_Rate__c=1.11;
        rc.Mileage_Rate__c=1.11;
        rc.Account__c=a.Id;
        rc.Name='TEST_RATE_CARD';
        insert rc;
        Opportunity o = new Opportunity(Name='TEST_OPPTY',AccountId=a.Id,StageName='In Process', CloseDate=Date.today());
        insert o;
        o.RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND Name='01-Standard Initial Report'].Id;
        o.StageName='Submitted';
        o.Amount_Locked__c = false;
        o.Related_Case__c = c.Id;
        o.Rate__c='TEST_RATE_CARD';//rc.Id;
        update o;
    }


}