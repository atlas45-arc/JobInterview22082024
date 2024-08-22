public with sharing class CaseTriggerHandler extends TriggerHandler{

    public override void  afterInsert(){
        Set<Id> accountsId = new Set<Id>();
        for (Case cas : (List<Case>)Trigger.new) {
            accountsId.add(cas.AccountId);
        }
    }

    public override void afterUpdate(){
        Set<Id> accountsId = new Set<Id>();
        for (Case cas : (List<Case>)Trigger.old) {
            accountsId.add(cas.AccountId);
        }

        for (Case cas : (List<Case>)Trigger.new) {
            accountsId.add(cas.AccountId);
        }
    }

    public override void afterDelete(){
        //i decided to also implement the deletion logic even though it was not mentioned in the task
        Set<Id> accountsId = new Set<Id>();
        for (Case cas : (List<Case>)Trigger.old) {
            accountsId.add(cas.AccountId);
        }
        
    }


    public void countCasesPerAccount(Set<Id> accountsId){
        Set<String> closedStatusesSet = new Set<String>();
        for (Closed_Cases_Status__mdt record : [SELECT MasterLabel FROM Closed_Cases_Status__mdt]) {
            closedStatusesSet.add(record.MasterLabel);
        }

        Set<String> openStatusesSet = new Set<String>();
        for (Open_Cases_Status__mdt record : [SELECT MasterLabel FROM Open_Cases_Status__mdt]) {
            openStatusesSet.add(record.MasterLabel);
        }

        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c 
            FROM Account 
            WHERE Id IN :accountsId]
        );

        for (Account account : accountsMap.values()) {
            account.Number_of_closed_cases__c = 0;
            account.Number_of_open_cases__c = 0;
        }


        for (Case caseToStatusCheck : [SELECT Id, AccountId, Status FROM Case WHERE AccountId IN :accountsMap.keySet()]) {
            if (closedStatusesSet.contains(caseToStatusCheck.Status)) {
                accountsMap.get(caseToStatusCheck.AccountId).Number_of_closed_cases__c++;
            } else if (openStatusesSet.contains(caseToStatusCheck.Status)) {
                accountsMap.get(caseToStatusCheck.AccountId).Number_of_open_cases__c++;
            }
        }

        Update accountsMap.values();
    

        
        
    }

}