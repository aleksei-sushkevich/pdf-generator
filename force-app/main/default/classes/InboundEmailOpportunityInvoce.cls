global class InboundEmailOpportunityInvoce implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
   
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Invoice_Number__c = :email.subject LIMIT 1];
            if(opp.StageName == 'Prospecting'){
                switch on email.plainTextBody.replaceAll('\\n|\\r\\n', '') {
                    when 'Approved'{
                        opp.StageName = nextStage(opp.StageName);
                    }
                    when 'Rejected'{
                        opp.StageName = 'Closed Lost';
                    }
                }
                update opp;
            }else if(email.plainTextBody.replaceAll('\\n|\\r\\n', '') == 'Rejected'){
                opp.StageName = 'Closed Lost';
                update opp;
            }
        }catch(Exception e){
            System.debug(e);
        }

        result.success = true;
        
        return result;
    }

    private static String nextStage(String stage){
        Schema.DescribeFieldResult optyDescribe = Opportunity.StageName.getDescribe(); 
        List<Schema.PicklistEntry> optyPickListEntry = optyDescribe.getPicklistValues();
        Integer index = 0;
        for(Schema.PicklistEntry objPickList : optyPickListEntry) {
            index++;
            if(objPickList.getLabel() == stage){
                break;
            }
        }
        return optyPickListEntry[index].getLabel();
    }
}