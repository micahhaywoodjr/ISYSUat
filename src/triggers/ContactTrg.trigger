trigger ContactTrg on Contact (before insert, before update, after update) 
{
	ContactTriggerHandler cth = new ContactTriggerHandler(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
	if(trigger.isAfter)
	{
		if(trigger.isUpdate)
		{
			cth.processAfterUpdate();
		}
	}//end isAfter
	
	if(trigger.isBefore)
	{
		if(Trigger.isInsert){
			cth.processBeforeInsert();
		}
		if(Trigger.isUpdate){
			cth.processBeforeUpdate();
		}
	}//end isBefore
}