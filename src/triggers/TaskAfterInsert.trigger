trigger TaskAfterInsert on Task(after insert) {

	list<Task> tList = Trigger.new;

	if(Trigger.isAfter && Trigger.isInsert)
		CaseNoteEntryCreationAutomation.CaseNoteEntryHandler(Trigger.newMap.keySet());

}