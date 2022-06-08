public with sharing class SendInvoiceController {

    private static final Id EMAIL_TEMPLATE_ID = '00X5i000000DiFKEA0';

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

        OpportunityContactRole con = [SELECT Contact.Name, Contact.Email FROM OpportunityContactRole WHERE OpportunityId = :recordId AND IsPrimary = true LIMIT 1];
        wrap.RecipientName = con.Contact.Name;
        wrap.RecipientEmail = con.Contact.Email;

        wrap.InvoiceNumb = [SELECT Ivoice_Number__c FROM Opportunity WHERE ID =:recordId LIMIT 1].Ivoice_Number__c;
        
        ContentDocumentLink file = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Title = :wrap.InvoiceNumb LIMIT 1];
        wrap.PDFId = file.ContentDocumentId;

        return wrap;
    }
}
