import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import getNotes from '@salesforce/apex/notesSearcherController.getNotes';
import getPDFprint from '@salesforce/apex/notesSearcherController.getPrint';
import { loadScript } from 'lightning/platformResourceLoader';
import downloadjs from '@salesforce/resourceUrl/downloadjs';



export default class NotesSearcher extends LightningElement {
    @api recordId
    accountName
    showCustomLookup;
    showSpinner;
    @track notesList;
    @track objectId;
    showDataTable = false;
    record;
    startDate;
    endDate;

    strFile;
    
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    setAccountData (data, error){
        if(data){
            this.record = data;
            this.accountName = getFieldValue(this.record.data, NAME_FIELD);
            console.log('accountName',this.accountName);
            if (!!this.accountName) {
                this.showCustomLookup = true;
            }
        }
        if (error){
            console.log('error', error)
        }
    };

    //  get name() {
    //     return getFieldValue(this.account.data, NAME_FIELD);
    // }

    renderedCallback() {
        loadScript(this, downloadjs);
    }

    searchNotes(event){
        this.showDataTable = false;
        this.showSpinner = true;
        this.objectId = event.detail.selectedId;
        this.startDate = event.detail.startDate;
        this.endDate = event.detail.endDate;
        //let filters = event.detail.queryFilter;
        getNotes({accountId: this.objectId, startDate:this.startDate, endDate:this.endDate})
        .then(result => {
            let notesList = [];  
            result.forEach(notes => {                            
                notesList.push(notes);
            });
            this.notesList = [...notesList]; 

            this.showDataTable = true;
            console.log(JSON.stringify(this.notesList))
        })
        .catch(error => console.error(error))
        .finally(() => this.showSpinner = false);
        
    }

    accountRemoved(event) {
        this.showDataTable = false;
    }

    // downloadPDF(event) {
    //     let baseUrl = window.location.origin;
    //     console.log(baseUrl);
    //     window.open(baseUrl + '/apex/notesTable?school=' + this.objectId, '_blank');
    // }

    downloadPDF(event) {
        getPDFprint({accountId: this.recordId, startDate: this.startDate, endDate: this.endDate}).then(response => {
            this.strFile = "data:application/pdf;base64,"+ response[0];
            window.open(response[1]);
        })
    }

    handleRemovePill() {
        this.showCustomLookup = true;
        this.showDataTable = false;
    }

}