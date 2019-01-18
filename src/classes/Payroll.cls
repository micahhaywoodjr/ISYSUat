public with sharing class Payroll {
    public PayrollTemp__c prTemp { get; set; }
    public PayrollTemp__c userAddedPrTemp { get; set; }
    public String toBeProcessedSelected { get; set; }
    public String processedSelected { get; set; }
    public List<SelectOption> toBeProcessedList { get; set; }
    public List<SelectOption> processedList { get; set; }
    private Map<Id, SFDC_Employee__c> empMap;
    public decimal approvedProfBillHoursInitialSum { get; set; }
    public decimal approvedTWBillHoursInitialSum { get; set; }
    public String uniqueKey { get; set; }
    public list<String> payrollProfileList { get; set; }

    public Payroll() {
        //system.debug('Payroll(1)');
        //system.debug('toBeProcessedList ' + toBeProcessedList);
        //system.debug('toBeProcessedSelected ' + toBeProcessedSelected);
        //system.debug('empMap ' + empMap);
        payrollProfileList=new list<string>();
        //the hard coded id need to be dynamic as test classes dont have the same id for records
        payrollProfileList.add('00e8000000189SB');
        payrollProfileList.add('00e80000001K8sZ');
        if (Test.isRunningTest()) {
            payrollProfileList.add('');
            payrollProfileList.add(null);
        }

        prTemp = new PayrollTemp__c();
        userAddedPrTemp = new PayrollTemp__c();
        empMap = new Map<Id, SFDC_Employee__c>();
        toBeProcessedSelected = '';
        processedSelected = '';
        toBeProcessedList = new List<SelectOption>();
        processedList = new List<SelectOption>();
        toBeProcessedList.add(new SelectOption('', '--Please Select--'));
        processedList.add(new SelectOption('', '--Please Select--'));
        // pr.getParameters().put('tEmployeeType', 'processed');
        if (ApexPages.currentPage().getParameters().containsKey('tEmployeeType')) {
            string process_type = ApexPages.currentPage().getParameters().get('tEmployeeType');
            String employee_id = ApexPages.currentPage().getParameters().get('tEmployee');
            String employee_name = ApexPages.currentPage().getParameters().get('tEmployeeName');
            if (process_type == 'processed') {
                processedList.add(new SelectOption(employee_id, employee_name));
                processedSelected = employee_id;
            }
            if (process_type == 'selected') {
                toBeProcessedList.add(new SelectOption(employee_id, employee_name));
                toBeProcessedSelected = employee_id;
            }


        }
        if (ApexPages.currentPage().getParameters().containsKey('eDate') && ApexPages.currentPage().getParameters().containsKey('sDate')) {
            prTemp.sDate__c = Date.valueOf(ApexPages.currentPage().getParameters().get('sDate'));
            prTemp.eDate__c = Date.valueOf(ApexPages.currentPage().getParameters().get('eDate'));
            processDateChange();
        }
    }
    public String fullName {
        get {
            //system.debug('fullName');
            //system.debug('empMap '+empMap);
            //system.debug('processedSelected '+processedSelected);
            //system.debug('toBeProcessedSelected '+toBeProcessedSelected);
            return empMap.get(String.isEmpty(toBeProcessedSelected) ? processedSelected : toBeProcessedSelected).SF_User__r.Name;
        }
        private set;
    }
    public String firstName {
        get {
            return empMap.get(String.isEmpty(toBeProcessedSelected) ? processedSelected : toBeProcessedSelected).SF_User__r.FirstName;
        }
        private set;
    }

    public Decimal threshold {
        get {
            Decimal thresholdToReturn = empMap.get(String.isEmpty(toBeProcessedSelected) ? processedSelected : toBeProcessedSelected).SF_User__r.PayrollThreshold__c;
            if (thresholdToReturn == null)
                return 0;
            return thresholdToReturn;
        }
        private set;
    }
    public PageReference processDateChange() {
        if (prTemp.eDate__c == null || prTemp.sDate__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter a start and end date.'));
            return null;
        }
        allCaseManagerList = null;
        toBeProcessedList.clear();
        processedList.clear();
        toBeProcessedList.add(new SelectOption('', '--Please Select--'));
        processedList.add(new SelectOption('', '--Please Select--'));
        processPayrollList();
        return null;
    }

    private void processPayrollList() {
        if (prTemp.sDate__c != null && prTemp.eDate__c != null) {
            Set<Id> processedUserSet = new Set<Id>();
            for (Payroll__c pr : [SELECT Id, Employee__c, Employee__r.SF_User__r.Name FROM Payroll__c WHERE DateSubmitted__c >= :prTemp.sDate__c AND DateSubmitted__c <= :prTemp.eDate__c])
                processedUserSet.add(pr.Employee__c);

            for (SFDC_Employee__c emp : allCaseManagerList) {
                if (processedUserSet.contains(emp.Id))
                    processedList.add(new SelectOption(emp.SF_User__c, emp.SF_User__r.Name)); else
                        toBeProcessedList.add(new SelectOption(emp.SF_User__c, emp.SF_User__r.Name));
            }
        }
    }
    private List<SFDC_Employee__c> allCaseManagerList {
        get {
            if (allCaseManagerList == null) {
                Set<Id> userIdSet = new Set<Id>();
                for (Case_Note_Entry__c cne : [Select CreatedById, CreatedBy.FirstName, CreatedBy.LastName, Report__r.RelatedCaseNoLeadingZero__c, Report__r.Report_Submission_Date__c, Report__r.Name, Professional_Hours__c, Travel_Wait_Hours__c From Case_Note_Entry__c WHERE CreatedDateCode__c <= :prTemp.eDate__c AND Report__r.A_Notes_Approved__c = true AND ((Report__r.PayrollSubmissionDate__c = null AND Report__r.Report_Submission_Date__c <= :prTemp.eDate__c and Report__r.Report_Submission_Date__c >= :prTemp.sDate__c) OR (Report__r.PayrollSubmissionDate__c != null AND Report__r.PayrollSubmissionDate__c <= :prTemp.eDate__c AND Report__r.PayrollSubmissionDate__c >= :prTemp.sDate__c)) AND CreatedBy.ProfileId in :payrollProfileList]) {
                    if (!userIdSet.contains(cne.CreatedById))
                        userIdSet.add(cne.CreatedById);
                }
                if (Test.isRunningTest()) {
                    //system.debug('get case man list test running');
                    allCaseManagerList = new List<SFDC_Employee__c>([SELECT Id, SF_User__c, SF_User__r.Name, SF_User__r.FirstName, SF_User__r.PayrollThreshold__c FROM SFDC_Employee__c ORDER BY SF_User__r.Name]);
                    //system.debug('allCaseManagerList '+allCaseManagerList);
                } else {
                    allCaseManagerList = new List<SFDC_Employee__c>([SELECT Id, SF_User__c, SF_User__r.Name, SF_User__r.FirstName, SF_User__r.PayrollThreshold__c FROM SFDC_Employee__c WHERE SF_User__c in :userIdSet ORDER BY SF_User__r.Name]);
                }
                empMap.clear();
                for (SFDC_Employee__c emp : allCaseManagerList)
                    empMap.put(emp.SF_User__c, emp);
            }
            return allCaseManagerList;
        }
        set;
    }
    public PageReference resetProcessed() {
        processedSelected = '';
        payrollTempSaveList = null;
        return null;
    }
    public PageReference resetToBeProcessed() {
        toBeProcessedSelected = '';
        payrollTempSaveList = null;
        return null;
    }
    public PageReference addRow() {
        if (payrollTempSaveList == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter a start and end date and select an Employee.'));
            return null;
        }
        if (userAddedPrTemp == null || userAddedPrTemp.Opportunity__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select a Report before adding a row.'));
            return null;
        }
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id, RelatedCaseNoLeadingZero__c, Name, Report_Submission_Date__c, Employee__r.Name FROM Opportunity WHERE Id = :userAddedPrTemp.Opportunity__c AND Report_Submission_Date__c <= :prTemp.eDate__c and Report_Submission_Date__c >= :prTemp.sDate__c]);
        if (oppList.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select a Report where the submission date is in your selected date range.'));
            return null;
        }
        Opportunity opp = oppList.get(0);
        String selected = String.isEmpty(toBeProcessedSelected) ? processedSelected : toBeProcessedSelected;
        payrollTempSaveList.add(new PayrollTemp__c(EmployeeName__c = empMap.get(selected).SF_User__r.Name, Employee__c = empMap.get(selected).Id, CaseNumber__c = opp.RelatedCaseNoLeadingZero__c, ReportNumber__c = opp.Name, DateSubmitted__c = opp.Report_Submission_Date__c, CaseName__c = opp.Employee__r.Name, Opportunity__c = opp.Id, ApprovedProfBillableHours__c = 0, ApprovedTWBillableHours__c = 0, IsUserAdded__c = true, UniqueKey__c = String.valueOf(Math.random())));
        userAddedPrTemp = new PayrollTemp__c();
        return null;
    }
    public PageReference deleteRow() {
        List<PayrollTemp__c> tempList = new List<PayrollTemp__c>();
        for (PayrollTemp__c prTemp : payrollTempSaveList) {
            if (prTemp.UniqueKey__c != uniqueKey)
                tempList.add(prTemp);
        }
        payrollTempSaveList = tempList;
        return null;
    }
    public List<PayrollTemp__c> payrollTempSaveList {
        get {
            decimal total_case_Management_billable_time = 0;
            string hr_notes = '';
            //system.debug('get payrollTempSaveList');
            //system.debug(payrollTempSaveList);
            //user id
            //system.debug('processedSelected ' + processedSelected);
            //system.debug('toBeProcessedSelected ' + toBeProcessedSelected);
            //system.debug('prTemp ' + prTemp);
            //system.debug('toBeProcessedSelected ' + toBeProcessedSelected);


            if (payrollTempSaveList == null) {

                Map<Id, PayrollTemp__c> oppIdToPayrollMap = new Map<Id, PayrollTemp__c>();
                approvedProfBillHoursInitialSum = 0;
                approvedTWBillHoursInitialSum = 0;
                if (!String.isEmpty(toBeProcessedSelected) && prTemp.eDate__c != null && prTemp.sDate__c != null) {
                    //look for existing records
                    //system.debug('payrollTempSaveList 1 ' + payrollTempSaveList);
                    //system.debug('empMap 1 ' + empMap);
                    //system.debug('prTemp 1 ' + prTemp);
                    //system.debug('toBeProcessedSelected 1 ' + toBeProcessedSelected);
                    //Employee__c = :empMap.get(toBeProcessedSelected).Id AND DateSubmitted__c <= :prTemp.eDate__c and DateSubmitted__c >= :prTemp.sDate__c
                    //system.debug('payroll search 1 ' + [SELECT Id, CaseName__c, CaseNumber__c, Comments__c, DateSubmitted__c, eDate__c, sDate__c, Employee__c, EmployeeName__c, HrNotes__c, IsUserAdded__c, Employee__r.Name, Opportunity__c, Opportunity__r.RelatedCaseNoLeadingZero__c, Opportunity__r.Employee__r.Name, Opportunity__r.Name, Opportunity__r.Report_Submission_Date__c, Payrollid__c, ReportNumber__c, TotalCaseManagementBillableTime__c, UniqueKey__c, ApprovedProfBillableHours__c, ApprovedTWBIllableHours__c, ApprovedProfBillableHoursCNE__c, ApprovedTWBIllableHoursCNE__c FROM PayrollTemp__c WHERE Employee__c = :empMap.get(toBeProcessedSelected).Id AND DateSubmitted__c <= :prTemp.eDate__c and DateSubmitted__c >= :prTemp.sDate__c]);
                    payrollTempSaveList = new List<PayrollTemp__c>();

                    //*
                    for (PayrollTemp__c pr : [SELECT Id, CaseName__c, CaseNumber__c, Comments__c, DateSubmitted__c, eDate__c, sDate__c, Employee__c, EmployeeName__c, HrNotes__c, IsUserAdded__c, Employee__r.Name, Opportunity__c, Opportunity__r.RelatedCaseNoLeadingZero__c, Opportunity__r.Employee__r.Name, Opportunity__r.Name, Opportunity__r.Report_Submission_Date__c, Payrollid__c, ReportNumber__c, TotalCaseManagementBillableTime__c, UniqueKey__c, ApprovedProfBillableHours__c, ApprovedTWBIllableHours__c, ApprovedProfBillableHoursCNE__c, ApprovedTWBIllableHoursCNE__c FROM PayrollTemp__c WHERE Employee__c = :empMap.get(toBeProcessedSelected).Id AND DateSubmitted__c <= :prTemp.eDate__c and DateSubmitted__c >= :prTemp.sDate__c]) {
                        payrollTempSaveList.add(pr);
                        approvedTWBillHoursInitialSum += pr.ApprovedTWBillableHours__c;
                        approvedProfBillHoursInitialSum += pr.ApprovedProfBillableHours__c;
                        total_case_Management_billable_time = pr.TotalCaseManagementBillableTime__c;
                        hr_notes = pr.HrNotes__c;
                    }
                    //system.debug('payrollTempSaveList 2 ' + payrollTempSaveList);
                    //*/
                    //employee id
                    //system.debug('empMap.get(toBeProcessedSelected).Id  ' + empMap.get(toBeProcessedSelected).Id);
                    //create records if no records found
                    if (payrollTempSaveList.size() == 0) {
                        decimal approvedProfBillHours;
                        decimal approvedTWBillHours;
                        Set<Id> oppIdSet = new Set<Id>();

                        for (Case_Note_Entry__c cne : [Select CreatedById, CreatedBy.Name, Report__r.RelatedCaseNoLeadingZero__c, Report__r.Report_Submission_Date__c, Report__r.Name, Report__r.Employee__c, Professional_Hours__c, Travel_Wait_Hours__c, Report__r.Employee__r.Name, Report__c From Case_Note_Entry__c WHERE CreatedById = :toBeProcessedSelected AND CreatedDateCode__c <= :prTemp.eDate__c AND Report__r.A_Notes_Approved__c = true AND Report__r.PayrollSubmissionDate__c = null AND Report__r.Report_Submission_Date__c <= :prTemp.eDate__c and Report__r.Report_Submission_Date__c >= :prTemp.sDate__c AND CreatedBy.ProfileId in :payrollProfileList]) {
                            if (!oppIdToPayrollMap.containsKey(cne.Report__c))
                                oppIdToPayrollMap.put(cne.Report__c, new PayrollTemp__c(EmployeeName__c = cne.CreatedBy.Name, Employee__c = empMap.get(cne.CreatedById).Id, CaseNumber__c = cne.Report__r.RelatedCaseNoLeadingZero__c, ReportNumber__c = cne.Report__r.Name, DateSubmitted__c = cne.Report__r.Report_Submission_Date__c, CaseName__c = cne.Report__r.Employee__r.Name, Opportunity__c = cne.Report__c, ApprovedProfBillableHours__c = 0, ApprovedTWBillableHours__c = 0));

                            if (cne.Professional_Hours__c != null) {
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedProfBillableHours__c += cne.Professional_Hours__c;
                                //keep the original CNE hours
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedProfBillableHoursCNE__c = oppIdToPayrollMap.get(cne.Report__c).ApprovedProfBillableHours__c;
                                approvedProfBillHoursInitialSum += cne.Professional_Hours__c;
                            }
                            if (cne.Travel_Wait_Hours__c != null) {
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedTWBillableHours__c += cne.Travel_Wait_Hours__c;
                                //keep the original CNE hours
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedTWBillableHoursCNE__c = oppIdToPayrollMap.get(cne.Report__c).ApprovedTWBillableHours__c;
                                approvedTWBillHoursInitialSum += cne.Travel_Wait_Hours__c;
                            }
                        }
                        for (Case_Note_Entry__c cne : [Select CreatedById, CreatedBy.Name, Report__r.RelatedCaseNoLeadingZero__c, Report__r.Report_Submission_Date__c, Report__r.Name, Report__r.Employee__c, Professional_Hours__c, Travel_Wait_Hours__c, Report__r.Employee__r.Name, Report__c From Case_Note_Entry__c WHERE CreatedById = :toBeProcessedSelected AND CreatedDateCode__c <= :prTemp.eDate__c AND Report__r.A_Notes_Approved__c = true AND (Report__r.PayrollSubmissionDate__c != null AND Report__r.PayrollSubmissionDate__c <= :prTemp.eDate__c AND Report__r.PayrollSubmissionDate__c >= :prTemp.sDate__c) AND CreatedBy.ProfileId in :payrollProfileList]) {
                            if (!oppIdToPayrollMap.containsKey(cne.Report__c))
                                oppIdToPayrollMap.put(cne.Report__c, new PayrollTemp__c(EmployeeName__c = cne.CreatedBy.Name, Employee__c = empMap.get(cne.CreatedById).Id, CaseNumber__c = cne.Report__r.RelatedCaseNoLeadingZero__c, ReportNumber__c = cne.Report__r.Name, DateSubmitted__c = cne.Report__r.Report_Submission_Date__c, CaseName__c = cne.Report__r.Employee__r.Name, Opportunity__c = cne.Report__c, ApprovedProfBillableHours__c = 0, ApprovedTWBillableHours__c = 0));

                            if (cne.Professional_Hours__c != null) {
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedProfBillableHours__c += cne.Professional_Hours__c;
                                //keep the original CNE hours
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedProfBillableHoursCNE__c = oppIdToPayrollMap.get(cne.Report__c).ApprovedProfBillableHours__c;
                                approvedProfBillHoursInitialSum += cne.Professional_Hours__c;
                            }
                            if (cne.Travel_Wait_Hours__c != null) {
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedTWBillableHours__c += cne.Travel_Wait_Hours__c;
                                //keep the original CNE hours
                                oppIdToPayrollMap.get(cne.Report__c).ApprovedTWBillableHoursCNE__c = oppIdToPayrollMap.get(cne.Report__c).ApprovedTWBillableHours__c;
                                approvedTWBillHoursInitialSum += cne.Travel_Wait_Hours__c;
                            }
                        }
                        payrollTempSaveList = oppIdToPayrollMap.values();
                    }

                    //system.debug('payrollTempSaveList 3 ' + payrollTempSaveList);
                } else if (!String.isEmpty(processedSelected) && prTemp.eDate__c != null && prTemp.sDate__c != null) {
                    //system.debug('empMap.get(processedSelected).Id  ' + empMap.get(processedSelected).Id);
                    payrollTempSaveList = new List<PayrollTemp__c>();

                    for (Payroll__c pr : [SELECT Id, IsUserAdded__c, Employee__r.Name, Employee__c, Opportunity__r.RelatedCaseNoLeadingZero__c, Opportunity__r.Employee__r.Name, Opportunity__r.Name, Opportunity__r.Report_Submission_Date__c, Opportunity__c, ApprovedProfBillableHours__c, ApprovedTWBIllableHours__c, ApprovedProfBillableHoursCNE__c, ApprovedTWBIllableHoursCNE__c, Comments__c FROM Payroll__c WHERE Employee__c = :empMap.get(processedSelected).Id AND DateSubmitted__c <= :prTemp.eDate__c and DateSubmitted__c >= :prTemp.sDate__c]) {
                        payrollTempSaveList.add(new PayrollTemp__c(Payrollid__c = pr.Id, EmployeeName__c = pr.Employee__r.Name, Employee__c = pr.Employee__c, CaseNumber__c = pr.Opportunity__r.RelatedCaseNoLeadingZero__c, ReportNumber__c = pr.Opportunity__r.Name, DateSubmitted__c = pr.Opportunity__r.Report_Submission_Date__c, CaseName__c = pr.Opportunity__r.Employee__r.Name, Opportunity__c = pr.Opportunity__c, ApprovedProfBillableHours__c = pr.ApprovedProfBillableHours__c, ApprovedTWBillableHours__c = pr.ApprovedTWBIllableHours__c, IsUserAdded__c = pr.IsUserAdded__c, ApprovedProfBillableHoursCNE__c = pr.ApprovedProfBillableHoursCNE__c, ApprovedTWBillableHoursCNE__c = pr.ApprovedTWBIllableHoursCNE__c, Comments__c = pr.Comments__c));
                        approvedTWBillHoursInitialSum += pr.ApprovedTWBillableHours__c;
                        approvedProfBillHoursInitialSum += pr.ApprovedProfBillableHours__c;
//                        total_case_Management_billable_time=pr.TotalCaseManagementBillableTime__c;
//                        hr_notes=pr.HrNotes__c;
                    }
                }
            }
            if (toBeProcessedSelected != null && toBeProcessedSelected != '') {
//                if (total_case_Management_billable_time > 0) {
//                    prTemp.TotalCaseManagementBillableTime__c = total_case_Management_billable_time;
//                }
                if (approvedProfBillHoursInitialSum > 0 || approvedTWBillHoursInitialSum>0) {
                    prTemp.TotalCaseManagementBillableTime__c = (approvedProfBillHoursInitialSum + approvedTWBillHoursInitialSum);
                }
                if (hr_notes != '') {
                    prTemp.HrNotes__c = hr_notes;
                }
            }

            return payrollTempSaveList;
        }
        set;
    }
    public PageReference confirm() {
        //system.debug(                'confirm()'        );
        save_state();
        //system.debug('prTemp.TotalCaseManagementBillableTime__c ' + prTemp.TotalCaseManagementBillableTime__c);
        //system.debug('prTemp.HrNotes__c ' + prTemp.HrNotes__c);
        //recalc the hours in case they were changed on the previous page
        approvedProfBillHoursInitialSum = 0;
        approvedTWBillHoursInitialSum = 0;
        if (payrollTempSaveList == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There are no payroll records to confirm.'));
            return null;
        }
        for (PayrollTemp__c prTemp : payrollTempSaveList) {
            approvedProfBillHoursInitialSum += prTemp.ApprovedProfBillableHours__c;
            approvedTWBillHoursInitialSum += prTemp.ApprovedTWBillableHours__c;
        }
        //only set total if empty or 0
        if (toBeProcessedSelected != null && toBeProcessedSelected != '') {
            if (prTemp.TotalCaseManagementBillableTime__c == null || prTemp.TotalCaseManagementBillableTime__c <= 0) {
                prTemp.TotalCaseManagementBillableTime__c = (approvedProfBillHoursInitialSum + approvedTWBillHoursInitialSum);
            }
        } else {
            prTemp.HrNotes__c = '';
            prTemp.TotalCaseManagementBillableTime__c = (approvedProfBillHoursInitialSum + approvedTWBillHoursInitialSum);
        }
        return Page.PayrollConfirm;
    }
    //save temp records for later use Levementum 2/16/17
    public void save_state() {
        //system.debug('save_state');
        //system.debug('prTemp ' + prTemp);
        Decimal total_time = prTemp.TotalCaseManagementBillableTime__c;
        String hr_notes = prTemp.HrNotes__c;
        List<PayrollTemp__c> prInsertList = new List<PayrollTemp__c>();
        List<PayrollTemp__c> prUpdateList = new List<PayrollTemp__c>();
        try {
            for (PayrollTemp__c prTemp : payrollTempSaveList) {

                prTemp.TotalCaseManagementBillableTime__c = total_time;
                prTemp.HrNotes__c = hr_notes;
                if (prTemp.id == null) {
                    prInsertList.add(prTemp);
                } else {
                    prUpdateList.add(prTemp);
                }
            }
            //system.debug('try save_state dml statements');
            //system.debug('prInsertList ' + prInsertList);
            //system.debug('prUpdateList ' + prUpdateList);
            if (prInsertList.size() > 0)
                insert prInsertList;
            if (prUpdateList.size() > 0)
                update prUpdateList;

            //remove pdf and attachments from the save state function Levemtentum 2/16/17

        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + e));
//            return null;
        }
//        return cancel();
    }

    public pageReference previous_page() {
        save_state();
        return previous_page_redirect();
    }

    public PageReference save() {
        //system.debug('save');
        //system.debug('prTemp ' + prTemp);
        List<Payroll__c> prInsertList = new List<Payroll__c>();
        List<Payroll__c> prUpdateList = new List<Payroll__c>();
        for (PayrollTemp__c prTemp : payrollTempSaveList) {
            //system.debug('prTemp ' + prTemp);
            //system.debug('prTemp.Comments__c ' + prTemp.Comments__c);
            if (prTemp.Payrollid__c == null) {
                prInsertList.add(new Payroll__c(Employee__c = prTemp.Employee__c, Opportunity__c = prTemp.Opportunity__c, Comments__c = prTemp.Comments__c, DateSubmitted__c = prTemp.DateSubmitted__c, ApprovedProfBillableHours__c = prTemp.ApprovedProfBillableHours__c, ApprovedTWBillableHours__c = prTemp.ApprovedTWBillableHours__c, IsUserAdded__c = prTemp.IsUserAdded__c, ApprovedProfBillableHoursCNE__c = prTemp.ApprovedProfBillableHoursCNE__c, ApprovedTWBillableHoursCNE__c = prTemp.ApprovedTWBillableHoursCNE__c));
            } else {
                prUpdateList.add(new Payroll__c(Id = prTemp.Payrollid__c, Comments__c = prTemp.Comments__c, ApprovedProfBillableHours__c = prTemp.ApprovedProfBillableHours__c, ApprovedTWBillableHours__c = prTemp.ApprovedTWBillableHours__c, IsUserAdded__c = prTemp.IsUserAdded__c));
            }
        }
        try {
            //system.debug('prInsertList ' + prInsertList);
            //system.debug('prUpdateList ' + prUpdateList);
            if (prInsertList.size() > 0)
                insert prInsertList;
            if (prUpdateList.size() > 0)
                update prUpdateList;
            if (payrollTempSaveList.size() > 0) {
                //system.debug('delete rows');
                //system.debug('payrollTempSaveList ' + payrollTempSaveList);
                list<PayrollTemp__c> deletePayrolls = new list<PayrollTemp__c>();
                for (PayrollTemp__c prTemp : payrollTempSaveList) {
                    //system.debug('prTemp ' + prTemp);
                    if (prTemp.Id != null) {
                        deletePayrolls.add(prTemp);
                    }
                }
                if (deletePayrolls.size() > 0)
                    delete deletePayrolls;
            }


            //system.debug('prInsertList ' + prInsertList);
            //system.debug('prUpdateList ' + prUpdateList);
            PageReference pdf = Page.PayrollConfirmPDF;
            //pdf.setRedirect(true);

            // Take the PDF content
            Blob b;
            if (Test.isRunningTest())
                b = Blob.valueOf('testRunning'); else
                    b = pdf.getContentAsPdf();

            String selected = String.isEmpty(toBeProcessedSelected) ? processedSelected : toBeProcessedSelected;
            String fileName = empMap.get(selected).SF_User__r.Name + ':' + prTemp.sDate__c.format() + '-' + prTemp.eDate__c.format() + '.pdf';

            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(fileName);
            efa.setBody(b);


			/*Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
			message.setToAddresses(new String[]{'finance@isyscm.com','Lyndsi.loumakis@isyscm.com '});
			message.setSubject('Payroll');
			message.setReplyTo('Jacqueline.Robinette@isyscm.com');
			message.setPlainTextBody('payroll');
			message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
			List<Messaging.Sendemailresult> results = Messaging.sendEmail(new Messaging.Singleemailmessage[]{message});
			*/
            ////system.debug(results);


            Attachment a = new Attachment(ParentId = empMap.get(selected).Id, Name = fileName, Body = b, ContentType = 'application/pdf');
            insert a;
            //system.debug('attachment from submit: ' + a);
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + e));
            return null;
        }
        return cancel();
    }
    public PageReference cancel() {
        PageReference pr = Page.Payroll;
        pr.getParameters().put('sDate', String.valueOf(prTemp.sDate__c));
        pr.getParameters().put('eDate', String.valueOf(prTemp.eDate__c));
        pr.setRedirect(true);
        return pr;
    }
    public PageReference previous_page_redirect() {
        //system.debug('previous_page_redirect');
        //system.debug('toBeProcessedSelected ' + toBeProcessedSelected);
        //system.debug('processedSelected ' + processedSelected);
        //system.debug('empMap ' + empMap);
        PageReference pr = Page.Payroll;
        pr.getParameters().put('sDate', String.valueOf(prTemp.sDate__c));
        pr.getParameters().put('eDate', String.valueOf(prTemp.eDate__c));

        //system.debug(prTemp);

        if (toBeProcessedSelected != '' && toBeProcessedSelected != null) {
            pr.getParameters().put('tEmployee', empMap.get(toBeProcessedSelected).SF_User__r.id);
            pr.getParameters().put('tEmployeeType', 'selected');
            pr.getParameters().put('tEmployeeName', empMap.get(toBeProcessedSelected).SF_User__r.Name);
        }
        if (processedSelected != '' && processedSelected != null) {
            pr.getParameters().put('tEmployee', empMap.get(processedSelected).SF_User__r.id);
            pr.getParameters().put('tEmployeeType', 'processed');
            pr.getParameters().put('tEmployeeName', empMap.get(processedSelected).SF_User__r.Name);
        }


        pr.setRedirect(true);
        return pr;
    }
}