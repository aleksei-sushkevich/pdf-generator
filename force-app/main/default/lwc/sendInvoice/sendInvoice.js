import { LightningElement, wire, api } from 'lwc';

import getInvoiceData from '@salesforce/apex/SendInvoiceController.getInvoiceData';
import sendOpportunityInvoice from '@salesforce/apex/EmailHandler.sendOpportunityInvoice';


export default class SendInvoice extends LightningElement {
    @api recordId;

    error;

    body;
    recipientEmail;
    recipientName;
    subject;
    pdfId;
    invNum;


    @wire(getInvoiceData, {recordId : '$recordId'})
    wiredValues({error, data}) {            
        if (data) {
            this.body = data.Body;
            this.recipientEmail = data.RecipientEmail;
            this.recipientName = data.RecipientName;
            this.subject = data.Subject + ' : ' + data.InvoiceNumb;
            this.pdfId = data.PDFId;
            this.invNum = data.InvoiceNumb;
        }else if(error) {
            console.log(error);
            this.error = error;
        }
    }

    @api
    sendEmail(){
        sendOpportunityInvoice({body: this.body, subject: this.subject, recipientEmail: this.recipientEmail, pdfId: this.pdfId, invNum: this.invNum});
    }


    setBody(event){
        this.body = event.target.value;
    }

}