global class BatchCaseNoteEntryMetrics implements Database.Batchable<sObject>, Database.Stateful
{
	Date runDate = Date.today();
	integer daysInMonth = Date.daysInMonth(runDate.year(),runDate.month());
	Date metricDate = Date.parse(String.valueOf(runDate.month())+'/'+daysInMonth+'/'+runDate.year());
	Map<String,CMMetric__c> keyMap = new Map<String, CMMetric__c>();
	String monthYear = '';	
	Map<String,Id> rtIdMap = new Map<String,Id>();
	
	global BatchCaseNoteEntryMetrics()
	{
		for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType='CMMetric__c'])
			rtIdMap.put(rt.DeveloperName,rt.Id);
	}
	global Database.Querylocator start(Database.Batchablecontext BC)
    {
    	/*OLD VERSION
    	return Database.getQueryLocator([SELECT Primary_Nurse__c,Covering_Nurse__c,Adj_Travel_Wait_Hours__c,Adj_Professional_Hours__c,Adj_Mileage__c,
                                         Adj_Expenses__c,CreatedById,CreatedBy.UserName,Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c,
                                         Report__c,Travel_Wait_Hours__c,Travel_Wait_Hours_Nurse__c,Professional_Hours__c,Professional_Hours_Nurse__c,
                                         Mileage__c,Mileage_Nurse__c,Expenses__c,Expenses_Nurse__c,Report__r.Report_Submission_Date__c 
                                         FROM Case_Note_Entry__c WHERE Report__r.StageName in ('Approved','Completed')
                                         AND Report__r.Report_Submission_Date__c > 2008-12-31 AND Report__r.A_Note_Approval_Date_Time__c > 2008-12-31T00:00:00.000Z 
                                         AND CreatedBy.IsActive=true AND (Primary_Nurse__c=true OR Covering_Nurse__c=true)]);
    	*/

    	/* Updates made by Corrao Group (Jonathan Castelo) January 2018
    		Updated Filter on Query getQueryLocator
    		Enabled Custom Setting for Start and End Date Range
    		Default Value of Dates to be set when Custom Setting values are Blank
    		Custom Setting values are used to calculate metrics in past and defaults are for current
    		Remove IsActive check on creating User.

		*/

    		//GET DATE RANGES FROM CUSTOM SETTING OR USE DEFAULTS 
    		CMMetricsDateRange__c dateRange = CMMetricsDateRange__c.getOrgDefaults();
    		Date sDate;
    		Date eDate;

    		if(dateRange.StartDate__c == null){
    			//Build Date for First Day of the Month
    			sDate = Date.newInstance(System.today().addDays(-90).year(),System.today().addDays(-90).month(),1);
    		}
    		else{
    			sDate = Date.newInstance(dateRange.StartDate__c.year(),dateRange.StartDate__c.month(),1);
    		}

			//Build Date for Last Day of the Month
    		if(dateRange.EndDate__c == null)
    			eDate = System.today();
    		else{
    			eDate = Date.newInstance(dateRange.EndDate__c.year(),
    											dateRange.EndDate__c.Month() + 1, 
    												Date.daysInMonth(dateRange.EndDate__c.year(),dateRange.EndDate__c.Month()));
    		}

    		return Database.getQueryLocator([SELECT Primary_Nurse__c,Covering_Nurse__c,Adj_Travel_Wait_Hours__c,Adj_Professional_Hours__c,Adj_Mileage__c,
                                         Adj_Expenses__c,CreatedById,CreatedBy.UserName,Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c,
                                         Report__c,Travel_Wait_Hours__c,Travel_Wait_Hours_Nurse__c,Professional_Hours__c,Professional_Hours_Nurse__c,
                                         Mileage__c,Mileage_Nurse__c,Expenses__c,Expenses_Nurse__c,Report__r.Report_Submission_Date__c 
                                         FROM Case_Note_Entry__c 
                                         WHERE Report__r.StageName in ('Approved','Completed')
                                         AND Report__r.Report_Submission_Date__c >=: sDate AND  Report__r.Report_Submission_Date__c <=: eDate
                                         //AND Report__r.A_Note_Approval_Date_Time__c >=: sDate AND Report__r.A_Note_Approval_Date_Time__c <: eDate.addDays(90)
                                         AND Report__r.A_Note_Approval_Date_Time__c != null
                                         AND (Primary_Nurse__c=true OR Covering_Nurse__c=true)]);
    


    }
    global void execute(Database.Batchablecontext BC, list<SObject> scope)
    {
    	try{
    	String areaKey;
    	String userKey;
    	CMMetric__c areaMetric;
    	CMMetric__c userMetric;
    	for(Sobject so : scope)
    	{
    		//report submission date is used to tie into case metric (cannot be null in SOQL)
    		//bnotesapprovaldatetime - has to be populated(cannot be null in SOQL)
    		//Submitted or Approved (not completed anymore)
    		areaMetric = null;
    		userMetric = null;
    		areaKey = null;
    		userKey = null;
    		Case_Note_Entry__c cne = (Case_Note_Entry__c)so;
    		monthYear = String.valueOf(cne.Report__r.Report_Submission_Date__c.month()+'/'+cne.Report__r.Report_Submission_Date__c.year());
    		if(cne.Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c!=null&&cne.Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c!='')
    			areaKey = cne.Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c+':'+cne.CreatedById+':'+monthYear;
    		userKey = cne.CreatedById+':'+monthYear;

    		//key = cne.Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c+':'+cne.CreatedById+':'+monthYear;
    		daysInMonth = Date.daysInMonth(cne.Report__r.Report_Submission_Date__c.year(),cne.Report__r.Report_Submission_Date__c.month());
    		metricDate = Date.parse(String.valueOf(cne.Report__r.Report_Submission_Date__c.month())+'/'+daysInMonth+'/'+cne.Report__r.Report_Submission_Date__c.year());

    		SFDC_Employee__c emp = new SFDC_Employee__c();
    		
    		//Check for Sandbox ".Implement"
	   		if(cne.CreatedBy.Username.contains('.implement'))
	   			emp.SF_Username__c = cne.CreatedBy.UserName.remove('.implement');
	   		else
	   			emp.SF_Username__c = cne.CreatedBy.UserName;
    				




    		if(areaKey!=null)
    		{
    			if(!keyMap.containsKey(areaKey))
    				keyMap.put(areaKey, new CMMetric__c(ExternalId__c=areaKey,TotalTravelWaitHoursNurse__c=0,TotalTravelWaitHoursB__c=0,
    					TotalTravelWaitHoursA__c=0,TotalProfessionalHoursNurse__c=0,TotalProfessionalHoursB__c=0,TotalProfessionalHoursA__c=0,
    					TotalMileageNurse__c=0,TotalMileageB__c=0,TotalMileageA__c=0,TotalExpensesNurse__c=0,TotalExpensesB__c=0,TotalExpensesA__c=0,
    					Employee__r=emp,Area__c=cne.Report__r.Related_Case__r.AssignmentRegion__r.AreaNumber__c,
    					MetricDate__c=metricDate,TotalExpensesCA__c=0,TotalExpensesCB__c=0,TotalExpensesCNurse__c=0,TotalMileageCA__c=0,
    					TotalMileageCB__c=0,TotalMileageCNurse__c=0,TotalProfessionalHoursCA__c=0,TotalProfessionalHoursCB__c=0,
    					TotalProfessionalHoursCNurse__c=0,TotalTravelWaitHoursCA__c=0,TotalTravelWaitHoursCB__c=0,TotalTravelWaitHoursCNurse__c=0,
    					RecordTypeId=rtIdMap.get('AreaMetric')));

					System.debug('metricDate ' + metricDate + ' area ' + metricDate);
    		}
    		if(!keyMap.containsKey(userKey))
    			keyMap.put(userKey, new CMMetric__c(ExternalId__c=userKey,TotalTravelWaitHoursNurse__c=0,TotalTravelWaitHoursB__c=0,TotalTravelWaitHoursA__c=0,TotalProfessionalHoursNurse__c=0,TotalProfessionalHoursB__c=0,TotalProfessionalHoursA__c=0,TotalMileageNurse__c=0,TotalMileageB__c=0,TotalMileageA__c=0,TotalExpensesNurse__c=0,TotalExpensesB__c=0,TotalExpensesA__c=0,Employee__r=emp,MetricDate__c=metricDate,TotalExpensesCA__c=0,TotalExpensesCB__c=0,TotalExpensesCNurse__c=0,TotalMileageCA__c=0,TotalMileageCB__c=0,TotalMileageCNurse__c=0,TotalProfessionalHoursCA__c=0,TotalProfessionalHoursCB__c=0,TotalProfessionalHoursCNurse__c=0,TotalTravelWaitHoursCA__c=0,TotalTravelWaitHoursCB__c=0,TotalTravelWaitHoursCNurse__c=0,RecordTypeId=rtIdMap.get('UserMetric')));
				System.debug('metricDate ' + metricDate + ' user');

    		if(keyMap.containsKey(areaKey))
    			areaMetric = keyMap.get(areaKey);
    		userMetric = keyMap.get(userKey);
    		
    		if(cne.Primary_Nurse__c)
    		{
	    		if(cne.Travel_Wait_Hours_Nurse__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalTravelWaitHoursNurse__c+=cne.Travel_Wait_Hours_Nurse__c;
	    			userMetric.TotalTravelWaitHoursNurse__c+=cne.Travel_Wait_Hours_Nurse__c;
	    		}
	    		if(cne.Professional_Hours_Nurse__c!=null)
    			{
	    			if(areaMetric!=null)
	    				areaMetric.TotalProfessionalHoursNurse__c+=cne.Professional_Hours_Nurse__c;
	    			userMetric.TotalProfessionalHoursNurse__c+=cne.Professional_Hours_Nurse__c;
    			}
	    		if(cne.Mileage_Nurse__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalMileageNurse__c+=cne.Mileage_Nurse__c;
	    			userMetric.TotalMileageNurse__c+=cne.Mileage_Nurse__c;
	    		}
	    		if(cne.Expenses_Nurse__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalExpensesNurse__c+=cne.Expenses_Nurse__c;
	    			userMetric.TotalExpensesNurse__c+=cne.Expenses_Nurse__c;
	    		}
	    		
	    		if(cne.Travel_Wait_Hours__c!=null)
	    		{
		    		if(areaMetric!=null)
	    				areaMetric.TotalTravelWaitHoursA__c+=cne.Travel_Wait_Hours__c;
	    			userMetric.TotalTravelWaitHoursA__c+=cne.Travel_Wait_Hours__c;
	    		}	    		
		    	if(cne.Professional_Hours__c!=null)
		    	{
	    			if(areaMetric!=null)
	    				areaMetric.TotalProfessionalHoursA__c+=cne.Professional_Hours__c;
	    			userMetric.TotalProfessionalHoursA__c+=cne.Professional_Hours__c;
		    	}
	    		if(cne.Mileage__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalMileageA__c+=cne.Mileage__c;
	    			userMetric.TotalMileageA__c+=cne.Mileage__c;
	    		}
	    		if(cne.Expenses__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalExpensesA__c+=cne.Expenses__c;
	    			userMetric.TotalExpensesA__c+=cne.Expenses__c;
	    		}
	    		
	    		if(cne.Adj_Travel_Wait_Hours__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalTravelWaitHoursB__c+=cne.Adj_Travel_Wait_Hours__c;
	    			userMetric.TotalTravelWaitHoursB__c+=cne.Adj_Travel_Wait_Hours__c;
	    		}
	    		if(cne.Adj_Professional_Hours__c!=null)
	    		{    		
	    			if(areaMetric!=null)
	    				areaMetric.TotalProfessionalHoursB__c+=cne.Adj_Professional_Hours__c;
	    			userMetric.TotalProfessionalHoursB__c+=cne.Adj_Professional_Hours__c;
	    		}
	    		if(cne.Adj_Mileage__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalMileageB__c+=cne.Adj_Mileage__c;
	    			userMetric.TotalMileageB__c+=cne.Adj_Mileage__c;
	    		}
	    		if(cne.Adj_Expenses__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalExpensesB__c+=cne.Adj_Expenses__c;
	    			userMetric.TotalExpensesB__c+=cne.Adj_Expenses__c;
	    		}
    		}
    		if(cne.Covering_Nurse__c)
    		{
    			if(cne.Travel_Wait_Hours_Nurse__c!=null)
    			{
	    			if(areaMetric!=null)
	    				areaMetric.TotalTravelWaitHoursCNurse__c+=cne.Travel_Wait_Hours_Nurse__c;
	    			userMetric.TotalTravelWaitHoursCNurse__c+=cne.Travel_Wait_Hours_Nurse__c;
    			}
	    		if(cne.Professional_Hours_Nurse__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalProfessionalHoursCNurse__c+=cne.Professional_Hours_Nurse__c;
	    			userMetric.TotalProfessionalHoursCNurse__c+=cne.Professional_Hours_Nurse__c;
	    		}
	    		if(cne.Mileage_Nurse__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalMileageCNurse__c+=cne.Mileage_Nurse__c;
	    			userMetric.TotalMileageCNurse__c+=cne.Mileage_Nurse__c;
	    		}
	    		if(cne.Expenses_Nurse__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalExpensesCNurse__c+=cne.Expenses_Nurse__c;
	    			userMetric.TotalExpensesCNurse__c+=cne.Expenses_Nurse__c;
	    		}
	    		
	    		if(cne.Travel_Wait_Hours__c!=null)
	    		{
		    		if(areaMetric!=null)
	    				areaMetric.TotalTravelWaitHoursCA__c+=cne.Travel_Wait_Hours__c;
	    			userMetric.TotalTravelWaitHoursCA__c+=cne.Travel_Wait_Hours__c;
	    		}	    		
		    	if(cne.Professional_Hours__c!=null)
		    	{
	    			if(areaMetric!=null)
	    				areaMetric.TotalProfessionalHoursCA__c+=cne.Professional_Hours__c;
	    			userMetric.TotalProfessionalHoursCA__c+=cne.Professional_Hours__c;
		    	}
	    		if(cne.Mileage__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalMileageCA__c+=cne.Mileage__c;
	    			userMetric.TotalMileageCA__c+=cne.Mileage__c;
	    		}
	    		if(cne.Expenses__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalExpensesCA__c+=cne.Expenses__c;
	    			userMetric.TotalExpensesCA__c+=cne.Expenses__c;
	    		}
	    		
	    		if(cne.Adj_Travel_Wait_Hours__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalTravelWaitHoursCB__c+=cne.Adj_Travel_Wait_Hours__c;
	    			userMetric.TotalTravelWaitHoursCB__c+=cne.Adj_Travel_Wait_Hours__c;
	    		}
	    		if(cne.Adj_Professional_Hours__c!=null)
	    		{    		
	    			if(areaMetric!=null)
	    				areaMetric.TotalProfessionalHoursCB__c+=cne.Adj_Professional_Hours__c;
	    			userMetric.TotalProfessionalHoursCB__c+=cne.Adj_Professional_Hours__c;
	    		}
	    		if(cne.Adj_Mileage__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalMileageCB__c+=cne.Adj_Mileage__c;
	    			userMetric.TotalMileageCB__c+=cne.Adj_Mileage__c;
	    		}
	    		if(cne.Adj_Expenses__c!=null)
	    		{
	    			if(areaMetric!=null)
	    				areaMetric.TotalExpensesCB__c+=cne.Adj_Expenses__c;
	    			userMetric.TotalExpensesCB__c+=cne.Adj_Expenses__c;
	    		}
    		} 		
    	}
    	}
    	catch(Exception e){

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'support@isyscm.com'};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Error Processing BatchCaseNoteEntryMetrics');
			mail.setPlainTextBody
			('The BatchCaseNoteEntryMetrics job failed. Some records may have been processed:' + '\n' + 'Message: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString() + '');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			
		}
    }
    global void finish (Database.Batchablecontext BC)
    {
    	upsert keyMap.values() ExternalId__c;
    }
}