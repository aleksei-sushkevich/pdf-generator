@isTest
public with sharing class SendInvoiceControllerTest {
    
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        Contact con = TestDataFactory.prepareContact(acc.Id);
        con.Email = 'test.mail@gmail.com';
        insert con;
        Opportunity opp = TestDataFactory.prepareOpportunity(acc.Id);
        insert opp;
        TestDataFactory.prepareContentDocument(opp.Id);
        OpportunityContactRole ocr = TestDataFactory.prepareOpportunityContactRole(con.Id, opp.Id);
        insert ocr;
    }

    @isTest
    static void getInvoiceDataTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        SendInvoiceController.InvoiceWrapper wrap =  SendInvoiceController.getInvoiceData(opp.Id);
        System.assertEquals(wrap.InvoiceNumb, 'test');
    }

    @isTest
    static void getPdfIdTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Id pdfId = SendInvoiceController.getPdfId(opp.Id);
        System.assert(pdfId != null);
    }
}
