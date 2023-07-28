@isTest
public class UserCallDetailControllerTest {
    @isTest 
    static void testGetUserCallDetails() {
        // Prepare data
        Contact con = new Contact(LastName = 'Smith', Email = 'test@test.com');
        insert con;

        Task t = new Task(
            WhoId = con.Id, 
            OwnerId = UserInfo.getUserId(), 
            Subject = 'Follow-up', 
            ActivityDate = Date.today()
        );
        insert t;

        Event e = new Event(
            WhoId = con.Id,
            OwnerId = UserInfo.getUserId(),
            Subject = 'Meeting',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(1)
        );
        insert e;

        // Perform test
        UserCallDetailController.UserCallDetailPackage details = UserCallDetailController.getUserCallDetails(UserInfo.getUserId(), Date.today().addDays(-30), Date.today().addDays(30));

        // Verify results
        System.assert(details != null, 'Details should not be null');
        System.assertEquals(1, details.callDetailsDateRange.size(), 'Should be 1 task in date range');
        System.assertEquals(1, details.meetingsDetailsDateRange.size(), 'Should be 1 event in date range');
        System.assertEquals(con.Id, details.contactsOwners.get(t.Id).Id, 'Contact owner should be same as task WhoId');
    }
}