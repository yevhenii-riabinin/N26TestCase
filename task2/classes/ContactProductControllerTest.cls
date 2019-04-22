/**
 * Created by Yevhenii on 22.04.2019.
 */

@IsTest
private class ContactProductControllerTest {
	@TestSetup
	static void testSetup() {
		Product__c p = new Product__c(Name = 'Standard');
		insert new Product__c[] { p };

		Product_Details__c pd = new Product_Details__c(Product__c = p.Id, Home_Country__c = 'DE', Card_Replacement_Cost__c = 10, ATM_Fee_in_other_currencies__c = 1.5, Cost_per_Calendar_Month__c = 5);
		insert new Product_Details__c[] { pd };

		Contact contact = new Contact(LastName = 'Contact1', Home_Country__c = 'DE', Product__c = p.Id);
		insert new Contact[] { contact };

		Case c = new Case(ContactId = contact.Id, Status = 'New', Origin = 'Web');
		insert new Case[] { c };
	}

	@IsTest
	static void getContactProductDetailsFromCaseTest() {
		for (Case c : [SELECT Id FROM Case LIMIT 1]) {
			Product_Details__c pd = ContactProductController.getContactProductDetailsFromCase(c.Id);
			System.assertNotEquals(null, pd);
			System.assertEquals(10, pd.Card_Replacement_Cost__c);
			System.assertEquals(5, pd.Cost_per_Calendar_Month__c);
			System.assertEquals(1.5, pd.ATM_Fee_in_other_currencies__c);
		}
	}

	@IsTest
	static void initCaseContactTest() {
		System.assertEquals(null, ContactProductController.caseContact);
		for (Case c : [SELECT Id FROM Case LIMIT 1]) {
			ContactProductController.initCaseContact(c.Id);
		}
		for (Contact c : [SELECT Id FROM Contact LIMIT 1]) {
			System.assertEquals(c.Id, ContactProductController.caseContact.Id);
		}
	}
}