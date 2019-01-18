trigger AreaTrg on Area__c (before insert, before update) 
{
	if(trigger.isBefore)
	{
		if(trigger.isInsert)
			AreaTrgHandler.onBeforeInsert(trigger.new);
		if(trigger.isUpdate)
			AreaTrgHandler.onBeforeUpdate(trigger.new);
	}
}