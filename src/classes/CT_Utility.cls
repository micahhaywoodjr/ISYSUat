//@author : CloudTrigger, Inc.
//@date : 3/10/2012
//@description : Class of common methods that facilitate 
global class CT_Utility
{
    static final String CLASSNAME = '\n\n**** CT_Utility';

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to determine if a String is NULL or has zero length ("empty")
	//@paramaters : a String to evaluate
	//@returns : a Boolean indicating if a String has an actual value or not
    global static Boolean StringIsNullOrEmpty(String pStringToValidate)
    {
        String METHODNAME = CLASSNAME + '.StringIsNullOrEmpty(String pStringToValidate)';
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' :: String to validate = ' + pStringToValidate +'\n\n');
        Boolean returnValue = (pStringToValidate == null);
        if(!returnValue)
            returnValue = (pStringToValidate.trim().equals(''));
        return returnValue;
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to evaluate a String and return a default value if the String is invalid
	//@paramaters : a String to evaluate & a String to use as the default value if needed
	//@returns : a String representing the String that was passed in OR a default value if the String is NUll/Empty
    global static String StringGetValueOrDefault(String pStringToValidate, String pDefaultValue)
    {
        String METHODNAME = CLASSNAME + '.StringGetValueOrDefault(String pStringToValidate, String pDefaultValue)';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' :: String to validate = ' + pStringToValidate + ' and Default = '+ pDefaultValue +'\n\n');
        String returnValue = pDefaultValue;
        if (CT_Utility.StringIsNullOrEmpty(pStringToValidate) == false)
            returnValue = pStringToValidate;
        return returnValue;
    }   
     
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : 
	//@paramaters : none
	//@returns : a Boolean representing ...
	global static Boolean ValidateSaveresultList(list<Database.Saveresult> pResults)
    {
        String METHODNAME = CLASSNAME + '.ValidateSaveresultList(list<Database.Saveresult> pResults)';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' :: pResults.size() = ' + pResults.size() + '\n\n');
        Boolean returnValue = true;
        for(Integer iLoop = 0;iLoop<pResults.size();iLoop++)
        {
        	system.debug(LoggingLevel.INFO, METHODNAME + ' :: Result #' + iLoop + ' isSuccess() = '+ pResults[iLoop].isSuccess() +'\n\n');
        	if(pResults[iLoop].isSuccess() == false)
        	{
        		returnValue = false;
        		break;
        	}
        }
        return returnValue;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to determine if a collection of Objects is populated or not
	//@paramaters : collection of Objects
	//@returns : a Boolean indicating if the collection of Objects is populated or not
    global static Boolean ValidateList(list<object> pList)
    {
        String METHODNAME = CLASSNAME + '.ValidateList(list<object>)';
        Boolean returnValue = true;
        if(pList == null){return false;}
        if(pList.size() < 1){return false;}
        if(pList.isEmpty()){return false;}
        return returnValue;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to determine if a collection of SObjects is populated or not
	//@paramaters : collection of SObjects
	//@returns : a Boolean indicating if the collection of SObjects is populated or not
    global static Boolean ValidateList(list<sObject> pList)
    {
        String METHODNAME = CLASSNAME + '.ValidateList(list<sObject>)';
        Boolean returnValue = true;
        if(pList == null){return false;}
        if(pList.size() < 1){return false;}
        if(pList.isEmpty()){return false;}
        return returnValue;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to determine if a collection of key/value pairs - SObjects and their IDs - is populated or not
	//@paramaters : a collection of key/value pairs - SObjects and their IDs
	//@returns : a Boolean indicating if the collection of key/value pairs is populated or not
    global static Boolean ValidateMap(map<Id, SObject> pMap)
    {
        String METHODNAME = CLASSNAME + '.ValidateMap(map<Id, SObject>)';
        Boolean returnValue = true;
        if(pMap == null){return false;}
        if(pMap.size() < 1){return false;}
        if(pMap.isEmpty()){return false;}
        return returnValue;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to determine if a collection of IDs is populated or not
	//@paramaters : a collection of IDs
	//@returns : a Boolean indicating if the collection of IDs is populated or not
    global static Boolean ValidateSet(Set<Id> pSet)
    {
        String METHODNAME = CLASSNAME + '.ValidateSet(Set<Id> pSet)';
        Boolean returnValue = true;
        if(pSet == null){return false;}
        if(pSet.size() < 1){return false;}
        if(pSet.isEmpty()){return false;}
        return returnValue;
    }
/*
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : a method to evaluate a collection of Database.Error objects and extract "Message" & "Status Code" details to return as a String
	//@paramaters : a collection of Database.Error objects to evaluate and extract information from
	//@returns : a String representing the detail information - Messages & Status Codes - from ...
    global static String ListOfDatabaseErrorsToString(list<Database.Error> errList)
    {
        String METHODNAME = CLASSNAME + '.ListOfDatabaseErrorsToString(list<Database.Error> errList)';
        StringBuilder sb = StringBuilder.NewStringBuilder();
        for(Database.Error err : errList)
        {
            sb.AppendLine('DB Error Message: ' + err.getMessage());
            sb.AppendLine('DB Error Status Code: ' + err.getStatusCode());
        }
        return sb.AsString();
    }
*/
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to determine if an Object is found in a collection of Objects
	//@paramaters : an Object to search for, and a collection of Objects to evaluate
	//@returns : a Boolean indicating if the Object param is found in the collection of Objects
    global static Boolean ExistsInList(object toSearchFor, list<object> listOfAny)
    {       
        Boolean returnVal = false;
        for(object a : listOfAny)
        {
            returnVal = (a == toSearchFor);
            if(returnVal) break;
        }
        return returnVal;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to 
	//@paramaters : a String representing the character to use as a separator, and a collection ('Set') of sObject IDs
	//@returns : a delimited String of IDs 
    global static String BuildStringOfIDsForInClause(Set<Id> pIds, String pSeparatorChar)
    {
    	String returnVal = '';
        
        Integer iLoop = 0;
        for(Id i:pIds)
        {
        	returnVal += '\'' + i + '\'';
        	if(iLoop < (pIds.size() - 1))
        		returnVal += pSeparatorChar;
        	iLoop++;
        }

    	return returnVal;
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to 
	//@paramaters : a String representing the character to use as a separator, and a list of sObjects
	//@returns : a delimited String of IDs 
    global static String BuildStringOfIDsForInClause(list<sObject> pSObjects, String pSeparatorChar)
    {
    	String returnVal = '';
        for(Integer iLoop = 0; iLoop <  pSObjects.size(); iLoop++)
        {
        	returnVal += '\'' + pSObjects[iLoop].Id + '\'';
        	if(iLoop < (pSObjects.size() - 1))
        		returnVal += pSeparatorChar;
        }

    	return returnVal;
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to get a RecordType ID from its Name
	//@paramaters : a String representing a RecordType Name
	//@returns : a String representing the RecordType ID based on the RecordType Name param
    global static String GetRecordTypeIdByRecordTypeName(String pRecordTypeName)
    {
    	map<Id, RecordType> RecordTypeMap = CT_Utility.GetRecordTypeMapBySobjectType('');
    	return GetRecordTypeIdByRecordTypeName(RecordTypeMap, pRecordTypeName);
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to get a RecordType ID from its Name based on SObject type (i.e. "Account")
	//@paramaters : a String representing a RecordType Name and a String representing the Sobject Name (i.e. "Account")
	//@returns : a String representing the RecordType ID based on the params
	//@sample: GetRecordTypeIdBySobjectTypeAndRecordTypeName('Account', 'Prospect')
    global static String GetRecordTypeIdBySobjectTypeAndRecordTypeName(String pSobjectType, String pRecordTypeName)
    {
    	map<Id, RecordType> RecordTypeMap = CT_Utility.GetRecordTypeMapBySobjectType(pSobjectType);
    	return GetRecordTypeIdByRecordTypeName(RecordTypeMap, pRecordTypeName);
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to get a RecordType ID from its Name
	//@paramaters : a collection of key/value pairs - RecordTypes & their IDs - and a String representing a RecordType Name
	//@returns : a String representing a RecordType ID based on the RecordType's Name
    private static String GetRecordTypeIdByRecordTypeName(map<Id, RecordType> pRecordTypeMap, String pRecordTypeName)
    {
    	// NOTE: there might be multiple RecordTypes with the same name but for different objects, so need to check for multiple
    	Integer NumberOfMatchesOnName = 0;
    	String returnValue;
    	for(String key : pRecordTypeMap.keySet())
    	{
    		RecordType rt = pRecordTypeMap.get(key);
    		if(rt.Name.equals(pRecordTypeName))
    		{
    			returnValue = rt.Id;
    			//break;
    			NumberOfMatchesOnName++;
    		}
    	}
    	if(NumberOfMatchesOnName < 2)
    	   	return returnValue;
	   	else
	   	{
	   		return 'MULTIPLE RECORDTYPES WITH THAT NAME';
	   	}
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : 
	//@paramaters : a String representing the name of the SObject we want RecordTypes for (i.e. "Account")
	//@returns : a collection of key/value pairs - the RecordTypes & their IDs - for the type of object passed in
	//			OR
	//			a collection of key/value pairs - the RecordTypes & their IDs - for ALL ACTIVE RecordTypes
    private static map<Id, RecordType> GetRecordTypeMapBySobjectType(String pSobjectType)
    {
    	map<Id, RecordType> RecordTypeMap = (CT_Utility.StringIsNullOrEmpty(pSobjectType))
    										? (new map<Id, RecordType>([SELECT r.BusinessProcessId, r.Description, r.DeveloperName, r.Id, r.IsActive, r.Name, r.NamespacePrefix, r.SobjectType FROM RecordType r WHERE r.IsActive = true]))
    										: (new map<Id, RecordType>([SELECT r.BusinessProcessId, r.Description, r.DeveloperName, r.Id, r.IsActive, r.Name, r.NamespacePrefix, r.SobjectType FROM RecordType r WHERE r.IsActive = true and r.SobjectType = :pSobjectType]));
    	
    	return RecordTypeMap;
    }  

/* =============================================  TEST METHODS  ============================================= */

    static testMethod void test_GetRecordTypeIdByRecordTypeName()
    {
		String METHODNAME = CLASSNAME + '.test_GetRecordTypeIdByRecordTypeName()';
		list<RecordType> types = [Select
									  r.SobjectType
									, r.NamespacePrefix
									, r.Name
									, r.IsActive
									, r.Id
									, r.DeveloperName
									, r.Description
									, r.BusinessProcessId
								From
									RecordType r
								WHERE
									r.IsActive = true];
        
        RecordType rt;
        if(ValidateList(types))
        {
        	rt = types[0];
	    	system.assert(rt.Id != null);
	    	system.debug(LoggingLevel.INFO, METHODNAME + ' :: RecType ID ' + rt.Id + '\n\n RecType.Name = '+ rt.Name +'\n\n');
	    	String returnedId = GetRecordTypeIdByRecordTypeName(rt.Name);
	    	system.debug(LoggingLevel.INFO, METHODNAME + ' :: RecType ID ' + rt.Id + '\n\n returnedId = ' + returnedId +'\n\n');
	    	if(returnedId.equals('MULTIPLE RECORDTYPES WITH THAT NAME')){
	    		system.assert(true);
	    	}else
	    		system.assert(rt.Id == returnedId);
        }else{
        	// no RecordTypes ?
        }
    }

    static testMethod void test_GetRecordTypeIdBySobjectTypeAndRecordTypeName()
    {
		list<RecordType> types = [Select
									  r.SobjectType
									, r.NamespacePrefix
									, r.Name
									, r.IsActive
									, r.Id
									, r.DeveloperName
									, r.Description
									, r.BusinessProcessId
								From
									RecordType r
								WHERE
									r.IsActive = true];
        
        RecordType rt;
        if(ValidateList(types))
        {
        	rt = types[0];
        }

    	system.assert(rt.Id != null);
    	
    	String returnedId = GetRecordTypeIdBySobjectTypeAndRecordTypeName(rt.SobjectType, rt.Name);
    	
    	system.assert(rt.Id == returnedId);
   	
    }

    static testMethod void test_ValidateSaveresultListPositive()
    {
        Account acct1 = new Account (Name = 'Test_Account1');
        Account acct2 = new Account (Name = 'Test_Account2');
        
        list<Account> accts = new list<Account>();
        accts.add(acct1);
        accts.add(acct2);
        list<Database.Saveresult> Results = Database.insert(accts);
    	system.assert(ValidateSaveresultList(Results) == true);
   	
    }

    static testMethod void test_ValidateMapPositive()
    {
        Account acct1 = new Account (Name = 'Test_Account1');
        insert acct1;
    	map<Id, Account> myMap = new map<Id, Account>();
    	myMap.put(acct1.Id, acct1);
    	system.assert(ValidateMap(myMap) == true);
   	
    }
    
    static testMethod void test_ValidateMapNegativeNull()
    {
    	map<Id, Contact> myMap;
    	system.assert(ValidateMap(myMap) == false);
    }
    
    static testMethod void test_ValidateMapNegativeEmpty()
    {
    	map<Id, Contact> myMap = new map<Id, Contact>();
    	system.assert(ValidateMap(myMap) == false);
    }
    
    static testMethod void test_ExistsInListNegative()
    {
        Contact cont = new Contact
        (
             MailingStreet        = 'Test Street'
            ,MailingCity          = 'Test City'
            ,Email                = 'unamefortesting@cloudtrigger.net'
            ,FirstName            = 'Test_FirstName'
            ,LastName             = 'Test_Lastname'
            ,Phone                = '2234567890'
            ,OtherPhone           = '2234567890'
            ,MailingState         = 'FL'
            ,MailingPostalCode    = '12345'
        );
        list<Contact> Contacts = new list<Contact>();
        system.assert(ExistsInList(cont, Contacts) == false);
    }

    static testMethod void test_ExistsInListPositive()
    {
        Contact cont = new Contact
        (
             MailingStreet        = 'Test Street'
            ,MailingCity          = 'Test City'
            ,Email                = 'unamefortesting@cloudtrigger.net'
            ,FirstName            = 'Test_FirstName'
            ,LastName             = 'Test_Lastname'
            ,Phone                = '2234567890'
            ,OtherPhone           = '2234567890'
            ,MailingState         = 'FL'
            ,MailingPostalCode    = '12345'
        );
        list<Contact> Contacts = new list<Contact>();
        Contacts.add(cont);
        system.assert(ExistsInList(cont, Contacts) == true);
    }

    static testMethod void test_ValidateSobjectListPositive()
    {
        Contact cont = new Contact
        (
             MailingStreet        = 'Test Street'
            ,MailingCity          = 'Test City'
            ,Email                = 'unamefortesting@cloudtrigger.net'
            ,FirstName            = 'Test_FirstName'
            ,LastName             = 'Test_Lastname'
            ,Phone                = '2234567890'
            ,OtherPhone           = '2234567890'
            ,MailingState         = 'FL'
            ,MailingPostalCode    = '12345'
        );
        list<Contact> Contacts = new list<Contact>();
        Contacts.add(cont);
        system.assert(ValidateList(Contacts) == true);
    }

    static testMethod void test_ValidateSobjectListNegative()
    {
        list<Contact> Contacts = new list<Contact>();
        system.assert(ValidateList(Contacts) == false);
    }

    static testMethod void test_ValidateObjectList()
    {
        list<Integer> ints = new list<Integer>{1,2,3};
        system.assert(ValidateList(ints));
    }

    static testMethod void test_StringGetValueOrDefault1()
    {
        String one = '';
        String defaultVal = 'DEFAULT';
        system.assert(StringGetValueOrDefault(one, defaultVal) == 'DEFAULT');
    }

    static testMethod void test_StringGetValueOrDefault2()
    {
        String one = 'TEST';
        String defaultVal = 'DEFAULT';
        system.assert(StringGetValueOrDefault(one, defaultVal) == 'TEST');
    }
/*
    static testMethod void test_ListOfDatabaseErrorsToStringPositive()
    {
        Account acct1 = new Account(Name='Acct1');
        Account acct2 = new Account();
        Account acct3 = new Account(Name='Acct3');

        list<Account> Accounts = new list<Account>();
        Accounts.add(acct1);
        Accounts.add(acct2);
        
        list<Database.Saveresult> Results = new list<Database.Saveresult>();
        try{
        Results = Database.insert(Accounts);
        }catch(Exception ex){}
        
        String s = ListOfDatabaseErrorsToString(Results[1].getErrors());
        
    	system.assert(s.contains('DB Error Status Code') == true);
   	
    }
*/

    static testMethod void test_BuildStringOfIdsForInClause_WithList()
    {
        Account acct1 = new Account (Name = 'Test_Account1');
        Account acct2 = new Account (Name = 'Test_Account2');
        
        list<Account> accts = new list<Account>();
        accts.add(acct1);
        accts.add(acct2);
        insert accts;

    	string soql = BuildStringOfIDsForInClause(accts,',');
    	
   	   	system.assert(soql.contains(accts[0].Id));
    	system.assert(soql.contains(accts[1].Id));
    	system.assert(soql.contains(','));
   	
    }

    static testMethod void test_BuildStringOfIdsForInClause_WithSet()
    {
        Account acct1 = new Account (Name = 'Test_Account1');
        Account acct2 = new Account (Name = 'Test_Account2');
        
        list<Account> accts = new list<Account>();
        accts.add(acct1);
        accts.add(acct2);
        insert accts;
        
        system.debug('*****TEST :: ID is for Account #1 is: ' + accts[0].Id);
        system.debug('*****TEST :: ID is for Account #2 is: ' + accts[1].Id);

    	Set<Id> mySet = new Set<Id>{accts[0].Id, accts[1].Id};
    	string soql = BuildStringOfIDsForInClause(mySet,',');

    	system.assert(soql.contains(accts[0].Id));
    	system.assert(soql.contains(accts[1].Id));
    	system.assert(soql.contains(','));
   	
    }

    static testMethod void test_ValidateSetPositive()
    {
        Account acct1 = new Account (Name = 'Test_Account1');
        insert acct1;

    	Set<Id> mySet = new Set<Id>{acct1.Id};
    	system.assert(ValidateSet(mySet) == true);
   	
    }
    
    static testMethod void test_ValidateSetNegativeNull()
    {
    	Set<Id> mySet;
    	system.assert(ValidateSet(mySet) == false);
    }
    
    static testMethod void test_ValidateSetNegativeEmpty()
    {
    	Set<Id> mySet = new Set<Id>();
    	system.assert(ValidateSet(mySet) == false);
    }

}