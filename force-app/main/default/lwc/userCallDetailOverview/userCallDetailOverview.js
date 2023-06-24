import { LightningElement } from "lwc";

export default class UserCallDetailOverview extends LightningElement {
  recordId;
  startDate;
  endDate;
  showSpinner;
  rawTaskList;

  searchCalls(event) {
    this.showSpinner = true;
    this.recordId = event.detail.selectedId;
    this.startDate = event.detail.startDate;
    this.endDate = event.detail.endDate;
    //let filters = event.detail.queryFilter;
    getTasks({
      accountId: this.recordId,
      startDate: this.startDate,
      endDate: this.endDate
    })
      .then((result) => {
        let notesList = [];
        result.forEach((notes) => {
          notesList.push(notes);
        });
        this.notesList = [...notesList];

        this.showDataTable = true;
        console.log(JSON.stringify(this.notesList));
      })
      .catch((error) => console.error(error))
      .finally(() => (this.showSpinner = false));
  }
}
