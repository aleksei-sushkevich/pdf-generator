import { LightningElement, wire, track, api } from 'lwc';

import getInvoiceData from '@salesforce/apex/SendInvoiceController.getInvoiceData';
import { NavigationMixin } from 'lightning/navigation';


export default class SendInvoice extends LightningElement {
    @api recordId;

    error;

    body;
    recipientEmail;
    recipientName;
    subject;
    pdfId;


    @wire(getInvoiceData, {recordId : '$recordId'})
    wiredValues({error, data}) {            
        if (data) {
            this.body = data.Body;
            this.recipientEmail = data.RecipientEmail;
            this.recipientName = data.RecipientName;
            this.subject = data.Subject + ' : ' + data.InvoiceNumb;
            this.pdfId = data.PDFId;
        }else if(error) {
            console.log(error);
            this.error = error;
        }
    }


    setBody(event){
        this.body = event.target.value;
    }

    openPDF(){
        console.log(this.pdfId);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: this.pdfId,
                selectedRecordId: this.pdfId
            }
        })
    }

    sendEmail(){
        console.log('send1132');
    }
}