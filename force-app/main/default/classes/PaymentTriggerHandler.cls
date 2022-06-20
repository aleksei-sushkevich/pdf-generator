public with sharing class PaymentTriggerHandler {
    

    public static void changeOpportunityStage(List<Payment__c> payments){
        Set<Id> oppsId = new Set<Id>();
        for(Payment__c pay : payments){
            oppsId.add(pay.Opportunity__c);
        }

        Map<Id, List<Payment__c>> oppIdToPaymentsMap = new Map<Id, List<Payment__c>>();
        for(Payment__c pay : [SELECT Id, Amount__c, Opportunity__c FROM Payment__c WHERE Opportunity__c IN :oppsId]){
            if(oppIdToPaymentsMap.get(pay.Opportunity__c) == null){
                oppIdToPaymentsMap.put(pay.Opportunity__c, new List<Payment__c>{pay});
            }else{
                oppIdToPaymentsMap.get(pay.Opportunity__c).add(pay);
            }
        }

        List<OpportunityContactRole> ocr = [SELECT OpportunityId, 
                                                   Contact.OwnerId
                                            FROM   OpportunityContactRole 
                                            WHERE  OpportunityId = :oppsId
                                            AND    IsPrimary = true];

        Map<Id, Id> oppIdToContactOwnerMap = new Map<Id, Id>();

        for(OpportunityContactRole con : ocr){
            oppIdToContactOwnerMap.put(con.OpportunityId, con.Contact.OwnerId);
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Task> tasksToCreate = new List<Task>();

        DateTime reminder = Datetime.newInstance(Date.today().addDays(2),Time.newInstance(10, 0, 0, 0));

        for(Opportunity opp : [SELECT Id, Amount FROM Opportunity WHERE Id IN :oppIdToPaymentsMap.keyset()]){
            if(checkAmount(opp.Amount, oppIdToPaymentsMap.get(opp.Id))){
                opp.StageName = 'Fully Paid';
                tasksToCreate.add(prepareTask(oppIdToContactOwnerMap.get(opp.Id), opp.Id, reminder));
            }else{
                opp.StageName = 'Partially paid';
            }
            oppsToUpdate.add(opp);
        }

        if(oppsToUpdate != null && !oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }

        if(tasksToCreate != null && !tasksToCreate.isEmpty()){
            insert tasksToCreate;
        }
    }

    private static Task prepareTask(Id ownerId, Id oppId, DateTime reminder){
        return new Task(
            OwnerId = ownerId,
            Priority = 'High',
            Status = 'Not Started',
            Subject = 'Delivery of goods',
            IsReminderSet = true,
            ReminderDateTime = reminder,
            WhatId = oppId
        );
    }

    private static Boolean checkAmount(Decimal amount, List<Payment__c> payments){
        Decimal sum = 0;
        for(Payment__c pay : payments){
            sum += pay.Amount__c;
        }
        return sum >= amount ? true : false;
    }

}
