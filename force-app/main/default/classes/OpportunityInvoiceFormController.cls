public with sharing class OpportunityInvoiceFormController {
    
    public Opportunity opp {get;set;}
    public OpportunityContactRole con {get;set;}
    public Map<Integer, List<OpportunityLineItem>> product {get;set;}
    public String balance {get;set;}


    public OpportunityInvoiceFormController(ApexPages.StandardController stdController) {
        List<String> fields = new List<String> {'Owner.Name', 'Invoice_Number__c'};
        if(!Test.isRunningTest()){
            stdController.addFields(fields);
        }
        
        opp = (Opportunity)stdController.getRecord();

        List<OpportunityContactRole> ocr = [SELECT ContactId, 
                                                   Contact.Name, 
                                                   Contact.Email, 
                                                   Contact.Account.Name,
                                                   Contact.Phone 
                                            FROM   OpportunityContactRole 
                                            WHERE  OpportunityId = :opp.Id 
                                            AND    IsPrimary = true 
                                            LIMIT  1];

        if(ocr != null && !ocr.isEmpty()){
            con = ocr[0];
        }

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
        if(products != null && !products.IsEmpty()){
            for(OpportunityLineItem pr : products){
                productsForMap.add(pr);
                count++;
                if(count == 15){
                    productsMap.put(intToMap, productsForMap);
                    productsForMap = new List<OpportunityLineItem>();
                    intToMap++;
                    count = 0;
                }else{
                    productsMap.put(intToMap, productsForMap);
                }
                totalPrice += pr.TotalPrice;
            }
            product = productsMap;
        }else{
            product = new Map<Integer, List<OpportunityLineItem>>();
            product.put(1, new List<OpportunityLineItem>());
        }
        List<String> args = new String[]{'0','number','###,###,###'};
        balance = String.format(totalPrice.format(), args);
        balance = balance.Substring(0,balance.length()-1);
    }
}