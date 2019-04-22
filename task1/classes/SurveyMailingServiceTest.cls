/**
 * Created by Yevhenii on 21.04.2019.
 */

@IsTest
private class SurveyMailingServiceTest {
	@TestSetup
	static void testSetup() {
		List<Contact> contacts = new List<Contact>();
		contacts.add(new Contact(LastName = 'Test Contact 1', Email = 'test0@test.com', Language__c = 'en', Survey_Date__c = Date.today()));
		contacts.add(new Contact(LastName = 'Test Contact 2', Email = 'test1@test.com', Language__c = 'en', Survey_Date__c = Date.today().addDays(1)));
		contacts.add(new Contact(LastName = 'Test Contact 3', Email = 'test2@test.com'));
		insert contacts;
	}

	@IsTest
	static void executeTest() {
		Contact[] contacts = [SELECT Id, Survey_Date__c FROM Contact WHERE Survey_Date__c != null];
		System.assertEquals(2, contacts.size());
		Test.startTest();
		Database.executeBatch(new SurveyMailingService());
		Test.stopTest();
		contacts = [SELECT Id, LastName, Survey_Date__c FROM Contact WHERE Survey_Date__c != null];
		System.assertEquals(1, contacts.size());
		System.assertEquals('Test Contact 2', contacts[0].LastName);
	}

	@IsTest
	static void buildMailListTest() {
		Contact[] contacts = [SELECT Id, Survey_Date__c, Language__c FROM Contact];
		Integer size = contacts.size();
		System.assertEquals(3, size);
		SurveyMailingService sms = new SurveyMailingService();
		Messaging.SingleEmailMessage[] mails = sms.buildMailList(contacts);
		System.assertEquals(size, mails.size());
	}

	@IsTest
	static void filterContactMapFromErrorResultsTest() {
		SurveyMailingService sms = new SurveyMailingService();
		List<Messaging.SingleEmailMessage> singleEmailMessages = new List<Messaging.SingleEmailMessage>();
		for (Contact c : [SELECT Id FROM Contact WHERE LastName = 'Test Contact 3' LIMIT 1]) {
			sms.contactMap.put(c.Id, c);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId(c.Id);
			mail.setPlainTextBody('test');
			singleEmailMessages.add(mail);
		}
		Messaging.SendEmailResult[] results = Messaging.sendEmail(singleEmailMessages);
		sms.filterContactMapFromErrorResults(results);
		System.assertEquals(1, sms.contactMap.size());
	}
}