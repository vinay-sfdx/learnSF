public with sharing class holidayfinder {
    public holidayfinder() {

    }

    public static void getholidaylist(){
        //https://holidayapi.com/v1/holidays?pretty&key=dcad6811-a862-4900-bf81-0ce0581850e4&country=IN&year=2024
       String KEY = 'dcad6811-a862-4900-bf81-0ce0581850e4';
       String url = 'https://holidayapi.com/v1/holidays?pretty&';
        Http http = new Http();
        String Country = 'IN';
        String Year = '2024';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url+'key='+KEY+'&country='+Country+'&year='+Year);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json'); 

        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            system.debug(response.getBody());
    }
}
}