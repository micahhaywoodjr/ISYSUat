public with sharing class RelateCommunicatonHistoryController {

	private Opportunity relatedOpp {get;set;}
	public Case_Note_Entry__c cne {get;set;}
	public List<Case_Note_Entry__c> cnes {get;set;}
	public List<TaskWrapper1> availableCommunicationHistories {get;set;}
	public List<AttachmentWrapper1> availableAttachments {get;set;}
	public List<AttachmentWrapper1> currentAttachments {get;set;}
	private Task selectedTask {get;set;}
	private List<Attachment> selectedAttachments {get;set;}
	public String selectedTaskId {get;set;}
	public Map<String,String> links {get;set;}



	public RelateCommunicatonHistoryController(ApexPages.StandardController std){
		cne = (Case_Note_Entry__c)std.getRecord();
		cne = [SELECT Report__c,Id,RelatedCommunicationHistories__c,RelatedAttachments__c FROM Case_Note_Entry__c WHERE Id = :cne.Id];
		availableAttachments = new List<AttachmentWrapper1>();
		//getRelatedRecords();
		//getCurrentAttachments();
	}

	public RelateCommunicatonHistoryController(Case_Note_Entry__c objCNE){
		cne = objCNE;

		availableAttachments = new List<AttachmentWrapper1>();
		availableCommunicationHistories = new List<TaskWrapper1>();
		getAttachmentLinks();
		//getRelatedRecords();
		//getCurrentAttachments();
	}

	public RelateCommunicatonHistoryController(List<Case_Note_Entry__c> objCNEs){
		cnes = objCNEs;
	}

	public RelateCommunicatonHistoryController(){
		String cneId = ApexPages.currentPage().getParameters().get('cneId');
		cne = [SELECT Report__c,Id FROM Case_Note_Entry__c WHERE Id = :cneId];
		availableAttachments = new List<AttachmentWrapper1>();
		//getRelatedRecords();
		//getCurrentAttachments();
	}

	public void getRelatedRecords(){
		availableCommunicationHistories = new List<TaskWrapper1>();
		if(cne.Report__c == null)
			return;

		for(Task t : [SELECT Id,Subject FROM Task WHERE WhatId = :cne.Report__c]){
			availableCommunicationHistories.add(new TaskWrapper1(t));
		}

	}

	public void getAvailableAttachments(){
		if(selectedTaskId == null)
			return;

		availableAttachments = new List<AttachmentWrapper1>();

		for(Attachment a : [SELECT Id,Name,ContentType FROM Attachment WHERE ParentId = :selectedTaskId]){
			availableAttachments.add(new AttachmentWrapper1(a));
		}


	}

	public Map<String,String> getAttachmentLinks(){
		links = new Map<String,String>();

		if(cne.RelatedAttachments__c != null){

			for(String s : cne.RelatedAttachments__c.split(',,')){
				String[] parts = s.split(';;');
				if(parts.size() < 2){
					continue;
				}
				links.put(parts[0],parts[1]);
			}

		}

		return links;
	}

	public Map<String,String> getCommunicationLinks(){
		Map<String,String> commlinks = new Map<String,String>();
		if(cne.RelatedCommunicationHistories__c != null){

			for(String s : cne.RelatedCommunicationHistories__c.split(',,')){
				String[] parts = s.split(';;');
				if(parts.size() < 2){
					continue;
				}
				commlinks.put(parts[0],parts[1]);
			}

		}

		return commlinks;
	}

	public class TaskWrapper1{
		public Boolean isSelected {get;set;}
		public Task a {get;set;}
		public String additionalToEmail {get; set;}
		public String recOrSent {get;set;}
		public String additionalToName {get; set;}

		public TaskWrapper1(Task a){
			try
			{
				this.a = a;
				isSelected = false;
				//logic to find email additional to:
				Pattern p = Pattern.compile('((Additional To:).+)');
				Matcher m = p.matcher(a.Description);
				String additionalTo = '';
				recOrSent = '';
				additionalToEmail = '';
				additionalToName = '';
				if(m.find()){
					additionalTo = m.group(1).split('Additional To:')[1].trim();
				}
				List<String> additionalToArray = new LIst<String>();
				if(additionalTo.contains(';'))
				{
					additionalToArray = additionalTo.split(';');
				}
				if(additionalToArray.size() > 0)
				{
					for(String currentAdditionalTo : additionalToArray)
					{
						String additionalToNameToAdd = '';
						String additionalToEmailToAdd = '';
						String regex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';
						Pattern myPattern = Pattern.compile(regex );
						Matcher myMatcher = myPattern.matcher(currentAdditionalTo);
						if (myMatcher.find())
						{
							additionalToEmailToAdd = myMatcher.group();
							additionalToEmail += additionalToEmailToAdd + '\r\n';
						}
						if(currentAdditionalTo.contains('"'))
						{
							String[] splitter = currentAdditionalTo.split('"');
							additionalToNameToAdd = splitter[1];
							additionalToName += additionalToNameToAdd + '<br/>';
						}
						else
						{
							List<String> splitter = new List<String>();
							splitter = currentAdditionalTo.split(additionalToEmailToAdd);
							if(splitter.size()>1)
							{
								additionalToNameToAdd = splitter[0];
								additionalToNameToAdd = additionalToNameToAdd.replaceAll('<', ' ');
								additionalToName +=additionalToNameToAdd + '<br/>';
							}
						}
					}
				}

				else {
					String regex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';
					Pattern myPattern = Pattern.compile(regex );
					Matcher myMatcher = myPattern.matcher(additionalTo);
					if (myMatcher.find())
					{
						additionalToEmail = myMatcher.group();
					}
					if(additionalTo.contains('"'))
					{
						String[] splitter = additionalTo.split('"');
						additionalToName = splitter[1];
					}
					else
					{
						String[] splitter = additionalTo.split(additionalToEmail);
						if(splitter.size()>1)
						{
							additionalToName = splitter[0];
							additionalToName = additionalToName.replaceAll('<', ' ');
							additionalToName = additionalToName;
						}
					}
				}
				recOrSent = sentOrRec(additionalTo);
			}
			catch(Exception e)
			{
				System.debug(e.getMessage() + ' in line '+ e.getLineNumber());
			}
		}
		public String sentOrRec(String additionalTo)
		{
			try
			{
				if(String.isNotBlank(additionalTo) && String.isNotEmpty(additionalTo))
				{
					Pattern p = Pattern.compile('((@).+)');
					Matcher m = p.matcher(additionalTo);
					if(m.find())
					{
						String extension = m.group(1).split('@')[1].trim();
						if(extension.contains('isyscm.com'))
						{
							return 'RECEIVED';
						}
						else
						{
							return 'SENT';
						}
					}
				}
			}
			catch(Exception e) {
				System.debug(e.getMessage() + ' in line '+ e.getLineNumber());
			}
			return '';
		}
	}

	public class AttachmentWrapper1{
		public Boolean isSelected {get;set;}
		public Attachment a {get;set;}
		public AttachmentWrapper1(Attachment a){
			this.a = a;
			isSelected = false;
		}

		public AttachmentWrapper1(Attachment a, Boolean b){
			this.a = a;
			isSelected = b;
		}
	}

}