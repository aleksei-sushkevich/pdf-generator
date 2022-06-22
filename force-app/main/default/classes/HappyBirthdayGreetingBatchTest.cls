@isTest
public with sharing class HappyBirthdayGreetingBatchTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.prepareAccount();
        insert acc;
        Contact con = TestDataFactory.prepareContact(acc.Id);
        con.Birthdate = Date.today();
        insert con;
    }

    @isTest
    static void happyBirthdayGreetingBatchTest(){
        String CRON_EXP = '0 0 0 15 3 ? 2052';
        Test.startTest();
        System.schedule('ScheduleHappyBirthdayGreetingBatch test', CRON_EXP, new ScheduleHappyBirthdayGreetingBatch());
        HappyBirthdayGreetingBatch myBatchObject = new HappyBirthdayGreetingBatch();
        database.executebatch(myBatchObject);
        Test.stopTest();  
    }
}
