public with sharing class CustomersDataController {

    public class CustomerDataWrapper{
        @AuraEnabled
        public String AccountName { get; set; }
        @AuraEnabled
        public Integer ClosedOpp { get; set; }
        @AuraEnabled
        public List<Opportunity> Opps { get; set; }
    }
    
    @AuraEnabled
    public static List<CustomerDataWrapper> getCustomersData(){

        Map<Id, Account> idToAccMap = new Map<Id,Account>([SELECT Id, Name FROM Account LIMIT 50000]);
        List<Opportunity> oppsList = [SELECT Id, 
                                             CreatedDate, 
                                             CloseDate, 
                                             AccountId, 
                                             Amount,
                                             isClosed
                                      FROM   Opportunity 
                                      WHERE  AccountId IN :idToAccMap.keyset()
                                      ];

        Map<Account, List<Opportunity>> accToOppsMap = new Map<Account, List<Opportunity>>();
        for(Opportunity opp : oppsList){
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
            Integer countClosedOpp = 0;
            for(Opportunity opp : accToOppsMap.get(acc)){
                if(opp.isClosed){
                    countClosedOpp++;
                }
            }
            
            CustomerDataWrapper data = new CustomerDataWrapper();
            data.AccountName = acc.Name;
            data.ClosedOpp = countClosedOpp;
            data.Opps = accToOppsMap.get(acc);

            customersData.add(data);
        }

        return customersData;

    }

}
