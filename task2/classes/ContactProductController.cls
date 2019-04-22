/**
 * Created by Yevhenii on 20.04.2019.
 */

public with sharing class ContactProductController {
	@TestVisible
	private static Contact caseContact { get; set; }

	@AuraEnabled
	public static Product_Details__c getContactProductDetailsFromCase(String caseId) {
		List<Product_Details__c> optionsList = new List<Product_Details__c>();
		initCaseContact(caseId);
		if (caseContact != null) {
			optionsList = [
					SELECT Id, Product__r.Name, Cost_per_Calendar_Month__c, ATM_Fee_in_other_currencies__c, Card_Replacement_Cost__c
					FROM Product_Details__c
					WHERE Product__c = :caseContact.Product__c AND Home_Country__c = :caseContact.Home_Country__c
					LIMIT 1
			];
		}
		return !optionsList.isEmpty() ? optionsList[0] : null;
	}

	@TestVisible
	private static void initCaseContact(String caseId) {
		if (caseContact == null) {
			for (Case c : [SELECT Id, Contact.Product__c, Contact.Home_Country__c FROM Case WHERE Id = :caseId LIMIT 1]) {
				caseContact = c.Contact;
			}
		}
	}
}