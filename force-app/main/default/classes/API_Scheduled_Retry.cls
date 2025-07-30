/**
 * @class API_Scheduled_Retry
 * @description Implements the Schedulable interface to schedule API callout retries.
 *              When executed, it enqueues a Queueable job (API_Callout_Queueable) with the provided request body and retry count.
 *
 * @param requestBody The body of the API request to be retried.
 * @param retryCount The number of retry attempts remaining.
 *
 * @constructor
 *   API_Scheduled_Retry(String body, Integer count)
 *     Initializes the scheduled retry with the given request body and retry count.
 *
 * @method execute(SchedulableContext sc)
 *   Enqueues a new API_Callout_Queueable job with the stored request body and retry count.
 */
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
