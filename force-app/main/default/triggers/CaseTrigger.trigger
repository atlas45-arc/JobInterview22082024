trigger CaseTrigger on Case (after insert, after update, after delete) {
CaseTriggerHandler handler = new CaseTriggerHandler();
    handler.run();
}