public with sharing class FileUploaderController {
    @AuraEnabled
    public static List<String> loadData( Id contentDocumentId ) {
        Integer index;
        String strMessage;
        List<String> contactsId = new List<String>();
        List < Contact > contactList = new List < Contact >();

        if ( contentDocumentId != null ) {
            
            ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId ];
            List < String > records = contentVersionObj.VersionData.toString().split( 'n' );

            //Get id INDEX
            List < String > rows = records[0].split( ',' );
            System.debug('GG>>>'+ JSON.serialize(rows));
            for (Integer i ; i < rows.size() ; i++){
                System.debug('GG>>>'+ rows[i]);
                if( rows[i] == 'Record Id' || rows[i] == 'Id' || rows[i] == 'ID' || rows[i] == 'Record ID'){
                   index = i;
                   System.debug('INDEEEX'+index);
                   break;
                }
            }

            //Removing the Header
            records.remove( 0 );
            for ( String record : records ) {
                if ( record != null ) {
                    List < String > row = record.split( ',' );
                    contactsId.add(row[index]);
                }
            }

            if ( contactsId.size() > 0 ) {
                Database.DeleteResult deleteResult = Database.delete( contentDocumentId, true );   
            } else {
                strMessage = 'Some error occured. Please reach out to your System Admin';
            }
        }
        return contactsId;
    }
}