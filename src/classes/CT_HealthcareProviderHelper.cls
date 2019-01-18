public with sharing class CT_HealthcareProviderHelper
{
	private String CLASSNAME = '\n\n**** CT_HealthcareProviderHelper.@@METHODNAME()';

	//@author : CloudTrigger, Inc.
	//@date : 3/12/2012
	//@description : method to 
	//@paramaters : none
	//@returns : nothing
    public static CT_HealthcareProviderHelper NewHelper()
    {
    	CT_HealthcareProviderHelper newModel = new CT_HealthcareProviderHelper();
    	return newModel;
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/12/2012
	//@description : method to 
	//@paramaters : none
	//@returns : nothing
    private CT_HealthcareProviderHelper()
    {
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/12/2012
	//@description : method to GetHealthcareProviderListByOpportunityId
	//@paramaters : a String representing the ID of an Opportunity
	//@returns : a collection of Healthcare_Provider__c records
    public list<Healthcare_Provider__c> GetHealthcareProviderListByOpportunityId(String pOpportunityId)
    {
    	String METHODNAME = CLASSNAME.replace('@@METHODNAME', 'GetHealthcareProviderListByOpportunityId');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' \n\n');

    	list<Healthcare_Provider__c> HealthcareProviderList = new list<Healthcare_Provider__c>([Select h.Contact__r.Name, h.Name, h.Contact__c, h.Phone__c, h.Mailing_Address__c, 
                h.Specialty__c, h.Primary__c, h.Contact__r.FirstName, h.Contact__r.LastName  From Healthcare_Provider__c h Where 
                h.Inactive__c <> true and h.Case__c in 
                (Select Related_Case__c From Opportunity Where Id =: pOpportunityId)]);
        return HealthcareProviderList;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/12/2012
	//@description : method to GetOpportunityListByOpportunityId
	//@paramaters : a String representing the ID of an Opportunity
	//@returns : a collection of Opportunity records
    public list<Opportunity> GetOpportunityListByOpportunityId(String pOpportunityId)
    {
    	String METHODNAME = CLASSNAME.replace('@@METHODNAME', 'GetOpportunityListByOpportunityId');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' \n\n');

    	list<Opportunity> OpptyList = new list<Opportunity>([Select Name, Employee__c From Opportunity Where Id =: pOpportunityId]);
        return OpptyList;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/12/2012
	//@description : method to GetHealthcareProviderListByOpportunityId
	//@paramaters : a String representing the ID of an Opportunity
	//@returns : a collection of Healthcare_Provider__c records
    public list<Healthcare_Provider__c> GetPrimaryHealthcareProviderListByOpportunityId(String pOpportunityId)
    {
    	String METHODNAME = CLASSNAME.replace('@@METHODNAME', 'GetPrimaryHealthcareProviderListByOpportunityId');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' \n\n');

    	list<Healthcare_Provider__c> HealthcareProviderList = new list<Healthcare_Provider__c>([Select h.Contact__r.Name, h.Contact__r.FirstName, h.Contact__r.LastName 
	            																		From Healthcare_Provider__c h 
	                																	Where h.Case__c in (Select Related_Case__c 
	                																						From Opportunity 
	                																						Where Id =: pOpportunityId) 
    																						and Primary__c = true]);
        return HealthcareProviderList;
    }


}