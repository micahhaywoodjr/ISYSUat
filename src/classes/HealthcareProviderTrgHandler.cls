public with sharing class HealthcareProviderTrgHandler 
{
	public static void onBeforeUpdate(Healthcare_Provider__c[] trgNew)
	{
		Set<String> areaCodeSet = new Set<String>();
		List<Case> caseUpdateList = new List<Case>();
		List<Healthcare_Provider__c> activePrimaryList = new List<Healthcare_Provider__c>();
		for(Healthcare_Provider__c hcp : trgNew)
		{
			//if(!hcp.Inactive__c && hcp.Primary__c)
			if(hcp.ProviderStatus__c=='Active' && hcp.Primary__c)
			{
				//areaCodeSet.add(cleanPhone(hcp.Phone__c).subString(0,3));
				System.debug('AREACODE::::::::::'+hcp.AreaCode__c);
				areaCodeSet.add(hcp.AreaCode__c);
				activePrimaryList.add(hcp);
			}
		}			
		if(areaCodeSet.size()>0)
		{
			Map<String,List<Area__c>> areaByZip = new Map<String,List<Area__c>>();
			for(Area__c area : [SELECT Id, Name, Region__c FROM Area__c where Name in :areaCodeSet])
			{
				if(!areaByZip.containsKey(area.Name))
					areaByZip.put(area.Name,new List<Area__c>());
				areaByZip.get(area.Name).add(area);
			}
				
			for(Healthcare_Provider__c hcp : activePrimaryList)
			{
				//if(areaByZip.containsKey(cleanPhone(hcp.Phone__c).subString(0,3)))
				if(areaByZip.containsKey(hcp.AreaCode__c))
				{
					//for(Area__c area : areaByZip.get(cleanPhone(hcp.Phone__c).subString(0,3)))
					for(Area__c area : areaByZip.get(hcp.AreaCode__c))
					{
						if(area.Region__c==hcp.AreaRegion__c)
						{
							hcp.Area__c = area.Id;
							Case c = new Case(Id=hcp.Case__c,AssignmentRegion__c=hcp.Area__c);
							caseUpdateList.add(c);
						}
					}
				}
			}
		}
		if(caseUpdateList.size()>0)
			update caseUpdateList;
	}
	public static void onBeforeInsert(Healthcare_Provider__c[] trgNew)
	{
		Set<String> areaCodeSet = new Set<String>();
		List<Case> caseUpdateList = new List<Case>();
		List<Healthcare_Provider__c> activePrimaryList = new List<Healthcare_Provider__c>();
		for(Healthcare_Provider__c hcp : trgNew)
		{
			//if(!hcp.Inactive__c && hcp.Primary__c)
			if(hcp.ProviderStatus__c=='Active' && hcp.Primary__c)
			{
				//areaCodeSet.add(cleanPhone(hcp.Phone__c).subString(0,3));
				System.debug('AREACODE2::::::::::'+hcp.AreaCode__c);
				areaCodeSet.add(hcp.AreaCode__c);
				activePrimaryList.add(hcp);
			}
		}			
		Map<String,List<Area__c>> areaByZip = new Map<String,List<Area__c>>();
		for(Area__c area : [SELECT Id, Name, Region__c FROM Area__c where Name in :areaCodeSet])
		{
			if(!areaByZip.containsKey(area.Name))
				areaByZip.put(area.Name,new List<Area__c>());
			areaByZip.get(area.Name).add(area);
		}
			
		for(Healthcare_Provider__c hcp : activePrimaryList)
		{
			//if(areaByZip.containsKey(cleanPhone(hcp.Phone__c).subString(0,3)))
			if(areaByZip.containsKey(hcp.AreaCode__c))
			{
				//for(Area__c area : areaByZip.get(cleanPhone(hcp.Phone__c).subString(0,3)))
				for(Area__c area : areaByZip.get(hcp.AreaCode__c))
				{
					if(area.Region__c==hcp.AreaRegion__c)
					{
						hcp.Area__c = area.Id;
						Case c = new Case(Id=hcp.Case__c,AssignmentRegion__c=hcp.Area__c);
						caseUpdateList.add(c);
					}
				}
			}
		}
		if(caseUpdateList.size()>0)
			update caseUpdateList;
	}
	/*private static String cleanPhone(String phoneNumber)
	{
		String digits;
		Pattern nonDigits = Pattern.compile('[^0-9]');
		Matcher matchDigits = nonDigits.matcher(phoneNumber);
		digits = matchDigits.replaceAll('');
		if(digits.length()!=10)
			return phoneNumber;
		return digits;
	}*/
}