public with sharing class OpportunityInvoiceFormGenerator {
    
    private final Opportunity opp;
    
    public OpportunityInvoiceFormGenerator(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
    }

    public PageReference savePDF() {
        Id recordId  = ApexPages.currentPage().getParameters().get('id');
        PageReference attachment = Page.OpportunityInvoiceFormTemplate;
        attachment.getParameters().put('id',recordId);
        Blob body;
        body = attachment.getContentAsPDF();

        String title = [SELECT Ivoice_Number__c FROM Opportunity WHERE Id = :recordId LIMIT 1].Ivoice_Number__c;

        List<ContentDocument> doc = [SELECT Id, Title FROM ContentDocument WHERE Title = :title];
        ContentVersion cv = new ContentVersion();

        if(doc != null && !doc.IsEmpty()){
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = :title LIMIT 1].ContentDocumentId;
            cv.Title = title;
            cv.PathOnClient = title + '.pdf';
            cv.VersionData = body;
            cv.ContentDocumentId = conDocId;
            insert cv;
        }else{
            cv.PathOnClient = title + '.pdf';
            cv.Title = title;
            cv.VersionData = body;
            insert cv;
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDocId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            insert cdl;
        }

        return new PageReference('/' + recordId);
    }
}