public class CaseNoteItem {
	public boolean showMinMaxValues {get;set;}
	public integer rowIndex {get;set;}
	public double billingMin {get;set;}
	public double billingMax {get;set;}
	public Case_Note_Entry__c entry {get;set;}
	
	public CaseNoteItem() {
		showMinMaxValues = false;
		rowIndex = 0;
		billingMin = 0;
		billingMax = 0;
		entry = new Case_Note_Entry__c();
	}	
	
	static testMethod void testInstantiateCaseNoteItem() {
		CaseNoteItem item = new CaseNoteItem();
		
		System.assert(item.rowIndex == 0,'Expected row index to be zero.');
		System.assert(item.billingMin == 0,'Expected billing min value to be zero.');
		System.assert(item.billingMax == 0,'Expected billing max value to be zero.');
		System.assert(item.showMinMaxValues == false, 'Expected show min/max values to be false.');
		System.assert(item.entry.Id == null, 'Expected case note entry to be a new case note object.');
	}
}