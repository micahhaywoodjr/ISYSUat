trigger UserTrg on User (after update, after insert) 
{
	UserTrgHandler uHandler = new UserTrgHandler();
	if(trigger.isAfter)
	{
		if(trigger.isUpdate)
		{
			uHandler.OnAfterUpdate(trigger.new, trigger.oldMap, trigger.newMap);
		}
		else if(trigger.isInsert)
		{			
			uHandler.onAfterInsert(trigger.new, trigger.newMap);
		}
	}
}