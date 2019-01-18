public class CG_OpportunityHandler{

    public static void handleOpportunities(set<ID> oIDs){
        
    List<Opportunity> toProcess = new List<Opportunity>();
    List<Invoice_Item__c> newItems = new List<Invoice_Item__c>();
    List<Invoice_Item__c> updateItems = new List<Invoice_Item__c>();
    
    List<User> userList = new List<User>();
    Map<String,String> userInitialsMap = new Map<String,String>();

    //Query Opportunities
    toProcess = [Select ID, Name, QBServiceItem__c,QB_Service_Item__c, B_Mileage_Miles_Total__c, Mileage_Rate__c,CRR_Assigned__c, QBJurisdiction__c, Total_Expenses__c, Service_Tax_Total__c, B_Non_Professional_Hours_Total__c,
    Travel_Wait_Rate__c, Professional_Rate__c, B_Professional_Hours_Total__c, Rush_Mileage_Rate__c, B_Rush_Mileage_Miles_Total__c, Rush_Travel_Wait_Rate__c,
    B_Rush_Non_Professional_Hours_Total__c, Report_Name__c, Service_Date_Thru__c, Rush_Professional_Rate__c, B_Rush_Professional_Hours_Total__c , CRR_Supervisor__c, Jurisdiction__c, Employee__r.Id, Employee__r.Name, Account.Name, Account.Owner.QB_Initials__c,   
    (Select ID,Service_Name__c, Account__c, Case_Report__c, Class__c, Employee_Name__c, Rate__c, Rep__c, QB_ServiceItem_check__c, Report_Name__c, Service_Date__c, Time_Units__c, CRR_Supervisor__c from Invoice_Items__r) from Opportunity Where ID in: oIDs];
    
    //QUery all users
    userList = [Select ID, Name, QB_Initials__c from User];
    
    for(User u: userList)
        userInitialsMap.put(u.Name,u.QB_Initials__c);
    
    for(Opportunity opp:toProcess){
            String crr = userInitialsMap.get(opp.CRR_Assigned__c);
            
            list<Invoice_Item__c> items = opp.Invoice_Items__r;
            map<String, Invoice_Item__c> itemMap = new map<String,Invoice_Item__c>();
            
            
            //Search for specific line with QB_ServiceItem_check__c is true
            for(Invoice_Item__c qbi : items){
                if(qbi.QB_ServiceItem_check__c == true)
                    itemMap.put(qbi.Service_Name__c, qbi);
            }
            
            
            System.debug('-------------------' + opp.B_Rush_Professional_Hours_Total__c + '----------------------');
            System.debug(opp.QBServiceItem__c);
            
            //Handle QB Service Item
            Invoice_Item__c qbservice = buildInvItem(opp, opp.QBServiceItem__c, opp.Professional_Rate__c, opp.B_Professional_Hours_Total__c,crr);
            
            /*if(opp.B_Rush_Professional_Hours_Total__c > 0){
                qbservice.Service_Name__c = 'MCM-On Site';
            }*/
        
        	if(qbservice.Service_Name__c == 'RUSH-MCM-On Site' || qbservice.Service_Name__c.toUpperCase().startsWith('RUSH')){
                qbservice.Service_Name__c = 'MCM-On Site';
            }
            
            qbservice.QB_ServiceItem_check__c = true;
        
            if(itemMap.containsKey(opp.QBServiceItem__c)){
                //Update that specific Item
                qbservice.id = itemMap.remove(opp.QBServiceItem__c).Id;
                updateItems.add(qbservice);
            }else{
                //Create New Item
                newItems.add(qbservice);
            }
            
            
            for(Invoice_Item__c i : items){
                if(i.QB_ServiceItem_check__c == false)
                    itemMap.put(i.Service_Name__c, i);
            }
    
            //HANDLE RUSH MCM
            Invoice_Item__c rushmcm = buildInvItem(opp, 'RUSH-MCM-On Site', opp.Rush_Professional_Rate__c, opp.B_Rush_Professional_Hours_Total__c,crr);
        	rushmcm.Service_Date__c = opp.Service_Date_Thru__c;
            if(itemMap.containsKey('RUSH-MCM-On Site')){
                //Update that specific Item
                rushmcm.id = itemMap.get('RUSH-MCM-On Site').Id;
                updateItems.add(rushmcm);
            }else{
                //Create New Item
                newItems.add(rushmcm);
            }
            
            //Handle RUSH Travel
            Invoice_Item__c rushtw = buildInvItem(opp, 'RUSH-Travel/Wait', opp.Rush_Travel_Wait_Rate__c, opp.B_Rush_Non_Professional_Hours_Total__c,crr);
            if(itemMap.containsKey('RUSH-Travel/Wait')){
                //Update that specific Item
                rushtw.id = itemMap.get('RUSH-Travel/Wait').Id;
                updateItems.add(rushtw);
            }else{
                //Create New Item
                newItems.add(rushtw);
            }
            
            //Hasndle RUSH-Mileage
            Invoice_Item__c rushmi = buildInvItem(opp, 'RUSH-Mileage', opp.Rush_Mileage_Rate__c, opp.B_Rush_Mileage_Miles_Total__c,crr);
            if(itemMap.containsKey('RUSH-Mileage')){
                //Update that specific Item
                rushmi.id = itemMap.get('RUSH-Mileage').Id;
                updateItems.add(rushmi);
            }else{
                //Create New Item
                newItems.add(rushmi);
            }
            
            //Handle Travel/Wait
            Invoice_Item__c tw = buildInvItem(opp, 'Travel/Wait', opp.Travel_Wait_Rate__c, opp.B_Non_Professional_Hours_Total__c,crr);
            if(itemMap.containsKey('Travel/Wait')){
                //Update that specific Item
                tw.id = itemMap.get('Travel/Wait').Id;
                updateItems.add(tw);
            }else{
                //Create New Item
                newItems.add(tw);
            }
            
            //Handle Mileage
            Invoice_Item__c mil = buildInvItem(opp,'Mileage' , opp.Mileage_Rate__c, opp.B_Mileage_Miles_Total__c,crr);
            if(itemMap.containsKey('Mileage')){
                //Update that specific Item
                mil.id = itemMap.get('Mileage').Id;
                updateItems.add(mil);
            }else{
                //Create New Item
                newItems.add(mil);
            }
            //Handle Expenses
            Invoice_Item__c exp = buildInvItem(opp, 'Expenses', opp.Total_Expenses__c, 1,crr);
            if(itemMap.containsKey('Expenses')){
                //Update that specific Item
                exp.id = itemMap.get('Expenses').Id;
                updateItems.add(exp);
            }else{
                //Create New Item
                newItems.add(exp);
            }
            
            //Handle Service Tax
            Invoice_Item__c tax = buildInvItem(opp, 'Service Tax', opp.Service_Tax_Total__c, 1,crr);
            if(itemMap.containsKey('Service Tax')){
                //Update that specific Item
                tax.id = itemMap.get('Service Tax').Id;
                updateItems.add(tax);
            }else{
                //Create New Item
                newItems.add(tax);
            }
            
            //Set Process B flag to "1" - Ready to Sync
             opp.Process_B__c = 1;
    }

        System.debug('newItems: '+ newItems);
		System.debug('updateItems: '+ updateItems);
        
    if(newItems.size() > 0)
        insert newItems;

    if(updateItems.size() > 0)
        update updateitems;

        update toProcess;
   
    }

    public static Invoice_Item__c buildInvItem(Opportunity opp, String sName, Decimal r, Decimal t, String ini){
        Invoice_Item__c i = new Invoice_Item__c();
            i.Service_Name__c = sName;
            i.Rate__c = r;
            i.Time_Units__c = t;
            i.Account__c = opp.Account.Name;
            i.Case_Report__c= opp.id;
            i.Class__c = opp.QBJurisdiction__c;
            i.Employee_Name__c = opp.Employee__r.Name;
            i.Rep__c = ini;
            i.Report_Name__c = opp.Report_Name__c.remove('Report-');
            i.CRR_Supervisor__c = opp.CRR_Supervisor__c;
        
        return i;
        
    }
       
    public static void handleTimesheets(set<ID> tIDs){ 
    	List<Opportunity> toProcess = new List<Opportunity>();
    	List<Timesheet__c> newTime = new List<Timesheet__c>();
    	List<Timesheet__c> updateTime = new List<Timesheet__c>();
       	
        
        //Query Opportunities
        toProcess =[SELECT id, A_Note_Approval_Date_Time__c, Employee__r.Id, Employee__r.Name, (SELECT Id, Approved_Units__c, Nurse_Name__c,Case_Report_Opportunity__c, Date_Approved__c,
        Line_Type__c, QB_Error__c, QB_Id__c,QBDuration__c, User__c from Timesheets__r),(SELECT id, CreatedBy.Name, CreatedBy.QB_Username__c, CreatedById, TotalHoursA__c, 
        Report__r.id, Report__r.A_Note_Approval_Date_Time__c, Professional_Hours__c, Travel_Wait_Hours__c from Case_Note_Entries__r) FROM Opportunity WHERE ID in: tIDs];
        
        for(Opportunity opp: toProcess){
            List<Case_Note_Entry__c> entry = opp.Case_Note_Entries__r;
            List<Timesheet__c> ts = opp.Timesheets__r; 
            Set<User> eIDs = new Set<User>();
        	
            
            //Identify all different employees 
            for(Case_Note_Entry__c e: entry){
                eIDs.add(e.CreatedBy);
            }
            
            //Map of existing time sheets for Users
            map<ID,Timesheet__c> proMap = new map<ID,Timesheet__c>();
            map<ID,Timesheet__c> traMap = new map<ID,Timesheet__c>();
            for(Timesheet__c t:ts){
                if(t.Line_Type__c == 'Travel/Wait')
                    traMap.put(t.User__c, t);
                    
                if(t.Line_Type__c == 'MCM-On Site')
                    proMap.put(t.User__c, t);
            }
            
            
            
            for(User eId : eIDs){ 
                
                Decimal pHours = 0;
            	Decimal tHours = 0;
                Timesheet__c pro = new Timesheet__c();
                
                if(proMap.containsKey(eID.Id))
                    pro = proMap.get(eID.Id);
                
                Timesheet__c tra = new Timesheet__c();
                
                if(traMap.containsKey(eId.Id))
                    tra = traMap.get(eId.Id);
                
                for(Case_Note_Entry__c e2 : entry){
                   
                    if(e2.CreatedBy == eID){
                        
                        if(e2.Professional_Hours__c != null){
                            
                        	pHours += e2.Professional_Hours__c;
                            
                        }else{
                            
                            pHours = pHours;
                            
                        }
                        if(e2.Travel_Wait_Hours__c != null){
                            
                    		tHours += e2.Travel_Wait_Hours__c; 
                            
                        }else{
                            
                            tHours=tHours;
                            
                        }
                    } 
				}
                
                pro = buildTs(opp, eId, 'MCM-On Site', pHours, pro);
                tra = buildTs(opp, eId, 'Travel/Wait', tHours, tra);
                
                if(pro.Id == null){
                    newTime.add(pro);
                }else{
                    updateTime.add(pro);
                }
                
                if(tra.Id == null){
                    newTime.add(tra);
                }else{
                    updateTime.add(tra);
                }
            }
            
            //Set Process A flag to "1" - Ready to Sync
             opp.Process_A__c = 1;
        }
        
        if(newTime.size() > 0)
            insert newTime;
        
        if(updateTime.size() > 0)
            update updateTime;
            
        if(newTime.size() > 0 || updateTime.size() > 0)
            update toProcess;
        
    }
    
    public static Timesheet__c buildTs(Opportunity opp, User ce, String tName, Decimal u, Timesheet__c ts ){
        Timesheet__c t = new Timesheet__c();
        Decimal i = u*60;
            t.Approved_Units__c = u;
        	t.QBDuration__c = 'PT'+i.round()+'M';
            t.Nurse_Name__c = ce.QB_Username__c;
        	t.Line_Type__c = tName;
            t.Case_Report_Opportunity__c = opp.id;
            t.Date_Approved__c = opp.A_Note_Approval_Date_Time__c.date();
        	t.Employee__c = opp.Employee__r.Name;
        	t.User__c = ce.Id;
        	
        	if(ts.Id != null)
        	    t.Id = ts.Id;
        	
        return t;
        
    }
}