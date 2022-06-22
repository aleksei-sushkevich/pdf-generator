public with sharing class EmailHandler {
    
    @AuraEnabled
    public static void sendOpportunityInvoice(String body, String subject, String recipientEmail, Id pdfId, String invNum){

        String htmlValue = [SELECT Id, HtmlValue FROM EmailTemplate WHERE ID = :SendInvoiceController.EMAIL_TEMPLATE_ID LIMIT 1].HtmlValue;
        htmlValue = htmlValue.replace('subject=Approve', 'subject=' + invNum);
        htmlValue = htmlValue.replace('subject=Reject', 'subject=' + invNum);
        body += htmlValue;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setHtmlBody(body);

        List<String> sendTo = new List<String>();
        sendTo.add(recipientEmail);
        mail.setToAddresses(sendTo);

        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        List<ContentVersion> cv = [SELECT VersionData, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId = :pdfId AND IsLatest = true LIMIT 1];
        if(cv != null && !cv.isEmpty()){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            Blob fileData = cv[0].VersionData;
            efa.setFilename(cv[0].Title + '.' + cv[0].FileExtension);
            efa.setBody(fileData);
            attachments.add(efa);
        }

        mail.setFileAttachments(attachments);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(mail);

        Messaging.sendEmail(mails);

    }

    public static void sendHappyBirthdayEmail(List<Contact> cons){

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        EmailTemplate emailTemplate = [SELECT Id,
                                              Subject,
                                              Description,
                                              HtmlValue,
                                              Body
                                       FROM   EmailTemplate 
                                       WHERE  Name = 'Happy Birthday Greeting'];

        for(Contact con : cons){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(con.Id);
            mail.setTemplateID(emailTemplate.Id);
            mail.setToAddresses(new List<String>{con.Email});
            mails.add(mail);
        }

        Messaging.sendEmail(mails);
        
    }
}
