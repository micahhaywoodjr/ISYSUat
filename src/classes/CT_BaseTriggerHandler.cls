//@author : CloudTrigger Inc.
//@date : 3/10/2012
//@description :	base class for the "*Handler" classes that support triggers; it provides common read-only properties that help
//					determine the context in which code is executing
global virtual with sharing class CT_BaseTriggerHandler
{
    protected boolean TriggerIsExecuting = false;

    public boolean IsTriggerContext
    {
        get{ return TriggerIsExecuting;}
    }
    
    public boolean IsVisualforcePageContext
    {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext
    {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext
    {
        get{ return !IsTriggerContext;}
    }
}