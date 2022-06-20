trigger PaymentTR on Payment__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        PaymentTriggerHandler.changeOpportunityStage(trigger.new);
    }

}