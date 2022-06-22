/**
*   Tested by : HappyBirthdayGreetingBatchTest
**/
global class ScheduleHappyBirthdayGreetingBatch implements Schedulable{

    global void execute(SchedulableContext sc) {
        HappyBirthdayGreetingBatch a = new HappyBirthdayGreetingBatch();
        database.executeBatch(a);
    }
    
}
