public class API_Scheduled_Retry implements Schedulable {
    private String requestBody;
    private Integer retryCount;

    public API_Scheduled_Retry(String body, Integer count) {
        this.requestBody = body;
        this.retryCount = count;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new API_Callout_Queueable(requestBody, retryCount));
    }
}
