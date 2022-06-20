@isTest
public with sharing class PaymentTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        Contact con = TestDataFactory.prepareContact(acc.Id);
        con.Email = 'test.mail@gmail.com';
        insert con;
        Opportunity opp = TestDataFactory.prepareOpportunity(acc.Id);
        opp.Amount = 100;
        insert opp;
        OpportunityContactRole ocr = TestDataFactory.prepareOpportunityContactRole(con.Id, opp.Id);
        insert ocr;
    }

    @isTest
    static void changeOpportunityStageFullyPaidTest(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<Payment__c> payments = new List<Payment__c>();
        for(Integer i = 0; i < 2; i++){
            Payment__c pay = new Payment__c(
                FirstName__c = 'Test',
                LastName__c = 'Test',
                Opportunity__c = oppId,
                Amount__c = 50
            );
            payments.add(pay);
        }
        insert payments;
        Opportunity opp = [SELECT StageName FROM Opportunity LIMIT 1];
        System.assertEquals('Fully Paid', opp.StageName);
    }

    @isTest
    static void changeOpportunityStagePartiallyPaidTest(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Payment__c pay = new Payment__c(
            FirstName__c = 'Test',
            LastName__c = 'Test',
            Opportunity__c = oppId,
            Amount__c = 10
        );
        insert pay;
        Opportunity opp = [SELECT StageName FROM Opportunity LIMIT 1];
        System.assertEquals('Partially paid', opp.StageName);
    }

}
