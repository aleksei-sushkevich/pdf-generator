public with sharing class OpportunityInvoiceFormController {
    
    public ID parentId {get;set;}
    public String pdfName {get;set;}
    public Opportunity opp {get;set;}
    public OpportunityContactRole con {get;set;}
    public List<OpportunityLineItem> prod {get;set;}


    public OpportunityInvoiceFormController(ApexPages.StandardController stdController) {
        List<String> fields = new List<String> {'Owner.Name', 'Ivoice_Number__c'};
        stdController.addFields(fields);
        
        this.opp = (Opportunity)stdController.getRecord();

        this.con = [SELECT ContactId, 
                           Contact.Name, 
                           Contact.Email, 
                           Contact.Account.Name,
                           Contact.Phone 
                    FROM   OpportunityContactRole 
                    WHERE  OpportunityId = :opp.Id 
                    AND    IsPrimary = true 
                    LIMIT  1];

        this.prod = [SELECT Id, 
                            UnitPrice, 
                            Name, 
                            TotalPrice, 
                            Quantity 
                    FROM    OpportunityLineItem
                    WHERE   OpportunityId = :opp.Id ];
    }

    public PageReference savePdf() {

        PageReference pdf = Page.OpportunityInvoiceForm;
        pdf.getParameters().put('id',parentId);

    
        Attachment attach = new Attachment();
        
        Blob body;
        
        try{
            body = pdf.getContent();
        }catch(VisualforceException e){
            body = Blob.valueOf('Error');
        }
        
        
        attach.Body = body;
        attach.Name = opp.Ivoice_Number__c;
        attach.IsPrivate = false;
        attach.ParentId = parentId;
        insert attach;
        
        return new PageReference('/'+parentId);
    }

}
