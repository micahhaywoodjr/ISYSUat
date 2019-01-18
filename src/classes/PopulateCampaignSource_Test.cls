@isTest
private class PopulateCampaignSource_Test{

    public Static TestMethod void PopulateCampaignSourceTest(){
    
        Campaign camp = New Campaign(Name='Test Campaign');
        insert camp;
        
        Case c = New Case(Status='Open', Employee_Case_Trakker__c='XYZ', Primary_Campaign__c=camp.Id);
        insert c;
        
        Opportunity oppt = new Opportunity(StageName='In Process', Name='Test Opportunity', CloseDate=System.Today(), Related_Case__c=c.Id);
        insert oppt;
    }
}