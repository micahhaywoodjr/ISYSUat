//@author : CloudTrigger, Inc.
//@date : 3/10/2012
//@description : class to provide similar functionlity to .NET StringBuilder class
public with sharing class CT_StringBuilder
{
    static final String CLASSNAME = 'CT_StringBuilder.METHODNAME()';
    
    private String[] arr;
    private list<String> stringList = new list<String>();

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : private class constructor
    private void CT_StringBuilder()
    {
        final string METHODNAME = CLASSNAME.replace('.METHODNAME()',' - constructor');
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to convert collection of Strings to one (1) single String
	//@paramaters : none
	//@returns : a String representing ...
    public String AsString()
    {
        // cannot override ToString() method so method is "AsString" instead
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AsString');
        
        String a = '';
        if(this.stringList.size() > 0)
        {
            for(String s : this.stringList)
            { a += s; }
        }
        return a;
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to ...
	//@paramaters : none
	//@returns : nothing
    public void Clear()
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Clear');
        stringList.clear();
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to add a String to the collection
	//@paramaters : a String to add to the collection
	//@returns : nothing
    public void Append(String pStringToAdd)
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Append');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' :: String to add = ' + pStringToAdd +'\n\n');
        stringList.add(pStringToAdd);
    }

	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to add a String to the object's collection in addition to the "new line" characters
	//@paramaters : a String to add to the collection
	//@returns : nothing
    public void AppendLine(String pStringToAdd)
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AppendLine');
        Append(pStringToAdd + '\r\n');
    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to ...
	//@paramaters : none
	//@returns : new instance of CT_StringBuilder class
//    public virtual CT_StringBuilder Clone()
//    {
//        String METHODNAME = CLASSNAME.replace('METHODNAME','Clone');
//
//        CT_StringBuilder sb = new CT_StringBuilder();
//        for(String s : stringList)
//        {
//            sb.Append(s);
//        }
//        return sb;
//
//        return CT_StringBuilder.NewWithFirstValue(this.AsString());
//    }
    
	//@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to instantiate a new CT_StringBuilder object
	//@paramaters : none
	//@returns : new instance of CT_StringBuilder class
    public static CT_StringBuilder NewStringBuilder()
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','NewStringBuilder');

        CT_StringBuilder sb = new CT_StringBuilder();
        return sb;
    }
        
    //@author : CloudTrigger, Inc.
	//@date : 3/10/2012
	//@description : method to instantiate a new CT_StringBuilder object AND populate its String collection with an initial value
	//@paramaters : a String to add to the collection
	//@returns : new instance of CT_StringBuilder class with an initial value in its String collection
    public static CT_StringBuilder NewWithFirstValue(String pValue)
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','NewWithFirstValue');
        CT_StringBuilder sb = new CT_StringBuilder();
        sb.Append(pValue);
        return sb;
    }

/* =============================================  TEST METHODS  ============================================= */

    private static testMethod void testStringBuilder1()
    {
        CT_StringBuilder sb = CT_StringBuilder.NewStringBuilder();
        sb.Append('HAPPY HOLIDAYS!');
        System.assertNotEquals(sb.AsString(), '');
        System.assertNotEquals(sb.AsString(), null);
    }
    
    private static testMethod void testStringBuilder2()
    {
        CT_StringBuilder sb = CT_StringBuilder.NewWithFirstValue('THIS IS A TEST FOR CLOUDTRIGGER');
        sb.Append('This is the second line');
        System.assertNotEquals(sb.AsString(), '');
        System.assertNotEquals(sb.AsString(), null);
        System.assert(sb.AsString().contains('CLOUDTRIGGER'));
    }
    
    private static testMethod void testStringBuilder3()
    {
        CT_StringBuilder sb = CT_StringBuilder.NewWithFirstValue('THIS IS A TEST FOR CLOUDTRIGGER');
        sb.Clear();
        System.assertEquals(sb.AsString(), '');
        System.assert(sb.AsString().contains('CLOUDTRIGGER') == false);
    }
    
    private static testMethod void testStringBuilder4()
    {
        CT_StringBuilder sb = CT_StringBuilder.NewStringBuilder();
        sb.AppendLine('CLOUDTRIGGER');
        sb.Append('ROCKS!');
        System.assertNotEquals(sb.AsString(), '');
        System.assertNotEquals(sb.AsString(), null);
        System.assert(sb.AsString().contains('\r\n'));
    }
}