public without sharing class notesSearcherController {

    Public static map<String, String> documentLinkContactsMap = new map<String,String>();
    Public static Set<Id> contactIds = new Set<Id>();
    Public static List<WrapperNotes> notes = new List<WrapperNotes>();
    Public static Set<Id> accountContentNotesIds = new Set<Id>();

    @AuraEnabled (cacheable=true)
    public static List<WrapperNotes> getNotes(String accountId,Date startDate, Date endDate){
        try {
            String accountNotesQuery = 'SELECT Id, Body, Title,CreatedDate,CreatedBy.Name FROM Notes';
            String accountQuery;
            String filters;

            System.debug(startDate);
            System.debug(endDate);

            if (startDate != null) {
                Integer d = startDate.day();
                Integer mo = startDate.month();
                Integer yr = startDate.year();

                DateTime DT = DateTime.newInstance(yr, mo, d,00,00,00);
                String formattedDatetime = DT.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

                filters = 'CreatedDate >= ' + formattedDatetime;
            }
            if (endDate != null) {
                Integer d = endDate.day();
                Integer mo = endDate.month();
                Integer yr = endDate.year();

                DateTime DT = DateTime.newInstance(yr, mo, d);
                String formattedDatetime = DT.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                if (String.isNotBlank(filters)){
                    filters +=  ' AND CreatedDate <= ' + formattedDatetime;
                    filters = '('+filters+')';
                } else {
                    filters = 'CreatedDate <= ' + formattedDatetime;
                }
            }

            System.debug('Notes'+filters);
 
            if (String.isNotBlank(filters)) {
                 accountNotesQuery = 'SELECT Id, Body, Title,CreatedDate,CreatedBy.Name FROM Notes WHERE ' + filters;
            }

            accountQuery = 'SELECT Id, Name, (' + accountNotesQuery + '),(SELECT Id, Name FROM Contacts) FROM Account WHERE Id = :accountId LIMIT 1';

            System.debug(accountQuery);
            List<Account> accounts = Database.query(accountQuery);

            System.debug(accounts);
            
            if (accounts.size() > 0) {
                getRelatedAccountNotes(accounts);
                getRelatedAccountContentNotes(accounts,accountId,filters);
                if(contactIds.size() > 0){
                    getRelatedContactNotes(filters);
                    getRelatedContactContentNotes(filters);
                }

                //sort notes by date
                notes.sort();

                return notes; 
            } else {
                return null;
            }
            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void getRelatedAccountNotes(List<Account> accounts){
        for(Account acc : accounts){
            for(Contact con : acc.Contacts){
                contactIds.add(con.Id);
            }
            for(Note n : acc.Notes){
                addWrapperFromNote(n,'Account',acc.Name);
            }
        }
    }

    public static void getRelatedContactNotes(String filters){
        String contactNotesQuery = 'SELECT Id, Body, Title,CreatedDate,CreatedBy.Name FROM Notes';
        String contactQuery;

        if (String.isNotBlank(filters)) {
            contactNotesQuery = 'SELECT Id, Body, Title,CreatedDate,CreatedBy.Name FROM Notes WHERE ' + filters;
        }

        contactQuery = 'SELECT Id, Name, (' + contactNotesQuery + ') FROM Contact WHERE Id IN :contactIds';
        System.debug('contactQuery notes ' +contactQuery);
        List<Contact> contactsNotes = Database.query(contactQuery);
        System.debug('contactsNotes notes ' +contactsNotes.size());

        for (Contact con : contactsNotes) {
            for(Note n : con.Notes){
                addWrapperFromNote(n,'Contact',con.Name);
            }
        }
    }

    public static void getRelatedAccountContentNotes(List<Account> accounts,String accountid, String filters){
        String accountLinksQuery = 'SELECT Id, LinkedEntityId,ContentDocumentId,LinkedEntity.Name FROM ContentDocumentLink WHERE ContentDocument.FileType = \'SNOTE\' AND LinkedEntityId =:accountid';

        System.debug('accountLinks'+accountLinksQuery);
        List<ContentDocumentLink> accountLinks = Database.query(accountLinksQuery);

        for (ContentDocumentLink link :accountLinks){
            accountContentNotesIds.add(link.ContentDocumentId);
        }

        if(accountContentNotesIds.size() > 0){
            String contentNoteQuery = 'SELECT Id,Content,Title,CreatedDate,CreatedBy.Name FROM ContentNote WHERE Id IN :accountContentNotesIds';

            if (String.isNotBlank(filters)) {
                contentNoteQuery = contentNoteQuery + ' AND ' + filters;
            }
            System.debug('contentNoteQuery ACCSS ' + contentNoteQuery );

            List<ContentNote> notes = Database.query(contentNoteQuery);

            System.debug('notesAccs ' + notes.size() );
            for(ContentNote accNotes : notes){
                addWrapperFromContentNote(accNotes,'Account',accounts[0].Name);    
            }
        } 
    }

    public static void getRelatedContactContentNotes(String filters){
        String contactLinksQuery = 'SELECT Id, LinkedEntityId,ContentDocumentId,LinkedEntity.Name FROM ContentDocumentLink WHERE ContentDocument.FileType = \'SNOTE\' AND LinkedEntityId IN :contactIds';

        List<ContentDocumentLink> contactLinks = Database.query(contactLinksQuery);

        for (ContentDocumentLink link : contactLinks){
            documentLinkContactsMap.put(link.ContentDocumentId,link.LinkedEntity.Name);
        }

        if (contactLinks.size() > 0) {
            Set<String> linksIds = documentLinkContactsMap.keySet();
            String contentNoteQuery = 'SELECT Id,Content,Title,CreatedDate,CreatedBy.Name FROM ContentNote WHERE Id IN :linksIds';

            if (String.isNotBlank(filters)) {
                contentNoteQuery = contentNoteQuery + ' AND ' + filters;
            }
            System.debug('error 142' + contentNoteQuery);
            List<ContentNote> notes = Database.query(contentNoteQuery);
            System.debug('notesConss ' + notes.size() );

            for(ContentNote contNotes : notes){
                addWrapperFromContentNote(contNotes, 'Contact', documentLinkContactsMap.get(contNotes.Id));
            }
        }   
    }

    public static void addWrapperFromNote(Note note,String objectType,String ownerName){
        WrapperNotes wrapper = new WrapperNotes();
        wrapper.id = note.Id;
        wrapper.title = note.Title;
        wrapper.body = note.Body;
        wrapper.ownerName = ownerName;
        wrapper.objectType = objectType;
        wrapper.createdDate = note.CreatedDate.date();
        wrapper.userName = note.CreatedBy.Name;
        notes.add(wrapper);
    }

    public static void addWrapperFromContentNote(ContentNote note,String objectType,String ownerName){
        WrapperNotes wrapper = new WrapperNotes();
        wrapper.id = note.Id;
        wrapper.title = note.Title;
        Blob myBlob = note.Content;
        String stringBody = EncodingUtil.base64Decode(EncodingUtil.base64Encode(myBlob)).toString().replaceAll('<[^>]+>',' ');
        wrapper.body = stringBody;
        wrapper.ownerName = ownerName;
        wrapper.objectType = objectType;
        wrapper.createdDate = note.CreatedDate.date();
        wrapper.userName = note.CreatedBy.Name;
        notes.add(wrapper);
    }

    //add extra things
    @AuraEnabled (cacheable=true)
    public static List<String> getPrint(String accountId,Date startDate, Date endDate){    
        List <String> pageStrings = new List<String>();

        String pdfURL = '/apex/notesTable?school=' + accountId;
        if (startDate != null) {
            String startDateValue = EncodingUtil.urlEncode(startDate.format(), 'UTF-8');
            pdfURL += '&startDate=' + startDateValue;
        }
        if (endDate != null) {
            String endDateValue = EncodingUtil.urlEncode(endDate.format(), 'UTF-8');
            pdfURL += '&endDate=' + endDateValue;
        }
        PageReference pdfPage = new Pagereference(pdfURL);
        Blob pdfBlob = pdfPage.getContent();
        String downloadURL = EncodingUtil.base64Encode(pdfBlob);

        pageStrings.add(downloadURL);
        pageStrings.add(pdfPage.getUrl());

        return pageStrings;
    }
    //end


    public class WrapperNotes implements Comparable{
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String title{get; set;}
        @AuraEnabled
        public String body{get; set;}
        @AuraEnabled
        public String ownerName{get; set;}
        @AuraEnabled
        public String objectType{get; set;}
        @AuraEnabled
        public Date createdDate{get; set;}
        @AuraEnabled
        public String userName{get; set;}

        public Integer compareTo(Object compareTo) {
            WrapperNotes compareToEmp = (WrapperNotes)compareTo;
            if (this.createdDate > compareToEmp.createdDate) return -1;
            if (this.createdDate < compareToEmp.createdDate) return 1;
            return 0;
        }

    }
}