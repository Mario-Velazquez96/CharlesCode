import { LightningElement } from 'lwc';
import loadData from '@salesforce/apex/FileUploaderController.loadData';

export default class ContactSearcherFileUploader extends LightningElement {
    error;
    isLoaded = false;
    conctactsId;

    get acceptedFormats() {
        return ['.csv'];
    }
    
    uploadFileHandler( event ) {
        
        this.isLoaded = true;
        const uploadedFiles = event.detail.files;

        loadData( { contentDocumentId : uploadedFiles[0].documentId } )
        .then( result => {
            this.isLoaded = false;
            window.console.log('result ===> '+result);
            this.loadData = result;
            console.log('DATA',JSON.stringify(this.loadData));
        })
        .catch( error => {
            this.isLoaded = false;
            this.error = error;
            console.log('ERROR',JSON.stringify(this.error));
        } )

    }
}