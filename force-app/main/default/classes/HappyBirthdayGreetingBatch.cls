global class HappyBirthdayGreetingBatch implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Account';
        Database.QueryLocator ql = Database.getQueryLocator(query);
        return ql;
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        System.debug('i;m here');
    	for(Account acc : accounts){
            System.debug(acc);
        }
    }
    
    global void finish(Database.BatchableContext bc){}
}