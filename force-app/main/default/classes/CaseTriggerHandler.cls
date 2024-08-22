public with sharing class CaseTriggerHandler extends TriggerHandler{
    public override void  afterInsert(){
        
    }
    public override void afterUpdate(){
    }
    public override void afterDelete(){
        
    }

    @Future
    public void countCasesPerAccount(List<Case> casesToGetAccounts){
        Set<String> casesIdsToGetAccounts = new Set<String>();
        for (Account account : casesToGetAccounts) {
        }
        
        List<Account>
    }

}