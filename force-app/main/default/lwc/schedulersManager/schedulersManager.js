import { LightningElement, track } from 'lwc';
import getSchedulersData from '@salesforce/apex/SchedulersManagerController.getSchedulersData';
import abortBatch from '@salesforce/apex/SchedulersManagerController.abortBatch';
import scheduleBatch from '@salesforce/apex/SchedulersManagerController.scheduleBatch';
import runOnce from '@salesforce/apex/SchedulersManagerController.runOnce';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';

const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';
const DEFAULT_SCHEDULER = "0 0 0 * * ?";

export default class SchedulersManager extends LightningElement {

    @track batches = {};
    error;
    errorMessage;

    showDropdown = false;
    searchString = '';
    selectedValue = '';
    placeholder = 'Select a Batch';
    scheduleValue = '';
    tooltip = false;
    runOnceDisabled = true;
    scheduleBatchDisabled = true;
    scheduleInput = true;
    abort = false;
    index = 0;
    

    connectedCallback(){
        this.getAllBatches();
    }

    blurEvent() {
        if(this.placeholder !== 'Select a Batch'){
            this.searchString = this.placeholder;
        }
        this.showDropdown = false;
        this.tooltip = false;
    }

    getAllBatches(){
        getSchedulersData()
        .then(data => { 
            console.log('data ' , data);
            this.batches = data.map(el => {
                return{
                    label : el.BatchClassName,
                    value : el.BatchClassName,
                    scheduled : el.Scheduled,
                    cronId : el.CronId,
                    cronExpr : el.CronExpr
                }
            })
        })         
        .catch(error => {
            this.error = error;
            this.errorMessage = reduceErrors(this.error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: ERROR_TITLE,
                    message: this.errorMessage.toString(),
                    variant: ERROR_VARIANT
                })
            );
        }); 
        this.scheduleValue = DEFAULT_SCHEDULER;
        this.runOnceDisabled = true;
        this.scheduleBatchDisabled = true;
        this.scheduleInputDisabled = true;
        this.placeholder = 'Select a Batch';
        this.searchString = '';
    }

    showOptions() {
        if(this.batches){
            this.searchString = '';
            for(var i = 0; i < this.batches.length; i++) {
                this.batches[i].isVisible = true;
            }
            if(this.batches.length > 0) {
                this.showDropdown = true;
            }
        }
    }

    filterOptions(event) {
        this.searchString = event.target.value;
        if(this.searchString && this.searchString.length > 0) {
            for(var i = 0; i < this.batches.length; i++) {
                if(this.batches[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                    this.batches[i].isVisible = true;
                } 
                else {
                    this.batches[i].isVisible = false;
                }
            }
        }else{
            for(var i = 0; i < this.batches.length; i++) {
                this.batches[i].isVisible = true;
            }
        }
    }

    scheduleChange(event){
        this.scheduleValue = event.target.value;
    }

    selectItem(event) {
        this.selectedValue = event.currentTarget.dataset.id;
        this.searchString = event.currentTarget.textContent;
        this.placeholder = event.currentTarget.textContent;
        this.showDropdown = false;
        this.scheduleBatchDisabled = false;
        this.scheduleInputDisabled = false;
        this.runOnceDisabled = false;
        this.index = this.findIndex(this.selectedValue);
        if(this.batches[this.index].cronExpr !== undefined){
            this.abort = true;
            this.scheduleValue = this.batches[this.index].cronExpr;
            this.scheduleInputDisabled = true;
        }else{
            this.scheduleValue = DEFAULT_SCHEDULER;
            this.abort = false;
        }
    }

    findIndex(value){
        let index = 0;
        for(var i = 0; i < this.batches.length; i++){
            if(this.batches[i].value === value){
                index = i;
            }
        }
        return index;
    }

    handleTooltip(){
        this.tooltip = true;
    }

    abortBatch(){
        abortBatch({cronId : this.batches[this.index].cronId})
        .then( () =>{     
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Scheduler ' + this.batches[this.index].label + ' was deleted',
                    variant: SUCCESS_VARIANT
                })
            );
            this.getAllBatches(); 
        }).catch(error => {
           this.error = error;
           this.errorMessage = reduceErrors(this.error);
           this.dispatchEvent(
                new ShowToastEvent({
                    title: ERROR_TITLE,
                    message: this.errorMessage.toString(),
                    variant: ERROR_VARIANT
                })
            );
       });
    }

    scheduleBatch(){
        scheduleBatch({cronExpr : this.scheduleValue, className : this.batches[this.index].label})
        .then( () =>{     
            this.dispatchEvent(
                new ShowToastEvent({
                    message: this.batches[this.index].label + ' was scheduled at ' + this.scheduleValue,
                    variant: SUCCESS_VARIANT
                })
            );
            this.getAllBatches(); 
        }).catch(error => {
           this.error = error;
           this.errorMessage = reduceErrors(this.error);
           this.dispatchEvent(
                new ShowToastEvent({
                    title: ERROR_TITLE,
                    message: this.errorMessage.toString(),
                    variant: ERROR_VARIANT
                })
            );
       });
    }

    runOnce(){
        runOnce({className : this.batches[this.index].label})
        .then( () =>{      
            this.dispatchEvent(
                new ShowToastEvent({
                    message:this.batches[this.index].label + ' was ran',
                    variant: SUCCESS_VARIANT
                })
            );
            this.getAllBatches(); 
        }).catch(error => {
           this.error = error;
           this.errorMessage = reduceErrors(this.error);
           this.dispatchEvent(
                new ShowToastEvent({
                    title: ERROR_TITLE,
                    message: this.errorMessage.toString(),
                    variant: ERROR_VARIANT
                })
            );
       });
    }

}