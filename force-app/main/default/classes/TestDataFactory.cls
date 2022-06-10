@IsTest
public with sharing class TestDataFactory {

    public static Account prepareAccount(){
        return new Account(
            Name = 'Test Account'
        );
    }

    public static Contact prepareContact(Id accId){
        return new Contact(
            LastName = 'Test Contact',
            AccountId = accId
        );
    }

    public static Opportunity prepareOpportunity(Id accId){
        return new Opportunity(
            Name = 'Test',
            AccountId = accId,
            StageName = 'Prospecting',
            CloseDate = Date.Today()
        );
    }

    public static OpportunityContactRole prepareOpportunityContactRole(Id conId, Id oppId){
        return new OpportunityContactRole(
            ContactId = conId,
            OpportunityId = oppId,
            IsPrimary = true,
            Role = 'Decision Maker'
        );
    }

    public static OpportunityLineItem prepareOpportunityLineItem(Id oppId){
        Id pricebookId = Test.getStandardPricebookId();

        Id prodId = [SELECT Id FROM Product2 LIMIT 1]?.Id;
        if(prodId == null){
            Product2 newProd = new Product2(
                Name = 'Product',
                ProductCode = 'Pro',
                isActive = true
            );
            insert newProd;
            prodId = newProd.Id;
        }

        Id pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1]?.Id;
        if(pbEntry == null){
            PricebookEntry newBook = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prodId,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert newBook;
            pbEntry = newBook.Id;
        }
       
        return new OpportunityLineItem(
            OpportunityId = oppId,
            Quantity = 5,
            PricebookEntryId = pbEntry,
            TotalPrice = 5 * 100.00
        );
    }

    public static void prepareContentDocument(Id recordId){
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'test.pdf';
        cv.Title = 'test';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        insert cdl;
    }
}
