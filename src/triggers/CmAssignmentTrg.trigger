trigger CmAssignmentTrg on CMAssignment__c (before update, before insert, after delete, after insert, after update) 
{
	CMAssignmentTrgHandler assignmentHandler = new CmAssignmentTrgHandler();
	if(trigger.isBefore)
	{
		if(trigger.isInsert)
			assignmentHandler.onBeforeInsert(trigger.new);
		else if(trigger.isUpdate)
			assignmentHandler.onBeforeUpdate(trigger.new);
	}
	if(trigger.isAfter)
	{
		if(trigger.isUpdate)
			assignmentHandler.onAfterUpdate(trigger.new, trigger.oldMap);
		else if(trigger.isInsert)
			assignmentHandler.onAfterInsert(trigger.new);
		else if(trigger.isDelete)
			assignmentHandler.onAfterDelete(trigger.old);
	}
}