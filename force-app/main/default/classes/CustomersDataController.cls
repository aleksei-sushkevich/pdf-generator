public with sharing class CustomersDataController {

    public class CustomerDataWrapper{
        @AuraEnabled
        public String AccountName { get; set; }
        @AuraEnabled
        public Decimal ClosedOpp { get; set; }
        @AuraEnabled
        public List<OpportunityWrapper> OppsAndProducts { get; set; }
    }

    public class OpportunityWrapper{
        @AuraEnabled
        public Opportunity OpportunityItem { get; set; }
        @AuraEnabled
        public List<OpportunityLineItem> Products{ get; set; }
    }
    
    @AuraEnabled
    public static List<CustomerDataWrapper> getCustomersData(){

        Map<Id, Account> idToAccMap = new Map<Id,Account>([SELECT Id, Name FROM Account LIMIT 50000]);
        Map<Id, Opportunity> idToOppsMap = new Map<Id, Opportunity>([SELECT Id,
                                                                            Name,
                                                                            CreatedDate, 
                                                                            CloseDate, 
                                                                            AccountId, 
                                                                            Amount,
                                                                            isClosed
                                                                     FROM   Opportunity 
                                                                     WHERE  AccountId IN :idToAccMap.keyset()
                                                                     ]);


        List<OpportunityLineItem> productsList = [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :idToOppsMap.keyset()];
        Map<Opportunity, List<OpportunityLineItem>> oppsToProductsMap = new  Map<Opportunity, List<OpportunityLineItem>>();
        for(OpportunityLineItem prod : productsList){
            Opportunity opp = idToOppsMap.get(prod.OpportunityId);
            if(oppsToProductsMap.get(opp) == null){
                List<OpportunityLineItem> newProdList = new List<OpportunityLineItem>();
                newProdList.add(prod);
                oppsToProductsMap.put(opp, newProdList);
            }else{
                oppsToProductsMap.get(opp).add(prod); 
            }
        }

        Map<Account, List<Opportunity>> accToOppsMap = new Map<Account, List<Opportunity>>();
        for(Opportunity opp : idToOppsMap.values()){
            Account acc = idToAccMap.get(opp.AccountId);
            if(accToOppsMap.get(acc) == null){
                List<Opportunity> newOppsList = new List<Opportunity>();
                newOppsList.add(opp);
                accToOppsMap.put(acc, newOppsList);
            }else{
                accToOppsMap.get(acc).add(opp); 
            }
        }
    
        List<CustomerDataWrapper> customersData = new List<CustomerDataWrapper>();
        for(Account acc : accToOppsMap.keyset()){
            Decimal sumClosedOpp = 0;
            List<OpportunityWrapper> oppsAndProdList = new List<OpportunityWrapper>();
            for(Opportunity opp : accToOppsMap.get(acc)){
                if(opp.isClosed){
                    sumClosedOpp += opp.Amount;
                }
                OpportunityWrapper oppWrap = new OpportunityWrapper();
                oppWrap.OpportunityItem = opp;
                oppWrap.Products = oppsToProductsMap.get(opp);
                oppsAndProdList.add(oppWrap);
            }
            CustomerDataWrapper data = new CustomerDataWrapper();
            data.AccountName = acc.Name;
            data.ClosedOpp = sumClosedOpp;
            data.OppsAndProducts = oppsAndProdList;

            customersData.add(data);
        }

        return customersData;

    }

}
