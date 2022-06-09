@isTest
public with sharing class CustomersDataControllerTest {
    
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        Opportunity opp1 = TestDataFactory.prepareOpportunity(acc.Id);
        insert opp1;
        Opportunity opp2 = TestDataFactory.prepareOpportunity(acc.Id);
        opp2.StageName = 'Closed Won';
        opp2.Amount = 100;
        insert opp2;
        OpportunityLineItem oli1 = TestDataFactory.prepareOpportunityLineItem(opp1.Id);
        insert oli1;
        OpportunityLineItem oli2 = TestDataFactory.prepareOpportunityLineItem(opp1.Id);
        insert oli2;
    }

    @isTest
    static void getCustomersDataTest(){
        List<CustomersDataController.CustomerDataWrapper> data = CustomersDataController.getCustomersData(null);
        System.assertEquals(data[0].AccountName, 'Test Account');
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        data = CustomersDataController.getCustomersData(accId);
        System.assertEquals(data[0].ClosedOpp, 100);
    }
}
