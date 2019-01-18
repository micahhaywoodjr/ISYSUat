trigger HealthcareProviderTrg on Healthcare_Provider__c (before insert, before update) 
{
	if(trigger.isBefore)
	{
		if(trigger.isInsert)
			HealthcareProviderTrgHandler.onBeforeInsert(trigger.new);
		else if(trigger.isUpdate)
			HealthcareProviderTrgHandler.onBeforeUpdate(trigger.new);
	}	
}