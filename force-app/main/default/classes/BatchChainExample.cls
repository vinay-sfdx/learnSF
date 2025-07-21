public class BatchChainExample implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        System.debug('Processing ' + scope.size() + ' records');
    }

    public void finish(Database.BatchableContext bc) {
        // Chain another batch
        Database.executeBatch(new BatchChainExample());
    }
}