public without sharing class UserCallDetailController {
  @AuraEnabled
  public static List<UserCallDetail> getUserCallDetails(Id userId) {
    return [
      SELECT
        Id,
        UserId,
        CallDurationInSeconds,
        CallType,
        CallDisposition,
        CallObject,
        CallResult,
        CallStartTime,
        CallEndTime,
        CallRecordId,
        CallRecordingUrl,
        CreatedDate,
        CreatedById,
        LastModifiedDate,
        LastModifiedById,
        SystemModstamp
      FROM UserCallDetail
      WHERE UserId = :userId
    ];
  }
}
