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
private class TestBatchCaseTotals 
{
    static List<Case> caseList = new List<Case>();
    static testMethod void myUnitTest() 
    {
        BatchCaseTotals bct = new BatchCaseTotals();
        bct.execute(null,caseList);
        bct.finish(null);
    }
    static testMethod void testSchedulable()
    {
    	Test.startTest();        
    	String cron = '0 0 0 17 11 ? 2033';
    	System.schedule('BATR99zz', cron, new BatchCaseTotalsSchedulable());
    	Test.stopTest();
    }
    static
    {
    	Case originalCase = new Case(Status = 'Open', Employee_Case_Trakker__c = 'Test', Total_Invoiced__c=10, TotalExpenses__c=10, RushProfessionalHoursB__c=10, RushProfessionalBillingsTotalB__c=10, RushNonProfessionalHoursB__c=10, RushNonProfessionalBillingsTotalB__c=10, RushMileageTotalB__c=10, RushMileageBillingsTotalB__c=10, ProfessionalHoursCM__c=10, ProfessionalHoursB__c=10, ProfessionalHoursA__c=10, ProfessionalBillingsTotalB__c=10, NonProfessionalHoursCM__c=10, NonProfessionalHoursB__c=10, NonProfessionalHoursA__c=10, NonProfessionalBillingsTotalB__c=10, MileageTotalCM__c=10, MileageTotalB__c=10, MileageTotalA__c=10, MileageBillingsTotalB__c=10, MileageBillingsTotalA__c=10);
    	insert originalCase;
		Case childCase = new Case(Status = 'Open',OriginalCase__c=originalCase.Id,Employee_Case_Trakker__c = 'Test', Total_Invoiced__c=10, TotalExpenses__c=10, RushProfessionalHoursB__c=10, RushProfessionalBillingsTotalB__c=10, RushNonProfessionalHoursB__c=10, RushNonProfessionalBillingsTotalB__c=10, RushMileageTotalB__c=10, RushMileageBillingsTotalB__c=10, ProfessionalHoursCM__c=10, ProfessionalHoursB__c=10, ProfessionalHoursA__c=10, ProfessionalBillingsTotalB__c=10, NonProfessionalHoursCM__c=10, NonProfessionalHoursB__c=10, NonProfessionalHoursA__c=10, NonProfessionalBillingsTotalB__c=10, MileageTotalCM__c=10, MileageTotalB__c=10, MileageTotalA__c=10, MileageBillingsTotalB__c=10, MileageBillingsTotalA__c=10);
    	insert childCase;
    	
    	caseList.add(originalCase);
    	caseList.add(childCase);
    }
}