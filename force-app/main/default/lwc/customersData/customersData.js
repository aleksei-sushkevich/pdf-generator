import { LightningElement, track, api } from "lwc";

import getCustomersData from '@salesforce/apex/CustomersDataController.getCustomersData';
import NAME_FIELD from '@salesforce/schema/OpportunityLineItem.Name';
import QUANTITY_FIELD from '@salesforce/schema/OpportunityLineItem.Quantity';
import UNITPRICE_FIELD from '@salesforce/schema/OpportunityLineItem.UnitPrice';
import PRODUCT_OBJECT from '@salesforce/schema/OpportunityLineItem';


const columns = [
    {
        label: 'Opportunity Name',
        fieldName: 'Opp',
        type: 'url',
        typeAttributes: {
            label: {fieldName: 'OppName'},
            target: '_blank'
        },
    },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'},
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date'},
    { label: 'Amount', fieldName: 'Amount'},
    {   type: "button-icon",
        initialWidth: 80,
        typeAttributes: {  
            name: 'ProductsView',
            iconName: 'standard:product',   
            disabled: false
        }
    }
];

export default class CustomersData extends LightningElement {
    
    @api recordId;

    @track data;
    @track recordData;
    @track columns = columns;
    @track products;
    error;

    activeSection = [];
    isModal = false;

    searchStringName = '';
    searchStringSum = '';

    objectApiName = PRODUCT_OBJECT;
    nameField = NAME_FIELD;
    quantityField = QUANTITY_FIELD;
    unitPriceField = UNITPRICE_FIELD;

    initialData;
    filteredData;
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
        getCustomersData({recordId: this.recordId})        
        .then(data => {
            let baseURL = 'https://'+location.host+'/';
            for(var i = 0; i < data.length; i++){
                this.data = data.map(el=>{
                    return{
                        Name : el.AccountName,
                        Sum : el.ClosedOpp + '',
                        Label : el.AccountName + ' - ' + el.ClosedOpp + '$',
                        Opps : el.OppsAndProducts.map(el => {
                            return{
                                Id : el.OpportunityItem.Id,
                                Opp : baseURL + el.OpportunityItem.Id,
                                OppName : el.OpportunityItem.Name,
                                CreatedDate: el.OpportunityItem.CreatedDate,
                                CloseDate: el.OpportunityItem.CloseDate,
                                Amount: el.OpportunityItem.Amount === undefined ? undefined : el.OpportunityItem.Amount + '$',
                                Products : el.Products
                            }
                        })
                    };
                })
            }
            if(this.recordId !== undefined){
                this.recordData = this.data[0].Opps;
            }else{
                this.initialData = this.data;
                this.processRecords(this.data);
            }
        })
        .catch(error =>{
            this.error = error;
            console.log(error);
        });
    }

    openModal(){
        this.isModal = this.isModal ? false : true;
    }

    handleRowAction(event){  
        const recId =  event.detail.row.Id;
        const actionName = event.detail.action.name;
        if(actionName === 'ProductsView'){
            for(var i = 0; i < this.data.length; i++){
                for(var j = 0; j < this.data[i].Opps.length; j++){
                    if(this.data[i].Opps[j].Id === recId){
                        this.products = this.data[i].Opps[j].Products;
                    }
                }
            }
            this.openModal();
        }
    }

    processRecords(data){
        this.totalRecountCount = data.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.endingRecord = this.pageSize;
        this.data = data.slice(0,this.pageSize);
        this.disableButtons();
    }

    disableButtons(){
        this.nextDisabled = this.page === this.totalPage ? true : false;
        this.previousDisabled = this.page === 1 ? true : false;
    }

    nextHandler() {
        if(this.page < this.totalPage && this.page !== this.totalPage){
            this.page++;
            this.displayRecordPerPage();            
        }
        this.disableButtons();
        this.activeSection = [];
        
    }

    findAccountsByName(event){
        this.searchStringName = event.target.value;
        let prop = 'Name';
        this.findFun(this.searchStringName, prop);
    }

    findAccountsBySum(event){
        this.searchStringSum = event.target.value;
        let prop = 'Sum';
        this.findFun(this.searchStringSum, prop);
    }

    findFun(value, prop){
        let parseData = JSON.parse(JSON.stringify(this.initialData));
        let newData = [];
        for(var i = 0; i < parseData.length; i++){
            if(parseData[i][prop].toLowerCase().trim().startsWith(value.toLowerCase().trim())){
                newData.push(parseData[i]);
            }
        }
        this.page = 1;
        this.filteredData = newData;
        this.processRecords(newData);
        this.disableButtons();
    }

    previousHandler() {
        if (this.page > 1) {
            this.page--;
            this.displayRecordPerPage();
        }
        this.disableButtons();
        this.activeSection = [];
    }

    displayRecordPerPage(){
        this.startingRecord = (this.page -1) * this.pageSize;
        this.endingRecord = this.pageSize * this.page;

        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord; 

        console.log(this.searchStringSum);
        if(this.searchStringName === '' && this.searchStringSum === ''){
            this.data = this.initialData.slice(this.startingRecord, this.endingRecord);
        }else{
            this.data = this.filteredData.slice(this.startingRecord, this.endingRecord);
        }

    }

  
}