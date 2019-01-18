trigger BillingCodeTrg on Billing_Code__c (after update, after insert, before delete) 
{
	BillingCodeTrgHandler bcHandler = new BillingCodeTrgHandler();
	if(trigger.isAfter)
	{
		if(trigger.isUpdate)
			bcHandler.OnAfterUpdate(trigger.new, trigger.oldMap);
		else if(trigger.isInsert)
			bcHandler.OnAfterInsert(trigger.new);
	}
	else if(trigger.isBefore)
	{
		if(trigger.isDelete)
			bcHandler.OnBeforeDelete(trigger.old);
	}
}