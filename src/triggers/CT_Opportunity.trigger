trigger CT_Opportunity on Opportunity (after insert, after update, before insert, before update)
{
    CT_ITriggerHandler.IOpportunityTriggerHandler handler;
    
    if(Trigger.isBefore)
    {
	    if(Trigger.isInsert){
            handler = new CT_OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
            handler.OnBeforeInsert(Trigger.new);
	    }
	    else if(Trigger.isUpdate){
            handler = new CT_OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
            handler.OnBeforeUpdate(trigger.old,trigger.new, trigger.oldmap,trigger.newmap);
	    }	    
    }
    else if(Trigger.isAfter)
    {
	    if(Trigger.isInsert){
            handler = new CT_OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
            handler.OnAfterInsert(Trigger.new, Trigger.newmap);
	    }
	    else if(Trigger.isUpdate){
            handler = new CT_OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldmap, Trigger.newmap);
	    }	    
    }
}