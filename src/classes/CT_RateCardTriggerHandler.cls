public with sharing class CT_RateCardTriggerHandler extends CT_BaseTriggerHandler implements CT_ITriggerHandler.IRateCardTriggerHandler
{
    final String CLASSNAME = '\n\n**** CT_RateCardTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : the class constructor method
	//@paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
	//@returns : nothing
	//@sample call : CT_ITriggerHandler.IRateCardTriggerHandler handler = new CT_RateCardTriggerHandler(Trigger.isExecuting, Trigger.size);
    public CT_RateCardTriggerHandler(boolean isExecuting, integer pTriggerSize)
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
    public void OnAfterUpdate(Rate_Card__c[] pOldRateCards, Rate_Card__c[] pUpdatedRateCards, map<ID, sobject> pRateCardOldMap, map<ID, sobject> pRateCardNewMap)
    {
    	String METHODNAME = CLASSNAME.replace('METHODNAME', 'OnAfterUpdate');
		map<ID, Rate_Card__c> RateCardOldMap = new map<ID, Rate_Card__c>();
		for(SObject o:pRateCardOldMap.values()){
			Rate_Card__c rc = (Rate_Card__c)o;
			RateCardOldMap.put(rc.Id, rc);
		}

    	try{
	    	if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext))
	    	{
			    // NOTE: THIS CODE BELOW IS FROM THE "RateCardAfterUpdate.trigger" TRIGGER
			    // THE ORIGINAL CODE HAS BEEN COPIED & PASTED
			    
			    list<Rate_Card__c> lstRC = pUpdatedRateCards;
			    if(lstRC!=null && lstRC.size()>0)
			    {
			    	Set<String> setAccountIds = new Set<String>();
			        Set<String> setRCIds = new Set<String>();
			        for(Rate_Card__c oRC : lstRC)
			        {
			            if((oRC.Travel_Wait_Rate__c != RateCardOldMap.get(oRC.Id).Travel_Wait_Rate__c) ||
			                (oRC.Rush_Travel_Wait_Rate__c != RateCardOldMap.get(oRC.Id).Rush_Travel_Wait_Rate__c) ||
			                (oRC.Rush_Professional_Rate__c != RateCardOldMap.get(oRC.Id).Rush_Professional_Rate__c) ||
			                (oRC.Rush_Mileage_Rate__c != RateCardOldMap.get(oRC.Id).Rush_Mileage_Rate__c) ||
			                (oRC.Professional_Rate__c != RateCardOldMap.get(oRC.Id).Professional_Rate__c) ||
			                (oRC.Mileage_Rate__c != RateCardOldMap.get(oRC.Id).Mileage_Rate__c))
			            {
			                setAccountIds.add(oRC.Account__c);
			                setRCIds.add(oRC.Id);
			            }
			        }
			        
			        if(setRCIds.size()>0)
			        {
			        	list<Opportunity> lstOpp = new list<Opportunity>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
			                Rush_Mileage_Rate__c, Professional_Rate__c, Rate__c, QBJurisdiction__c, Mileage_Rate__c, AccountId, Amount_Locked__c From Opportunity Where AccountId in : setAccountIds]);
			            
			            list<Rate_Card__c> lstRateCard = new list<Rate_Card__c>([Select Travel_Wait_Rate__c, Rush_Travel_Wait_Rate__c, Rush_Professional_Rate__c, 
			                Rush_Mileage_Rate__c, Professional_Rate__c, Mileage_Rate__c, Account__c, Name From Rate_Card__c Where Id in : setRCIds]);
			                
			            map<String, list<Opportunity>> mapOppLegal = new map<String, list<Opportunity>>();
			            for(Opportunity oOpp : lstOpp)
			            {
			            	if(!mapOppLegal.containsKey(oOpp.AccountId+'~'+oOpp.Rate__c))
			            	{
			            		list<Opportunity> tmpList = new list<Opportunity>();
			            		tmpList.add(oOpp);
			            		mapOppLegal.put(oOpp.AccountId+'~'+oOpp.Rate__c, tmpList);
			            	}
			            	else
			                    mapOppLegal.get(oOpp.AccountId+'~'+oOpp.Rate__c).add(oOpp);
			            }    
			            list<Opportunity> lstToUpdate = new list<Opportunity>();
			            for(Rate_Card__c objRC : lstRateCard)
			            {
			            	list<Opportunity> tmpLstOpp = mapOppLegal.get(objRC.Account__c+'~'+objRC.Name);
			            	if(tmpLstOpp!=null && tmpLstOpp.size()>0)
			            	{
				            	for(Opportunity objOpp : tmpLstOpp)
				            	{
				            		if(!objOpp.Amount_Locked__c)
				            		{
				            			objOpp.Travel_Wait_Rate__c = objRC.Travel_Wait_Rate__c;
				                        objOpp.Rush_Travel_Wait_Rate__c = objRC.Rush_Travel_Wait_Rate__c;
				                        objOpp.Rush_Professional_Rate__c = objRC.Rush_Professional_Rate__c;
				                        objOpp.Rush_Mileage_Rate__c = objRC.Rush_Mileage_Rate__c;
				                        objOpp.Professional_Rate__c = objRC.Professional_Rate__c;
				                        objOpp.Mileage_Rate__c = objRC.Mileage_Rate__c;
				                        lstToUpdate.add(objOpp);
				            		}
				            	}
			            	}
			            }
			            
			            if(lstToUpdate.size()>0)
			                update lstToUpdate;
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

    private static testMethod void test_CT_RateCardTriggerHandler_New_1()
    {
        CT_ITriggerHandler.IRateCardTriggerHandler handler = null;
        handler = new CT_RateCardTriggerHandler(true, 1);
        system.assert(handler != null);
    }

    private static testMethod void test_CT_RateCardTriggerHandler_OnAfterUpdate()
    {
        CT_ITriggerHandler.IRateCardTriggerHandler handler = null;
        handler = new CT_RateCardTriggerHandler(true, 1);
        system.assert(handler != null);
        // Rate_Card__c[] pOldRateCards, Rate_Card__c[] pUpdatedRateCards, map<ID, sobject> pRateCardOldMap, map<ID, sobject> pRateCardNewMap)
        
        handler.OnAfterUpdate(new list<Rate_Card__c>(), new list<Rate_Card__c>(), new map<Id, sobject>(), new map<Id, sobject>());
    }

}