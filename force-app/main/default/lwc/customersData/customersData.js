import { LightningElement, track } from "lwc";

import getCustomersData from '@salesforce/apex/CustomersDataController.getCustomersData';

const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';

export default class CustomersData extends LightningElement {

    @track data;

    initialData;
    activeSectionMessage = '';
    page = 1;
    totalRecountCount;
    totalPage;
    pageSize = 10;
    startingRecord = 1;
    endingRecord = 0;
    nextDisabled;
    previousDisabled;


    connectedCallback(){
        this.getCustomersData();
    }

    getCustomersData(){
        getCustomersData()        
        .then(data => {
            for(var i = 0; i < data.length; i++){
                this.data = data.map(el=>{
                    return{
                        Label : el.AccountName + ' - ' + el.ClosedOpp,
                        Opps : el.Opps
                    };
                })
            }
            this.initialData = this.data;
            this.processRecords(this.data);
        })
        .catch(error =>{
            this.error = error;
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: ERROR_TITLE,
                    message: this.error.toString(),
                    variant: ERROR_VARIANT
                })
            );
        });
    }

    processRecords(data){
        this.totalRecountCount = data.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.endingRecord = this.pageSize;
        this.data = data.slice(0,this.pageSize);
        this.disableButtons();
    }

    disableButtons(){
        console.log(this.page + 'this.page');
        console.log(this.totalPage + 'this.totalPage');
        console.log(this.nextDisabled + 'this.nextDisabled');
        console.log(this.previousDisabled + 'this.previousDisabled');

        this.nextDisabled = this.page === this.totalPage ? true : false;
        this.previousDisabled = this.page === 1 ? true : false;
    }

    nextHandler() {
        if(this.page < this.totalPage && this.page !== this.totalPage){
            this.page++;
            this.displayRecordPerPage();            
        }
        this.disableButtons();
        
    }

    previousHandler() {
        if (this.page > 1) {
            this.page--;
            this.displayRecordPerPage();
        }
        this.disableButtons();
    }

    displayRecordPerPage(){
        this.startingRecord = ((this.page -1) * this.pageSize);
        this.endingRecord = (this.pageSize * this.page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord; 

        this.data = this.initialData.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    handleToggleSection(event) {
    }

    handleSetActiveSectionC() {
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = 'C';
    }
}