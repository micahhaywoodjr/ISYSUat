public class redirectToAppointmentVisit {
	
	String strOppId;
    //ApexPages.StandardController controller
    public redirectToAppointmentVisit()
    {
    }
    
    public PageReference redirectMe()
    {
        if(ApexPages.currentPage().getParameters().get('OppId')!=null && ApexPages.currentPage().getParameters().get('OppId')!='')
           strOppId = ApexPages.currentPage().getParameters().get('OppId');
        boolean bAddValue = false;
        string strPath = '';
        
        if(strOppId!=null && strOppId!='')
        {
        	List<RecordType> lstRec = new List<RecordType>([select Id from RecordType Where Name like '%Standard%' and sObjectType='Appointment_Visit__c']);
        	if(lstRec.size()>0)
        	{
	        	List<Opportunity> oOpp = new List<Opportunity>([Select Name From Opportunity Where Id =: strOppId]);
	        	if(oOpp!=null && oOpp.size()>0)
	        	{
	        		strPath = '/a0A/e?CF00N80000003lIEu='+oOpp[0].Name+'&CF00N80000003lIEu_lkid='+strOppId+'&RecordType='+lstRec[0].Id+'&saveURL=/'+strOppId+'&cancelURL=/'+strOppId;
		        	List<Healthcare_Provider__c> lstHP = new List<Healthcare_Provider__c>([Select h.Contact__r.Name From Healthcare_Provider__c h Where h.Case__c in (Select Related_Case__c From Opportunity Where Id =: strOppId) and Primary__c = true]);
		        	if(lstHP.size()==1)
		        	{
		        		strPath+='&CF00N80000003lIJi='+lstHP[0].Contact__r.Name;
		        	}
	        	}
        	}
        }
        
        PageReference p;
        if(strPath!='') 
            p = new PageReference(strPath);
        else if(strOppId!=null && strOppId!='')
            p = new PageReference('/'+strOppId);
        p.setRedirect(true);
        return p;
    }
    
    //------------TEST COVERAGE METHOD-----------------------------
    public static testMethod void testThisClass() {
        Test.startTest();      
        List<Opportunity> lstOpp = [Select Id From Opportunity Where Related_Case__c<> null limit 1];
        ApexPages.currentPage().getParameters().put('OppId', lstOpp[0].Id);   
        redirectToAppointmentVisit controller = new redirectToAppointmentVisit();
        controller.redirectMe();
        Test.stopTest();
    }
    //--------------------------------------------------------------
}