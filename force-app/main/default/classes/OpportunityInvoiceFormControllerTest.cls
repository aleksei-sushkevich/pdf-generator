@isTest
public with sharing class OpportunityInvoiceFormControllerTest {
    
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        Contact con = TestDataFactory.prepareContact(acc.Id);
        insert con;
        Opportunity opp = TestDataFactory.prepareOpportunity(acc.Id);
        insert opp;
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(Integer i = 0; i < 20; i++){
            OpportunityLineItem oli = TestDataFactory.prepareOpportunityLineItem(opp.Id);
            oliList.add(oli);
        }
        insert oliList;
        OpportunityContactRole ocr = TestDataFactory.prepareOpportunityContactRole(con.Id, opp.Id);
		insert ocr;
    }

    @isTest
    static void constructorTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        PageReference pageRef = Page.OpportunityInvoiceFormTemplate;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(opp.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OpportunityInvoiceFormController contr = new OpportunityInvoiceFormController(sc);
        System.assertEquals(contr.balance, '10,00');
    }
}
