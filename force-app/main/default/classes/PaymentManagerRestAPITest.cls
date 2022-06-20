@isTest
public with sharing class PaymentManagerRestAPITest {
    
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        Opportunity opp = TestDataFactory.prepareOpportunity(acc.Id);
        insert opp;
    }

    @isTest
    static void createPaymentsTest(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        PaymentManagerRestAPI.Payment payment = new PaymentManagerRestAPI.Payment();
        payment.Opportunity = oppId;
        payment.Amount = 1;
        payment.FirstName = 'Test';
        payment.LastName = 'Test';
        List<PaymentManagerRestAPI.Payment> payments = new List<PaymentManagerRestAPI.Payment>{payment};
        PaymentManagerRestAPI.createPayments(payments);
        List<Payment__c> insPayments = [SELECT Id, FirstName__c FROM Payment__c];
        System.assertEquals(insPayments[0].FirstName__c, 'Test');
    }
}
