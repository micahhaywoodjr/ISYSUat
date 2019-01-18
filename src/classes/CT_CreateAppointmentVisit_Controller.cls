public with sharing class CT_CreateAppointmentVisit_Controller
{
    final String CLASSNAME = '\n\n**** CT_CreateAppointmentVisit_Controller.METHODNAME()';
    String OpptyId;
    String ContactId;
    String strButType;
    Appointment_Visit__c newApptVisit;

    String RecTypeNewStandard{get;set;}
    String RecTypeStandard{get;set;}
    String RecTypeSentry{get;set;}

    public CT_CreateAppointmentVisit_Controller()
    {
        list<RecordType> RecordTypeList = new list<RecordType>([select Id, Name from RecordType Where sObjectType='Appointment_Visit__c']);
        if(RecordTypeList!=null && RecordTypeList.size()>0)
        {
            for(RecordType rt : RecordTypeList)
            {
                if(rt.Name.contains('Standard'))
                    RecTypeStandard = rt.Id;
                    if(rt.Name.contains('Sentry'))
                    RecTypeSentry = rt.Id;
                    if(rt.Name.contains('New'))
                    RecTypeNewStandard = rt.Id;
                /*if(rt.Name.contains('Standard'))
                    RecTypeStandard = rt.Id;
                if(rt.Name.contains('Sentry'))
                    RecTypeSentry = rt.Id;*/
            }
        }
    }

    public PageReference ProcessNewApptVisit()
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'ProcessNewApptVisit');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        
        if(ApexPages.currentPage().getParameters().get('OppId')!=null && ApexPages.currentPage().getParameters().get('OppId')!='')
           OpptyId = ApexPages.currentPage().getParameters().get('OppId');
        if(ApexPages.currentPage().getParameters().get('ContId')!=null && ApexPages.currentPage().getParameters().get('ContId')!='')
           ContactId = ApexPages.currentPage().getParameters().get('ContId');
        if(ApexPages.currentPage().getParameters().get('butType')!=null && ApexPages.currentPage().getParameters().get('butType')!='')
           strButType = ApexPages.currentPage().getParameters().get('butType');

        newApptVisit = new Appointment_Visit__c();
        newApptVisit.Case_Report_Opportunity__c = OpptyId;
        newApptVisit.Doctor__c = ContactId;
        
        if(strButType == 'New')
            newApptVisit.RecordTypeId = RecTypeNewStandard;
            else
            newApptVisit.RecordTypeId = RecTypeNewStandard;
        /*if(strButType == 'Sentry')
            newApptVisit.RecordTypeId = RecTypeSentry;
        else
            newApptVisit.RecordTypeId = RecTypeStandard;
        */
        insert newApptVisit;
        return redirect();
    }

    public PageReference redirect() 
    {
        // https://cs12.salesforce.com/006/e?retURL=%2F006%2Fo&RecordType=012800000007JXw&ent=Opportunity
        
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'redirect');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
/*
        list<Opportunity> Opps = [SELECT Id, Name FROM Opportunity WHERE Id = :OpptyId];
        //String tmpPath = '/a0A/e?CF00N80000003lIEu=&CF00N80000003lIEu_lkid='+OpptyId+'&saveURL=/'+OpptyId+'&cancelURL=/'+OpptyId;
        String tmpPath = '/a0A/e?CF00N80000003lIEu='+Opps[0].Name+'&CF00N80000003lIEu_lkid='+OpptyId+'&saveURL=/'+OpptyId+'&cancelURL=/'+OpptyId;
        if(strButType == 'Standard')
            tmpPath += '&RecordType='+RecTypeStandard;
        else if(strButType == 'Sentry')
            tmpPath += '&RecordType='+RecTypeSentry;
*/
        
        //https://cs12.salesforce.com/a0A/e?cancelURL=%2F0068000000dJKoJ&CF00N80000003lIEu=James+Turner+-+10-011684&CF00N80000003lIEu_lkid=0068000000dJKoJ&RecordType=0120R000000EY2L&saveURL=%2F0068000000dJKoJ
        
        
        //PageReference customPage = new PageReference(tmpPath);
        PageReference customPage = new PageReference('/' + newApptVisit.Id);
        customPage.setRedirect(true);
        return customPage;
    }

/* =============================================  TEST METHODS  ============================================= */

    private static testMethod void test_CT_CreateAppointmentVisit_Controller_ProcessNewApptVisit()
    {
        Account a = new Account(Name='TEST_ACCOUNT');
        insert a;
        Contact con = new Contact(AccountId=a.Id,LastName='TEST_ACCOUNT');
        insert con;
        Opportunity o = new Opportunity(Name='TEST_OPPTY',AccountId=a.Id,StageName='TEST_ACCOUNT', CloseDate=Date.today());
        insert o;
        
        PageReference pageRef = Page.CT_CreateAppointmentVisit;
        pageRef.getParameters().put('OppId',o.id);
        pageRef.getParameters().put('ContId',con.id);
        Test.setCurrentPageReference(pageRef);
        
        CT_CreateAppointmentVisit_Controller c = new CT_CreateAppointmentVisit_Controller();
        system.assert(c != null);
        PageReference pr = c.ProcessNewApptVisit();
        system.assert(pr != null);
    }
}