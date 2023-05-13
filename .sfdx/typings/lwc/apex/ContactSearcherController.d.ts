declare module "@salesforce/apex/ContactSearcherController.getContacts" {
  export default function getContacts(param: {contactsEmail: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactSearcherController.createRecords" {
  export default function createRecords(param: {contactsId: any, codeName: any}): Promise<any>;
}
