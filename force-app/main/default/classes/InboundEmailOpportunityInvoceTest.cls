@isTest
public with sharing class InboundEmailOpportunityInvoceTest {


    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        Opportunity opp = TestDataFactory.prepareOpportunity(acc.Id);
        insert opp;
    }


    
    @isTest
    static void handleInboundEmailTest1(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity LIMIT 1];
        
        email.subject = opp.Invoice_Number__c;
        email.plainTextBody = 'Approved';
        env.fromAddress = 'test@gmail.com';
        
        InboundEmailOpportunityInvoce inbound = new InboundEmailOpportunityInvoce();
        inbound.handleInboundEmail(email, env); 

        Opportunity oppAfterEmail = [SELECT Id, Invoice_Number__c, StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(oppAfterEmail.StageName, 'Qualification');

    }

    @isTest
    static void handleInboundEmailTest2(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity LIMIT 1];
        
        email.subject = opp.Invoice_Number__c;
        email.plainTextBody = 'Rejected';
        env.fromAddress = 'test@gmail.com';

        InboundEmailOpportunityInvoce inbound = new InboundEmailOpportunityInvoce();
        inbound.handleInboundEmail(email, env); 

        Opportunity oppAfterEmail = [SELECT Id, Invoice_Number__c, StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(oppAfterEmail.StageName, 'Closed Lost');
    }

    @isTest
    static void handleInboundEmailTestNegative(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity LIMIT 1];
        delete opp;
        
        email.subject = '11';
        email.plainTextBody = 'Rejected';
        env.fromAddress = 'test@gmail.com';

        InboundEmailOpportunityInvoce inbound = new InboundEmailOpportunityInvoce();
        inbound.handleInboundEmail(email, env); 
    }

}
