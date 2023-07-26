import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getTasks from "@salesforce/apex/UserCallDetailController.getUserCallDetails";
export default class UserCallDetailOverview extends LightningElement {
  recordId;
  startDate;
  endDate;
  showSpinner;
  loading = false;

  callDetailsThisWeek = [];
  callDetailsLastWeek = [];
  callDetailsThisMonth = [];
  callDetailsLastMonth = [];
  callDetailsDateRange = [];
  meetingsDetailsDateRange = [];
  contactTaskOwners = {};

  callTotalAmount;
  //conversationTotalAmount;
  numberOfDaysCalling;
  callsPerEachMarket = {};
  callsPerEachTitle = {};
  meetingsScheduled;
  meetingsScheduledForOthers;

  searchCalls(event) {
    this.loading = true;
    this.recordId = event.detail.selectedId;
    this.startDate = event.detail.startDate;
    this.endDate = event.detail.endDate;
    //let filters = event.detail.queryFilter;
    getTasks({
      accountId: this.recordId,
      startDate: this.startDate,
      endDate: this.endDate
    })
      .then((data) => {
        this.callDetailsThisWeek = data?.callDetailsThisWeek;
        this.callDetailsLastWeek = data?.callDetailsLastWeek;
        this.callDetailsThisMonth = data?.callDetailsThisMonth;
        this.callDetailsLastMonth = data?.callDetailsLastMonth;
        this.callDetailsDateRange = data?.callDetailsDateRange;
        this.meetingsDetailsDateRange = data?.meetingsDetailsDateRange;
        this.contactTaskOwners = data?.contactsOwners;
        console.log("contactTaskOwners: ", this.contactTaskOwners);
        this.loading = false;
      })
      .catch((error) => this.showToast("Error", error.body.message, "error"));
  }

  getSummaryData() {
    this.callTotalAmount = this.callDetailsDateRange.length;
    this.numberOfDaysCalling = this.getNumberOfDaysCalling();
    this.callsPerEachMarket = this.getCallsPerEachMarket();
  }

  //Get the number of days calling (not while traveling)
  getNumberOfDaysCalling() {
    if (this.callDetailsDateRange.length <= 0) {
      return 0;
    }
    let datesRaw = new Set();
    let datesWhileTraveling = new Set();

    for (let i = 0; i < this.callDetailsDateRange.length; i++) {
      let date = new Date(this.callDetailsDateRange[i].CreatedDate);
      let formattedDate =
        date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear();
      console.log("formattedDate: ", formattedDate);

      if (this.callDetailsDateRange[i].Done_While_Traveling__c) {
        datesWhileTraveling.add(formattedDate);
      } else {
        datesRaw.add(formattedDate);
      }
    }

    // delete the dates that are in both sets
    for (let date of datesWhileTraveling) {
      datesRaw.delete(date);
    }

    return datesRaw.size;
  }

  getCallsPerEachMarket() {
    //iterate through the contactsTaskOwners which is a map of taskId and contacts
    //if the market is not in the map, add it and have a count of how many call are in each market
    //if the market is in the map, increment the count
    let callsPerEachMarket = {};
    for (let [key, value] of Object.entries(this.contactTaskOwners)) {
      let market = value.Main_Market__c;
      if (market in callsPerEachMarket) {
        callsPerEachMarket[market] += 1;
      } else {
        callsPerEachMarket[market] = 1;
      }
    }
    console.log("callsPerEachMarket: ", callsPerEachMarket);
    return callsPerEachMarket;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}

/*console.log(
          "callDetailsThisWeek: ",
          this.callDetailsThisWeek[0].CreatedDate
        );
        //test
        let dateTest = new Date(this.callDetailsThisWeek[0].CreatedDate);
        let formattedDate =
          dateTest.getMonth() +
          1 +
          "/" +
          dateTest.getDate() +
          "/" +
          dateTest.getFullYear();
        //how check type of dateTest?
        console.log("dateTest: ", formattedDate);
        console.log("dateTest: ", typeof formattedDate);
        console.log(
          "callDetailsDateRange: ",
          JSON.stringify(this.callDetailsDateRange)
        );*/
