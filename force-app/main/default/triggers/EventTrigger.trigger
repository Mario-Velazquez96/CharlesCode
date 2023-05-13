trigger EventTrigger on Event (after insert) {
	List<Id> eventIds = new List<Id>();
    if(trigger.isAfter && trigger.isInsert){
        for(Event objEvent : trigger.new){
            eventIds.add(objEvent.Id); 
        }
    }
    if(eventIds.size()>0){
        Id eventId = eventIds[0];
        SendMailWhenEventScheduled.getAccountAndContact(eventId);
    }
}