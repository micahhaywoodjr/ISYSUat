public class searchHPLink {
	String strOppId;
	public String strNextPath{get;set;}
    public searchHPLink(ApexPages.StandardController controller)
    {
    	String strHPVisitId = controller.getId();
        List<Appointment_Visit__c> lstTmpHP = new List<Appointment_Visit__c>([Select Case_Report_Opportunity__c From Appointment_Visit__c Where Id =: strHPVisitId]);
        if(lstTmpHP.size()>0)
        {
            strOppId = lstTmpHP[0].Case_Report_Opportunity__c;
        }
        
        if(strOppId!=null && strOppId!='')
            strNextPath = '/apex/selectHealthcareProvider?OppId='+strOppId+'&HpId='+strHPVisitId;   
    }
    
    //------------TEST COVERAGE METHOD-----------------------------
    public static testMethod void testThisClass() {
        Test.startTest();
        List<Appointment_Visit__c> oAV = [Select Id From Appointment_Visit__c Where Case_Report_Opportunity__c<>null limit 1];
        ApexPages.StandardController obj = new ApexPages.StandardController(oAV[0]);
        searchHPLink controller = new searchHPLink(obj);
        Test.stopTest();
    }
    //--------------------------------------------------------------
}