public with sharing class OpportunityInvoiceFormController {
    
    public String pdfName {get;set;}
    public Opportunity opp {get;set;}
    public OpportunityContactRole con {get;set;}
    public Map<Integer, List<OpportunityLineItem>> product {get;set;}
    public String balance {get;set;}


    public OpportunityInvoiceFormController(ApexPages.StandardController stdController) {
        List<String> fields = new List<String> {'Owner.Name', 'Ivoice_Number__c'};
        stdController.addFields(fields);
        
        opp = (Opportunity)stdController.getRecord();

        con = [SELECT ContactId, 
                      Contact.Name, 
                      Contact.Email, 
                      Contact.Account.Name,
                      Contact.Phone 
                FROM  OpportunityContactRole 
                WHERE OpportunityId = :opp.Id 
                AND   IsPrimary = true 
                LIMIT 1];

        List<OpportunityLineItem> products = [SELECT Id, 
                                                    UnitPrice, 
                                                    Product2.Name, 
                                                    TotalPrice, 
                                                    Quantity 
                                            FROM    OpportunityLineItem
                                            WHERE   OpportunityId = :opp.Id];
                                            
        Map<Integer, List<OpportunityLineItem>> productsMap = new Map<Integer, List<OpportunityLineItem>>(); 
        List<OpportunityLineItem> productsForMap = new List<OpportunityLineItem>();                       
    
        Decimal totalPrice = 0;
        Integer count = 0;
        Integer intToMap = 0;
        for(OpportunityLineItem pr : products){
            productsForMap.add(pr);
            count++;
            if(count == 15){
                productsMap.put(intToMap, productsForMap);
                productsForMap = new List<OpportunityLineItem>();
                intToMap++;
                count = 0;
            }
            totalPrice += pr.TotalPrice;
        }
        product = productsMap;
        List<String> args = new String[]{'0','number','###,###,###'};
        balance = String.format(totalPrice.format(), args);
        balance = balance.Substring(0,balance.length()-1);
    }

    public PageReference savePDF() {
        if(ApexPages.currentPage().getParameters().containsKey('generatepdf')){ 
            return new PageReference('/' + this.opp.Id);
        }
        PageReference attachment = Page.OpportunityInvoiceForm;
        attachment.getParameters().put('generatepdf','true');
        attachment.getParameters().put('Id', opp.Id);
        Attachment attach = new Attachment();
        Blob body;
        body = attachment.getContentAsPDF();
        attach.Body = body;
        attach.Name = opp.Ivoice_Number__c;
        attach.IsPrivate = false;
        attach.ParentId = opp.Id;
        attach.ContentType = 'application/pdf';
        insert attach;
        return new PageReference('/' + this.opp.Id);
    }
}
