trigger CT_RateCard on Rate_Card__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
    CT_ITriggerHandler.IRateCardTriggerHandler handler;
    
    if(Trigger.isBefore)
    {
	    if(Trigger.isInsert){
	        // Currently unsupported by IRateCardTriggerHandler
	    }
	    else if(Trigger.isUpdate){
	        // Currently unsupported by IRateCardTriggerHandler
	    }
	    else if(Trigger.isDelete){
	        // Currently unsupported by IRateCardTriggerHandler
	    }
	    else if(Trigger.isUnDelete){
	        // Currently unsupported by IRateCardTriggerHandler
	    }
    }
    else if(Trigger.isAfter)
    {
	    if(Trigger.isInsert){
	        // Currently unsupported by IRateCardTriggerHandler
	    }
	    else if(Trigger.isUpdate){
            handler = new CT_RateCardTriggerHandler(Trigger.isExecuting, Trigger.size);
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldmap, Trigger.newmap);
	    }
	    else if(Trigger.isDelete){
	        // Currently unsupported by IRateCardTriggerHandler
	    }
	    else if(Trigger.isUnDelete){
	        // Currently unsupported by IRateCardTriggerHandler
	    }
    }

}