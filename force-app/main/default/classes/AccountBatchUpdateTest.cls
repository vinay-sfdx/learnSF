@isTest
public class AccountBatchUpdateTest {
    
    @isTest
    static void testBatchProcessing() {
        
        List<Account> accList = new List<Account>();
        for (Integer i = 1; i <= 10; i++) { 
            accList.add(new Account(Name = 'Test Account ' + i, Phone = '1234567890'));
        }
        insert accList; 
        
        
        Test.startTest();
        Database.executeBatch(new AccountBatchUpdate(), 10); 
        Test.stopTest();
        
        
        List<Account> updatedAccounts = [SELECT Id, Industry FROM Account WHERE Id IN :accList];
        for (Account acc : updatedAccounts) {
            System.assertEquals('Technology', acc.Industry, 'Industry should be updated to Technology');
        }
    }
}