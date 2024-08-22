@isTest
private class CaseTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    }

    @isTest
    private static List<String> getOpenStatuses(){
        List<String> openStatusesSet = new List<String>();
        for (Open_Cases_Status__mdt record : [SELECT MasterLabel FROM Open_Cases_Status__mdt]) {
            openStatusesSet.add(record.MasterLabel);
        }
        System.assertNotEquals(0, openStatusesSet.size(), 'There are no declared open statuses on org.');

        return openStatusesSet;
    }
    @isTest
    private static List<String> getClosedStatuses(){
        List<String> closedStatusesSet = new List<String>();
        for (Closed_Cases_Status__mdt record : [SELECT MasterLabel FROM Closed_Cases_Status__mdt]) {
            closedStatusesSet.add(record.MasterLabel);
    }
    System.assertNotEquals(0, closedStatusesSet.size(), 'There are no declared closed statuses on org.');
    return closedStatusesSet;
}

        @isTest
        static void testAfterInsert() {
        List<String> openStatuses = getOpenStatuses();
        List<String> closedStatuses = getClosedStatuses();
    
        Account acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account LIMIT 1];

        Case case1 = new Case(
            AccountId = acc.Id,
            Status = openStatuses[0]
        );
        insert case1;

        acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(1, acc.Number_of_open_cases__c, 'Integer Number_of_open_cases__c should be equal to 1.');
        System.assertEquals(0, acc.Number_of_closed_cases__c, 'Integer Number_of_closed_cases__c should be equal to 0.');
    }

    @isTest
    static void testAfterUpdate() {
            List<String> openStatuses = getOpenStatuses();
            List<String> closedStatuses = getClosedStatuses();

        Account acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account LIMIT 1];

        Case case1 = new Case(
            AccountId = acc.Id,
            Status = 'New'
        );
        insert case1;

        case1.Status = 'Closed';
        update case1;

        acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(1, acc.Number_of_closed_cases__c, 'Integer Number_of_closed_cases__c should be equal to 1.');
        System.assertEquals(0, acc.Number_of_open_cases__c, 'Integer Number_of_open_cases__c should be equal to 0.');
    }

    @isTest
    static void testAfterDelete() {
        List<String> openStatuses = getOpenStatuses();
        List<String> closedStatuses = getClosedStatuses();

        Account acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account LIMIT 1];

        Case case1 = new Case(
            AccountId = acc.Id,
            Status = 'Closed'
        );
        insert case1;

        delete case1;

        acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(0, acc.Number_of_closed_cases__c, 'Integer Number_of_closed_cases__c should be equal to 0.');
        System.assertEquals(0, acc.Number_of_open_cases__c, 'Integer Number_of_open_cases__c should be equal to 0.');
    }

    @isTest
    static void testMixedCaseStatus() {
        List<String> openStatuses = getOpenStatuses();
        List<String> closedStatuses = getClosedStatuses();

        Account acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account LIMIT 1];

        Case case1 = new Case(AccountId = acc.Id, Status = 'New');
        Case case2 = new Case(AccountId = acc.Id, Status = 'Closed');
        Case case3 = new Case(AccountId = acc.Id, Status = 'New');
        insert new List<Case>{ case1, case2, case3 };

        acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(2, acc.Number_of_open_cases__c, 'Integer Number_of_open_cases__c should be equal to 2.');
        System.assertEquals(1, acc.Number_of_closed_cases__c, 'Integer Number_of_closed_cases__c should be equal to 1.');
    }
    @isTest
    static void testPerformanceForLargeNumberOfCases() {
        List<String> openStatuses = getOpenStatuses();
        List<String> closedStatuses = getClosedStatuses();

        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < 1000; i++) {
            casesToInsert.add(new Case(
                AccountId = acc.Id,
                Status = openStatuses[0] 
            ));
        }

        for (Integer i = 0; i < 1000; i++) {
            casesToInsert.add(new Case(
                AccountId = acc.Id,
                Status = closedStatuses[0] 
            ));
        }

        Test.startTest();
        insert casesToInsert;
        Test.stopTest();

        acc = [SELECT Id, Number_of_closed_cases__c, Number_of_open_cases__c FROM Account WHERE Id = :acc.Id];
        
        System.assertEquals(1000, acc.Number_of_closed_cases__c, 'Number_of_closed_cases__c should be equal to 500.');
        System.assertEquals(1000, acc.Number_of_open_cases__c, 'Number_of_open_cases__c should be equal to 500.');
    }
}
