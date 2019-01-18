public with sharing class CT_CaseTriggerHandler extends CT_BaseTriggerHandler implements CT_ITriggerHandler.ICaseTriggerHandler
{
    final String CLASSNAME = '\n\n**** CT_CaseTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : the class constructor method
	//@paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
	//@returns : nothing
	//@sample call : CT_ITriggerHandler.ICaseTriggerHandler handler = new CT_CaseTriggerHandler(Trigger.isExecuting, Trigger.size);
    public CT_CaseTriggerHandler(boolean isExecuting, integer pTriggerSize)
    {
        TriggerIsExecuting = isExecuting;
        BatchSize = pTriggerSize;
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description :  this method handles the 'after update' event for the trigger; 
	//@paramaters : an array of ...
	//@returns : nothing
    public void OnAfterUpdate(Case[] pOldCases, Case[] pUpdatedCases, map<ID, sobject> pCaseOldMap, map<ID, sobject> pCaseNewMap)
    {
    	String METHODNAME = CLASSNAME.replace('METHODNAME', 'OnAfterUpdate');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
		map<ID, Case> CaseOldMap = new map<ID, Case>();
		for(SObject o:pCaseOldMap.values()){
			Case rc = (Case)o;
			CaseOldMap.put(rc.Id, rc);
		}

    	try{
	    	if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext))
	    	{
			    // NOTE: THIS CODE BELOW IS FROM THE "CaseAfterUpdate.trigger" TRIGGER
			    // THE ORIGINAL CODE HAS BEEN COPIED & PASTED
			    // ALL NEW/CHANGED CODE IS NOTED

			    list<Case> lstCase = pUpdatedCases;
			    if(lstCase!=null && lstCase.size()>0)
			    {
			    	map<String, String> mapNewOldJuris = new map<String, String>();
			    	map<String, String> mapNewOldQBService = new map<String, String>();
			        map<String, String> mapNewOldRates = new map<String, String>(); // NEW 3-10-2012
			        Set<String> setRates = new Set<String>(); // NEW 3-10-2012
			        Set<String> setJuris = new Set<String>();
			    	Set<String> setCaseIds = new Set<String>();
			    	
				    for(Case oCase : lstCase)
				    {
				    	Boolean JurisdictionChanged = (oCase.Jurisdiction__c != CaseOldMap.get(oCase.Id).Jurisdiction__c);
				    	Boolean QBServiceItemChanged = (oCase.QB_Service_Item__c!= CaseOldMap.get(oCase.Id).QB_Service_Item__c);
				    	Boolean RateChanged = (oCase.Rate__c!= CaseOldMap.get(oCase.Id).Rate__c);
				    	system.debug(LoggingLevel.INFO, METHODNAME + '\nJurisdictionChanged = '+JurisdictionChanged+'\nQBServiceItemChanged = '+QBServiceItemChanged+'\nRateChanged = '+RateChanged+'\n\n');
				    	if(JurisdictionChanged || QBServiceItemChanged || RateChanged)
				    	{
				            setCaseIds.add(oCase.Id);
				            setJuris.add(CaseOldMap.get(oCase.Id).Jurisdiction__c);
				            setRates.add(CaseOldMap.get(oCase.Id).Rate__c); // NEW 3-10-2012
			                mapNewOldRates.put(CaseOldMap.get(oCase.Id).Rate__c+'~'+oCase.AccountId, oCase.Rate__c); // NEW 3-10-2012
			                mapNewOldJuris.put(CaseOldMap.get(oCase.Id).Jurisdiction__c+'~'+oCase.AccountId, oCase.Jurisdiction__c);
			                mapNewOldQBService.put(CaseOldMap.get(oCase.Id).QB_Service_Item__c+'~'+oCase.AccountId, oCase.QB_Service_Item__c);
				    	}
				    }
				    
				    if(setCaseIds!=null && setCaseIds.size()>0)
				    {
				    	Set<String> setAccIds = new Set<String>();
				    	
				    	// Get "In Process" Opportunities where matches on Case AND
				    	// also matches on Rate and Jurisdiction
				    	list<Opportunity> lstOppToUpdate = new list<Opportunity>([Select QBJurisdiction__c
														    				, Rate__c // NEW 3-10-2012
														    				, AccountId, Amount_Locked__c, Travel_Wait_Rate__c
													                        , Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c
													                        , Rush_Mileage_Rate__c, Professional_Rate__c
													                        , Mileage_Rate__c, QBServiceItem__c
													                        from Opportunity 
													                        Where Related_Case__c in : setCaseIds 
													                        and QBJurisdiction__c in : setJuris
													                        and Rate__c in : setRates // NEW 3-10-2012
													                        and StageName = 'In Process' 
													                        and Amount_Locked__c=false]);
				    	
				    	Boolean bUpdated = false;
				    	for(Opportunity oOpp : lstOppToUpdate)
				    	{
				    	    setAccIds.add(oOpp.AccountId);
				    	    
				    	    // This first IF block is NEW 3-10-2012
				    	    if(mapNewOldRates.get(oOpp.Rate__c+'~'+oOpp.AccountId)!=null)
				    	    {
			                   oOpp.Rate__c = mapNewOldRates.get(oOpp.Rate__c+'~'+oOpp.AccountId);
			                   bUpdated = true;
				    	    }
				    	    if(mapNewOldJuris.get(oOpp.QBJurisdiction__c+'~'+oOpp.AccountId)!=null)
				    	    {
			                   oOpp.QBJurisdiction__c = mapNewOldJuris.get(oOpp.QBJurisdiction__c+'~'+oOpp.AccountId);
			                   bUpdated = true;
				    	    }
				    	    if(mapNewOldQBService.get(oOpp.QBServiceItem__c+'~'+oOpp.AccountId)!=null)
				    	    {
				    	       oOpp.QBServiceItem__c = mapNewOldQBService.get(oOpp.QBServiceItem__c+'~'+oOpp.AccountId);
			                   bUpdated = true;
				    	    }
				    	} 
				    	if(bUpdated){
				    		system.debug(LoggingLevel.INFO, METHODNAME + ' :: about to UPDATE a list of Opportunities with '+lstOppToUpdate.size()+' Opportunities in it.\n\n');
				    	    update lstOppToUpdate;
			    	    }
				    	    
				    	list<Rate_Card__c> lstRateCard = new list<Rate_Card__c>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
			                Rush_Mileage_Rate__c, Professional_Rate__c, Mileage_Rate__c, Account__c, Name From Rate_Card__c Where Account__c in : setAccIds]);
			            
			            map<String, list<Rate_Card__c>> mapRateCard = new map<String, list<Rate_Card__c>>();
			            for(Rate_Card__c objRC : lstRateCard)
			            {
			            	if(!mapRateCard.containsKey(objRC.Account__c+'~'+objRC.Name))
			                {
			                    list<Rate_Card__c> tmpList = new list<Rate_Card__c>();
			                    tmpList.add(objRC);
			                    mapRateCard.put(objRC.Account__c+'~'+objRC.Name, tmpList);
			                }
			                else
			                    mapRateCard.get(objRC.Account__c+'~'+objRC.Name).add(objRC);
			            }    
			            
			            system.debug(LoggingLevel.INFO, METHODNAME + ' :: =========mapRateCard========== '+mapRateCard + '\n\n');
			            
			            for(Opportunity oOpp : lstOppToUpdate)
			            {
			            	//list<Rate_Card__c> lstRC = mapRateCard.get(oOpp.AccountId+'~'+oOpp.QBJurisdiction__c);
			            	list<Rate_Card__c> RateCardList = mapRateCard.get(oOpp.AccountId+'~'+oOpp.Rate__c); // NEW 3-10-2012
			            	
			            	system.debug(LoggingLevel.INFO, METHODNAME + ' :: =========RateCardList========== '+RateCardList + '\n\n');
			            	
			            	if(CT_Utility.ValidateList(RateCardList)) // NEW 3-10-2012
			            	{
			            		Rate_Card__c objRC = RateCardList[0];
			                    oOpp.Travel_Wait_Rate__c = objRC.Travel_Wait_Rate__c;
			                    oOpp.Rush_Travel_Wait_Rate__c = objRC.Rush_Travel_Wait_Rate__c;
			                    oOpp.Rush_Professional_Rate__c = objRC.Rush_Professional_Rate__c;
			                    oOpp.Rush_Mileage_Rate__c = objRC.Rush_Mileage_Rate__c;
			                    oOpp.Professional_Rate__c = objRC.Professional_Rate__c;
			                    oOpp.Mileage_Rate__c = objRC.Mileage_Rate__c;
			            	}
			            	else
			            	{
			            		oOpp.Travel_Wait_Rate__c = null;
			                    oOpp.Rush_Travel_Wait_Rate__c = null;
			                    oOpp.Rush_Professional_Rate__c = null;
			                    oOpp.Rush_Mileage_Rate__c = null;
			                    oOpp.Professional_Rate__c = null;
			                    oOpp.Mileage_Rate__c = null;
			            	}
			            }
			            
			            if(CT_Utility.ValidateList(lstOppToUpdate)) // NEW 3-10-2012
			            {
			            	system.debug(LoggingLevel.INFO, METHODNAME + ' :: ========= lstOppToUpdate ========== ' + lstOppToUpdate + '\n\n');
			                system.debug(LoggingLevel.INFO, METHODNAME + ' :: about to UPDATE a list of Opportunities with '+lstOppToUpdate.size()+' Opportunities in it.\n\n');
			                update lstOppToUpdate;
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

/* =============================================  TEST METHODS  ============================================= */

    private static testMethod void test_CT_CaseTriggerHandler_New_1()
    {
        CT_ITriggerHandler.ICaseTriggerHandler handler = null;
        handler = new CT_CaseTriggerHandler(true, 1);
        system.assert(handler != null);
    }

    private static testMethod void test_CT_CaseTriggerHandler_OnAfterInsert()
    {
        CT_ITriggerHandler.ICaseTriggerHandler handler = null;
        handler = new CT_CaseTriggerHandler(true, 1);
        system.assert(handler != null);
        
    }

}