@isTest
public class LocationCodeUpdaterTest {
    @isTest
    public static void updateRecordsTest(){
        Account account = new Account(Name = 'accountTest');
        insert account;

        List<String> names = new List<String>{'accountTest'};
        
        List<Account> testaccs = LocationCodeUpdaterController.updateRecords(names,'[{"Name":"accountTest","Active_Location__c":"Active","Location_Code__c":"test"},{"Name":"accountTest1","Active_Location__c":"Active","Location_Code__c":"test","ShippingStateCode":"MO"}]');
    }
}