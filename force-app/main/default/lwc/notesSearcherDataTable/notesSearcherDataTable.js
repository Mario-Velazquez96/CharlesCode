import { LightningElement, api, wire, track } from 'lwc';

const COLUMNS = [
    { label: 'Title', fieldName: 'title', type: 'text', wrapText: true },
    { label: 'Body', fieldName: 'body', type: 'text', wrapText: true },
    { label: 'Owner', fieldName: 'ownerName', type: 'text', sortable: true },
    { label: 'Created Date', fieldName: 'createdDate', type: 'date', sortable: true },
    { label: 'Type', fieldName: 'objectType', type: 'text' },
    { label: 'Created By', fieldName: 'userName', type: 'text' },
];

export default class NotesSearcherDataTable extends LightningElement {
    @api notesList;
    disabledFirst = false;
    disabledPrevious = false;
    disabledNext = false;
    disabledLast = false;
    totalRecords;
    page;
    totalPages;
    columns = COLUMNS;
    sortedBy = 'ownerName';
    sortDirection;
    defaultSortDirection = 'asc';
    allSelectedRows = new Set()
    pageNumber = 0
    pageData = []
     
    connectedCallback() {
        this.updatePage()
    }

    updatePage() {
        this.pageData = this.notesList.slice(this.pageNumber*5, this.pageNumber*5+5);
        this.totalRecords = this.notesList.length;
        this.totalPages = Math.ceil((this.notesList.length)/5);
        this.page = this.pageNumber+1;
        this.disableButtons();
    }

    previous() {
        this.pageNumber = Math.max(0, this.pageNumber - 1);
        this.updatePage()
    }

    first() {
        this.pageNumber = 0;
        this.updatePage();
    }

    next() {
        this.pageNumber = Math.min(Math.ceil((this.notesList.length)/5), this.pageNumber + 1);
        this.updatePage();
    }

    last() {
        this.pageNumber = Math.ceil((this.notesList.length)/5)-1;
        this.updatePage();
    }

    disableButtons(){
        if(this.pageNumber == 0){
            this.disabledFirst = true;
            this.disabledPrevious = true;
        }
        else{
            this.disabledFirst = false;
            this.disabledPrevious = false;
        }
        if(this.pageNumber + 1 == Math.ceil((this.notesList.length)/5)){
            this.disabledNext = true;
            this.disabledLast = true;
        }
        else{
            this.disabledNext = false;
            this.disabledLast = false;
        }
    }

    onHandleSort(event) {
        var fieldName = event.detail.fieldName;
        var sortedDirection = event.detail.sortDirection;
        this.sortedBy = fieldName;
        this.sortDirection = sortedDirection;
        this.sortData(fieldName, sortedDirection);
        this.updatePage();
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.notesList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.notesList = parseData;
    }   

    download(){
        this.dispatchEvent(new CustomEvent('download'));
    }

}