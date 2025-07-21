public with sharing class Governorlimits {
    public Governorlimits() {

    }

    //1. System.LimitException: Too many query rows: 50001. To avoid use filters, limit, offset in soql
    public static void fetchAllContacts() {
        // This will fail if more than 50,000 contacts exist
        List<Contact> contacts = [SELECT Id, Name FROM Contact];

        
    }

    // 2. System.LimitException: Too many SOQL queries: 101. Avoid soql in for loop
    public static void processAccounts() {
        List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 200];

        for (Account acc : accounts) {
            // separate SOQL query runs for each account
            Contact c = [SELECT Id, LastName FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
            System.debug('Processing Contact: ' + c.LastName);
        }
    }

    //3. System.LimitException: Too many DML statements: 151. No DML in for loop.
    public static void updateContacts() {
        List<Contact> contacts = [SELECT Id, LastName FROM Contact LIMIT 200];  

        for (Contact c : contacts) {
            c.LastName = 'Updated';
            update c;
        }
    }
}