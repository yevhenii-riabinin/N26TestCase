/**
 * Created by Yevhenii on 21.04.2019.
 * Sends surveys to Contacts
 */

public without sharing class SurveyMailingService implements Database.Batchable<SObject>, Database.Stateful {
	private static final String EN_EMAIL_TEMPLATE_NAME = 'N26SurveyEN';
	private static final String DE_EMAIL_TEMPLATE_NAME = 'N26SurveyDE';
	public EmailTemplate enEmailTemplate { get; set; }
	public EmailTemplate deEmailTemplate { get; set; }
//	collects Contacts for updating the Survey_Date__c field
	public Map<Id, Contact> contactMap {get;set;}

	public SurveyMailingService() {
		for (EmailTemplate et : [SELECT Id, Name FROM EmailTemplate WHERE Name IN (:EN_EMAIL_TEMPLATE_NAME, :DE_EMAIL_TEMPLATE_NAME) LIMIT 2]) {
			if (et.Name == EN_EMAIL_TEMPLATE_NAME) {
				enEmailTemplate = et;
			} else {
				deEmailTemplate = et;
			}
		}
		contactMap = new Map<Id, Contact>();
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id, FirstName, Language__c, Survey_Date__c FROM Contact WHERE Email != null AND Survey_Date__c != null AND Survey_Date__c <= TODAY');
	}

	public void execute(Database.BatchableContext bc, List<Contact> scope) {
		if (scope != null) {
			try {
				Messaging.reserveSingleEmailCapacity(scope.size());
				contactMap.putAll(scope);
				List<Messaging.SingleEmailMessage> mailList = buildMailList(scope);
				List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(mailList);
				filterContactMapFromErrorResults(emailResults);
			} catch (Exception ex) {
				System.debug(ex.getMessage());
			}
		}
	}

	/**
	 * Builds a SingleEmailMessages from a batch's scope
	 *
	 * @param scope: List of Contacts
	 *
	 * @return List<Messaging.SingleEmailMessage>
	 */
	@TestVisible
	private List<Messaging.SingleEmailMessage> buildMailList(List<Contact> scope) {
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		if (scope != null) {
			for (Contact contact : scope) {
				Messaging.reserveSingleEmailCapacity(1);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//				choose a template based on a Contact's Language__c field
				mail.setTemplateId(contact.Language__c == 'de' ? deEmailTemplate.Id : enEmailTemplate.Id);
				mail.setTargetObjectId(contact.Id);
				mail.setSenderDisplayName('N26 Support');
				mailList.add(mail);
			}
		}
		return mailList;
	}

	/**
	 * Removes Contacts from a contactMap if
	 *
	 * @param results
	 */
	@TestVisible
	private void filterContactMapFromErrorResults(List<Messaging.SendEmailResult> results) {
		if (results != null) {
			for (Messaging.SendEmailResult sendEmailResult : results) {
				if (!sendEmailResult.isSuccess()) {
					for (Messaging.SendEmailError error : sendEmailResult.getErrors()) {
						contactMap.remove(error.getTargetObjectId());
					}
				}
			}
		}
	}

	public void finish(Database.BatchableContext bc) {
		if (!contactMap.isEmpty()) {
			for (Contact contact : contactMap.values()) {
				contact.Survey_Date__c = null;
			}
			Savepoint sp = Database.setSavepoint();
			try {
				Database.update(contactMap.values());
			} catch (Exception ex) {
				Database.rollback(sp);
				System.debug(ex.getMessage());
			}
		}
	}
}