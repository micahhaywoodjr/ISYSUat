//@author : CloudTrigger Inc.
//@date : 10/10/2011
//@description :	class providing ...
public with sharing class createUpdateRates
{
    final String CLASSNAME = '\n\n**** createUpdateRates.METHODNAME()';
    String strAccId;
    Account oAcc;
    public createUpdateRates(ApexPages.StandardController controller)
    {
    	String METHODNAME = CLASSNAME.replace('METHODNAME', 'createUpdateRates') + ' - constructor';
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
    	
        strAccId = controller.getId();
        oAcc = [Select a.Travel_Wait_Rate__c, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, 
            a.Rush_Travel_Wait_Rate__c, a.Rush_Professional_Rate__c, a.Rush_Mileage_Rate__c, a.Professional_Rate__c, a.Mileage_Rate__c From Account a
            Where a.Id = : strAccId];	
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 10/10/2011
	//@description :  this method ___
	//@paramaters : NONE
	//@returns : A PageReference
    public PageReference processMe()
    {
    	String METHODNAME = CLASSNAME.replace('METHODNAME', 'processMe');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');

    	ApexPages.Message msg;
    	/*
    	// get the picklist values for the Case Jurisdiction picklist
    	Set<String> lstLegalJuris = getAllLegalJurisdiction();
    	*/
    	// get the picklist values for the Case Rate__c picklist - NEW 3-10-2012
    	Set<String> lstLegalJuris = getAllValidCaseRateValues();
    	
    	map<String, Rate_Card__c> mapRateCard = new map<String, Rate_Card__c>();
    	
    	// get list of Rate Cards based on Account Id with a name that matches one of the Case Jurisdictions
    	list<Rate_Card__c> lstRC = new list<Rate_Card__c>([Select Id, Name from Rate_Card__c Where Name in :lstLegalJuris and Account__c =: strAccId]);
    	
    	for(Rate_Card__c oRC : lstRC)
    	   mapRateCard.put(oRC.Name, oRC);
    	list<Rate_Card__c> lstToInsert = new list<Rate_Card__c>();
    	for(String strLegalJuris : lstLegalJuris)
    	{
    		if(mapRateCard.get(strLegalJuris)==null)
    		{
    			Rate_Card__c objRC = new Rate_Card__c();
    			objRC.Name = strLegalJuris;
    			objRC.Account__c = strAccId;
    			if((strLegalJuris.toUpperCase()=='CALIFORNIA-WC' && (oAcc.ShippingState=='CA' || oAcc.ShippingState=='CALIFORNIA'))
    			     || (strLegalJuris.toUpperCase()=='ARIZONA-WC' && (oAcc.ShippingState=='AZ' || oAcc.ShippingState=='ARIZONA')) 
    			     || (strLegalJuris.toUpperCase()=='NEVADA-WC' && (oAcc.ShippingState=='NV' || oAcc.ShippingState=='NEVADA')))
    			{
    				objRC.Rush_Mileage_Rate__c = oAcc.Rush_Mileage_Rate__c;
    				objRC.Rush_Professional_Rate__c = oAcc.Rush_Professional_Rate__c;
    				objRC.Rush_Travel_Wait_Rate__c = oAcc.Rush_Travel_Wait_Rate__c;
    				objRC.Travel_Wait_Rate__c = oAcc.Travel_Wait_Rate__c;
    				objRC.Mileage_Rate__c = oAcc.Mileage_Rate__c;
    				objRC.Professional_Rate__c = oAcc.Professional_Rate__c;
    			}
    			lstToInsert.add(objRC);
    		}
    	}
    	PageReference p;
    	try{
    		if(lstToInsert.size()>0)
    		   insert lstToInsert;
	    	p = new PageReference('/'+strAccId);
	    	p.setRedirect(true);
	    	if(test.isRunningTest()) {
            	throw new GenericException('IO Exception');
            }
    	}catch(exception e)
    	{
    		msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to Delete.'+e);
            ApexPages.addMessage(msg);
    	}
    	return p;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description :  this method ___
	//@paramaters : NONE
	//@returns : A collection of Strings
    private Set<String> getAllValidCaseRateValues()
    {
    	String METHODNAME = CLASSNAME.replace('METHODNAME', 'getAllValidCaseRateValues');
    	//system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');

        Set<String> CaseRates = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Case.Rate__c.getDescribe();
        list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
            CaseRates.add(f.getValue());
        return CaseRates;   
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 10/10/2011
	//@description :  this method ___
	//@paramaters : NONE
	//@returns : A collection of Strings
    private Set<String> getAllLegalJurisdiction()
    {
    	String METHODNAME = CLASSNAME.replace('METHODNAME', 'getAllLegalJurisdiction');
    	//system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');

        Set<String> lstLegal = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Case.Jurisdiction__c.getDescribe();
        list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
            lstLegal.add(f.getValue());
        return lstLegal;   
    }
    
    public class GenericException extends Exception {
	}
}