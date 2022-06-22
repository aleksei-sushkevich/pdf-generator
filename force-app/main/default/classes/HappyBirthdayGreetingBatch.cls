global class HappyBirthdayGreetingBatch implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Email FROM Contact WHERE Email != null AND Birthdate = TODAY';
        Database.QueryLocator ql = Database.getQueryLocator(query);
        return ql;
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> contacts){
        try{
            EmailHandler.sendHappyBirthdayEmail(contacts);
        }catch(Exception e){
            System.debug('Exception: ' + e);
        }
    }
    
    global void finish(Database.BatchableContext bc){}
}