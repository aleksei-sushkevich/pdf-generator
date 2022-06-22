@isTest
public with sharing class EmailHandlerTest {

    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        TestDataFactory.prepareContentDocument(acc.Id);
        Contact con = TestDataFactory.prepareContact(acc.Id);
        con.Birthdate = Date.today();
        insert con;
    }
    
    @isTest
    static void sendOpportunityInvoiceTest(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        ContentDocumentLink file = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :accId LIMIT 1];
        Test.startTest();
        EmailHandler.sendOpportunityInvoice(
                'Test Body',
                'Test Subject',
                'test.email@test.com',
                file.ContentDocumentId,
                null
        );
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, emailInvocations);
    }

    @isTest
    static void sendHappyBirthdayEmailTest(){
        List<Contact> cons = [SELECT Id, Name, Email FROM Contact];
        Test.startTest();
        EmailHandler.sendHappyBirthdayEmail(cons);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, emailInvocations);
    }

}
