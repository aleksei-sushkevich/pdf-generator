@RestResource(urlMapping='/Payments/*')
global with sharing class PaymentManagerRestAPI {

    global class Payment{
        global String Opportunity;
        global Decimal Amount;
        global String FirstName;
        global String LastName;
    }

    @HttpPost
    global static void createPayments(List<Payment> payments){
        List<Payment__c> newPayments = new List<Payment__c>();
        for(Payment pay : payments){
            Payment__c newPayment = new Payment__c(
                FirstName__c = pay.FirstName,
                LastName__c = pay.LastName,
                Opportunity__c = pay.Opportunity,
                Amount__c = pay.Amount
            );
            newPayments.add(newPayment);
        }
        insert newPayments;
    }   
}
