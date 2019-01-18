//@author : CloudTrigger Inc.
//@date : 3/10/2012
//@description :    class providing public interfaces; software development "best practices" prescribe coding to interfaces INSTEAD of concrete
//                  implementations of classes, so these interfaces provide the "contracts" which are coded to.
public with sharing class CT_ITriggerHandler
{
    public virtual interface IBaseTriggerHandler
    {


/*      NOTE: if these event methods are ever needed, they should NOT be uncommented here in "IBaseTriggerHandler" because
        it would impact all classes implementing these interfaces that are already in use.  Instead, put the methods in new
        'child' (derived) interfaces [see below] as needed
        
        void OnAfterInsert(SObject[] newSObjects);
        void OnBeforeInsert(SObject[] newSObjects);
        void OnBeforeUpdate(SObject[] oldSObjects, SObject[] updatedSObjects, map<ID, SObject> SObjectMapOld, map<ID, SObject> SObjectMapNew);
        void OnBeforeDelete(SObject[] SObjectsToDelete, map<ID, SObject> SObjectMap);
        void OnAfterDelete(SObject[] deletedSObjects, map<ID, SObject> SObjectMap);
        void OnAfterUpdate(SObject[] oldSObjects, SObject[] updatedSObjects, map<ID, SObject> SObjectOldMap, map<ID, SObject> SObjectNewMap);
        void OnUndelete(SObject[] restoredSObjects);
*/
    }

    public interface IOpportunityTriggerHandler extends IBaseTriggerHandler
    {
        void OnBeforeUpdate(Opportunity[] oldSObjects, Opportunity[] updatedSObjects, map<ID, Opportunity> SObjectMapOld, map<ID, Opportunity> SObjectMapNew);
        void OnBeforeInsert(Opportunity[] newOpportunities);
        void OnAfterUpdate(Opportunity[] pOldOpportunities, Opportunity[] pUpdatedOpportunities, map<ID, Opportunity> pOpportunityOldMap, map<ID, Opportunity> pOpportunityNewMap);
        void OnAfterInsert(Opportunity[] pNewOpportunities, map<ID, Opportunity> pOpportunityNewMap);
    }

    public interface ICaseTriggerHandler extends IBaseTriggerHandler
    {
        void OnAfterUpdate(Case[] pOldCases, Case[] pUpdatedCases, map<ID, sobject> pCaseOldMap, map<ID, sobject> pCaseNewMap);
    }

    public interface IRateCardTriggerHandler extends IBaseTriggerHandler
    {
        void OnAfterUpdate(Rate_Card__c[] pOldRateCards, Rate_Card__c[] pUpdatedRateCards, map<ID, sobject> pRateCardOldMap, map<ID, sobject> pRateCardNewMap);
    }


}