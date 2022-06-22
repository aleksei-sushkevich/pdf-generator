@isTest
public with sharing class SchedulersManagerControllerTest {
    
    @isTest
    static void getSchedulersDataTest(){
        String cronExpr = '0 0 0 15 3 ? 2052';
        List<SchedulersManagerController.SchedulerWrapper> wrap = SchedulersManagerController.getSchedulersData();
        SchedulersManagerController.scheduleBatch(cronExpr, wrap[0].BatchClassName);
        wrap = SchedulersManagerController.getSchedulersData();
        System.assertEquals(wrap[0].CronExpr, cronExpr);
        SchedulersManagerController.abortBatch(wrap[0].CronId);
        wrap = SchedulersManagerController.getSchedulersData();
        System.assertEquals(wrap[0].CronExpr, null);
        SchedulersManagerController.runOnce(wrap[0].BatchClassName);
    }
}
