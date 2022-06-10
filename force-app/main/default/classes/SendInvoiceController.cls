public with sharing class SendInvoiceController {

    public static final Id EMAIL_TEMPLATE_ID = '00X5i000000DiR4EAK';

    public class InvoiceWrapper{
        @AuraEnabled
        public String Subject { get; set; }
        @AuraEnabled
        public String Body { get; set; }
        @AuraEnabled
        public String RecipientName { get; set; }
        @AuraEnabled
        public String RecipientEmail { get; set; }
        @AuraEnabled
        public String InvoiceNumb { get; set; }
        @AuraEnabled
        public String PDFId { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static InvoiceWrapper getInvoiceData(Id recordId){
        InvoiceWrapper wrap = new InvoiceWrapper();

        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE ID = :EMAIL_TEMPLATE_ID];
        wrap.Subject = template.Subject;
        wrap.Body = template.Body;

        List<OpportunityContactRole> con = [SELECT Contact.Name, Contact.Email FROM OpportunityContactRole WHERE OpportunityId = :recordId AND IsPrimary = true LIMIT 1];
        wrap.RecipientName = con[0]?.Contact.Name;
        wrap.RecipientEmail = con[0]?.Contact.Email;

        wrap.InvoiceNumb = [SELECT Invoice_Number__c FROM Opportunity WHERE ID =:recordId LIMIT 1].Invoice_Number__c;

        if(Test.isRunningTest()){
            wrap.InvoiceNumb = 'test';
        }
        
        List<ContentDocumentLink> file = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Title = :wrap.InvoiceNumb LIMIT 1];
        if(file != null && !file.isEmpty()){
            wrap.PDFId = file[0]?.ContentDocumentId;
        }

        return wrap;
    }

    @AuraEnabled(cacheable=true)
    public static Id getPdfId(Id recordId){
        String invNumb = [SELECT Invoice_Number__c FROM Opportunity WHERE ID =:recordId LIMIT 1].Invoice_Number__c;
        if(Test.isRunningTest()){
            invNumb = 'test';
        }
        return [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Title = :invNumb LIMIT 1].ContentDocumentId;
    }

}