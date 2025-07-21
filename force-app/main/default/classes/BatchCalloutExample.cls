global class BatchCalloutExample implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id,name, Artist__c, Lyrics__c, Song__c FROM Account WHERE Artist__c != NULL AND Song__c != NULL');
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        // url https://api.lyrics.ovh/v1/Coldplay/Adventure of a Lifetime
        // remote site settings https://api.lyrics.ovh/v1/
        Http http = new Http();
        List<Account> accountsToUpdate = new List<Account>();
        system.debug('first');

        for (Account acc : scope) {
            system.debug('second');
            try {
                if (String.isBlank(acc.Artist__c) || String.isBlank(acc.Song__c)) {
                    continue; // Skip if either Artist or Song is missing
                }
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://api.lyrics.ovh/v1/'+acc.Artist__c+'/'+acc.Song__c);
                request.setMethod('GET');

                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    system.debug('third');
                    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    
                    if (responseBody.containsKey('lyrics')) {
                        system.debug('four');
                        acc.Lyrics__c = (String) responseBody.get('lyrics');
                        accountsToUpdate.add(acc);
                
               
                }
            } 
        }catch (Exception e) {
                System.debug('Error finding lyrics for ' + acc.Id + ': ' + e.getMessage());
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch completed.');
    }
}