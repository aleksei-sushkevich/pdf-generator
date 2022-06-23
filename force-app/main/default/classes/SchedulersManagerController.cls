public with sharing class SchedulersManagerController {

    public class SchedulerWrapper{
        // @AuraEnabled
        // public String BatchClassName { get; set; }
        @AuraEnabled
        public Boolean Scheduled { get; set; }
        @AuraEnabled
        public String CronId { get; set; }
        @AuraEnabled
        public String CronExpr { get; set; }
    }
    
    
    // @AuraEnabled
    // public static List<SchedulerWrapper> getSchedulersData(){

    //     List<SchedulerWrapper> lstToReturn = new List<SchedulerWrapper>();
    //     List<ApexClass> lstApexClasses = [SELECT Id, Name, Body FROM ApexClass WHERE NamespacePrefix = null];
    //     for(ApexClass it : lstApexClasses) {
    //         if(it.Body.contains('Database.Batchable') && it.Name != 'SchedulersManagerController') {
    //             SchedulerWrapper wrap = new SchedulerWrapper();
    //             wrap.BatchClassName = it.Name;
    //             wrap.Scheduled = false;
    //             wrap.CronId = null;
    //             wrap.CronExpr = null;
    //             lstToReturn.add(wrap);
    //         }
    //     }

    //     Set<Id> jobIds = new Set<Id>();
    //     for(CronJobDetail it : [SELECT Id, Name FROM CronJobDetail]){
    //         Integer index = findIndexOfClassByJob(lstToReturn, it.Name);
    //         if(index != null){
    //             lstToReturn[index].Scheduled = true;
    //             lstToReturn[index].CronId = it.Id;
    //             jobIds.add(it.Id);
    //         }
    //     }

    //     for(CronTrigger it : [SELECT Id, CronExpression, CronJobDetailId FROM CronTrigger WHERE CronJobDetailId IN :jobIds]){
    //         Integer index = findIndexOfClassByCron(lstToReturn, it.CronJobDetailId);
    //         lstToReturn[index].CronExpr = it.CronExpression;
    //         lstToReturn[index].CronId = it.Id;
    //     }
    //     return lstToReturn;
    // }

    @AuraEnabled
    public static SchedulerWrapper getSchedulersData(String batchName){
        SchedulerWrapper wrToReturn = new SchedulerWrapper();
        Id jobId = [SELECT Id, Name FROM CronJobDetail WHERE Name = :batchName]?.Id;

        if(jobId != null){
            CronTrigger crTr = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetailId = :jobId LIMIT 1];
            wrToReturn.CronExpr = crTr.CronExpression;
            wrToReturn.Scheduled = true;
            wrToReturn.CronId = crTr.Id;
        }
        return wrToReturn;
    }

    @AuraEnabled
    public static void abortBatch(Id cronId){
        System.abortJob(cronId);
    }

    @AuraEnabled
    public static void scheduleBatch(String cronExpr, String className){
        Type cl = Type.forName('Schedule' + className);
        System.schedule(className, cronExpr, (Schedulable)cl.newInstance());
    }

    @AuraEnabled
    public static void runOnce(String className){
        Type cl = Type.forName(className);
        Database.executebatch((Database.Batchable<SObject>)cl.newInstance());
    }

    // private static Integer findIndexOfClassByCron(List<SchedulerWrapper> wrap, String jobId){
    //     Integer index = 0;
    //     for(SchedulerWrapper it : wrap){
    //         if(it.CronId == jobId){
    //             break;
    //         }
    //         index ++;
    //     }
    //     return index;
    // }

    // private static Integer findIndexOfClassByJob(List<SchedulerWrapper> wrap, String Name){
    //     Integer index = 0;
    //     Boolean exist = false; 
    //     for(SchedulerWrapper it : wrap){
    //         if(it.BatchClassName == Name){
    //             exist = true;
    //             break;
    //         }
    //         index ++;
    //     }
    //     return exist ? index : null;
    // }
}