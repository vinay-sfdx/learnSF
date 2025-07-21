public class FutureCalloutExample {
    
    @future(callout=true)
    public static void makeCallout(String url) {
        // url = 'https://gita-api.vercel.app/tel/verse/2/2';
        // remote site settings https://gita-api.vercel.app/
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint(url);
            request.setMethod('GET'); 
            request.setHeader('Content-Type', 'application/json'); 
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('Response: ' + response.getBody());
            } else {
                System.debug('Callout failed: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Error during callout: ' + e.getMessage());
        }
    }
}