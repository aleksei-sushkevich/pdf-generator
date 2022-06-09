@isTest
public with sharing class EmailHandlerTest {
    
    @isTest
    static void sendOpportunityInvoiceTest(){
        Test.startTest();
        EmailHandler.sendOpportunityInvoice(
                'Test Body',
                'Test Subject',
                'test.email@test.com',
                null,
                null
        );
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, emailInvocations);
    }

}
