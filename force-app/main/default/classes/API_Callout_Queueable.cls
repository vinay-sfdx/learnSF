public class API_Callout_Queueable implements Queueable, Database.AllowsCallouts {
    private String requestBody;
    private Integer retryCount;
    private static final Integer MAX_RETRIES = 3;
    private static final String API_ENDPOINT = 'endpoint';

    public API_Callout_Queueable(String requestBody, Integer retryCount) {
        this.requestBody = requestBody;
        this.retryCount = retryCount;
    }

    public void execute(QueueableContext context) {
        Boolean success = false;
        HttpResponse response;

        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(API_ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);

            response = http.send(req);

            if (response.getStatusCode() == 200) {
                success = true;
            } else {
                logFailure(requestBody, response, retryCount);
            }
        } catch (Exception ex) {
            logFailure(requestBody, null, retryCount, ex.getMessage());
        }

        // If not successful and retry limit not reached
        if (!success && retryCount < MAX_RETRIES) {
            Integer delayMinutes = getBackoffTime(retryCount);
            System.debug('⏳ Scheduling next retry in ' + delayMinutes + ' minute(s).');
            scheduleRetry(delayMinutes);
        }
        // If completely failed, fire Platform Event
        else if (!success && retryCount >= MAX_RETRIES) {
            publishFailureEvent(requestBody, response != null ? response.getBody() : 'No response');
        }
    }

    // Calculate exponential backoff (1, 2, 5 min)
    private Integer getBackoffTime(Integer attempt) {
        if (attempt == 1) return 1;
        if (attempt == 2) return 2;
        return 5;
    }

    // Schedule next retry using Queueable chaining after delay
    private void scheduleRetry(Integer minutes) {
        Datetime scheduleTime = Datetime.now().addMinutes(minutes);
        String cron = String.format('{0} {1} {2} {3} {4} ? {5}',
            new List<String>{
                String.valueOf(scheduleTime.second()),
                String.valueOf(scheduleTime.minute()),
                String.valueOf(scheduleTime.hour()),
                String.valueOf(scheduleTime.day()),
                String.valueOf(scheduleTime.month()),
                String.valueOf(scheduleTime.year())
            });
        System.schedule('API_Retry_' + Datetime.now().getTime(),
                        cron,
                        new API_Scheduled_Retry(requestBody, retryCount+1));
    }

    private void logFailure(String reqBody, HttpResponse resp, Integer attempt, String errorMsgOpt) {
        API_Callout_Log__c log = new API_Callout_Log__c();
        log.Endpoint__c = API_ENDPOINT;
        log.Request_Body__c = reqBody;
        log.Retry_Count__c = attempt;
        log.Status__c = 'Failed';
        log.Response_Code__c = resp != null ? String.valueOf(resp.getStatusCode()) : 'No Response';
        log.Response_Body__c = resp != null ? resp.getBody() : errorMsgOpt;
        insert log;
    }
    private void logFailure(String reqBody, HttpResponse resp, Integer attempt) {
        logFailure(reqBody, resp, attempt, 'HTTP Error');
    }

    // Publish platform event for manual intervention
    private void publishFailureEvent(String request, String message) {
        API_Callout_Failure__e eventObj = new API_Callout_Failure__e(
            Endpoint__c = API_ENDPOINT,
            Request__c = request,
            Error_Message__c = message
        );
        EventBus.publish(eventObj);
    }
}
