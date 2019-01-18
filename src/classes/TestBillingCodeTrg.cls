/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestBillingCodeTrg 
{
	@TestSetup static void testData(){
		Environment_Settings__c e = new Environment_Settings__c();
		e.Name = 'Environment';
		e.ResultsNotificationEmail__c = 'test@testing.com';
		e.NewAcctBillingCodeBatchSize__c= 10;
		insert e;
		Billing_Code__c dBc = new Billing_Code__c();
		dBc.Active__c=true;
		dBc.DefaultCode__c=true;
		dBc.Min__c=1;
		dBc.Max__c=4;
		dBc.Name = 'testBillingCode1';
		insert dBc;
	}
    static Billing_Code__c defaultBc;
    static Account a;
    
    static testMethod void myUnitTest() 
    {
        insert defaultBc;
		//List<Billing_Code__c> newBCList = [select id from Billing_Code__c where name ='testBillingCode'];

		//Database.executeBatch(new NewAcctBillingCodeBatch(newBCList),1);
        //assert that when a new default code is created and the account uses custom codes, the BC is added
    	//System.assertEquals(1,[SELECT Count() FROM Billing_Code__c where Account__c=:a.Id]);
    	
    	Billing_Code__c accountBc = new Billing_Code__c();
    	accountBc.Active__c=true;
    	accountBc.DefaultCode__c=false;
    	accountBc.Min__c=2;
    	accountBc.Max__c=3;
    	accountBc.Account__c=a.Id;
    	accountBc.DefaultBillingCode__c=defaultBc.Id;
    	insert accountBc;
    	    	
    	defaultBc.Active__c=false;
    	update defaultBc;
    	
    	//make sure all related billing codes are marked inactive when the parent is marked inactive
    	System.assertEquals(false,[SELECT Active__c FROM Billing_Code__c where Id=:accountBc.Id].Active__c);

		Billing_Code__c dBc2 = [select Id from Billing_Code__c where  Name = 'testBillingCode1' limit 1] ;
		delete dBc2;
		
    	//delete defaultBc;
    	
    	//make sure all related billing codes are deleted
    	//System.assertEquals(0,[SELECT count() FROM Billing_Code__c where Id=:accountBc.Id or Id=:defaultBc.Id]);
    }
	/*static testMethod void myUnitDeleteTest()
	{
		Billing_Code__c dBc = new Billing_Code__c();
		dBc.Active__c=true;
		dBc.DefaultCode__c=false;
		dBc.Min__c=1;
		dBc.Max__c=4;
		dBc.Name = 'testBillingCode1';
		insert dBc;
		Billing_Code__c dBc2 = [select Id from Billing_Code__c where  Name = 'testBillingCode1'] ;
		delete dBc2;
	}*/
    static
    {
    	a = new Account();
    	a.Name='Test Account';
    	a.UseCustomBillingCode__c = true;
    	insert a;
    	
    	defaultBc = new Billing_Code__c();
    	defaultBc.Active__c=true;
    	defaultBc.DefaultCode__c=true;
    	defaultBc.Min__c=1;
    	defaultBc.Max__c=2;
		defaultBc.Name = 'testBillingCode';



    }
}