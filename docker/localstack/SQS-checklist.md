# SQS Smoke Checklist (LocalStack)

## 1) Start infrastructure

From repository root:

```bat
docker\1.start-db-container-n-localstack.bat
```

Expected:

- `andd3dfx-localstack` container is up.

## 2) Run backend in `localstack` profile

```bat
docker\2.start-backend-vs-localstack.bat
```

Expected:

- backend starts in `localstack` profile.

## 3) List queues

```bash
docker exec -it andd3dfx-localstack awslocal sqs list-queues
```

Expected:

- queue URLs are returned (based on `aws.*-queue` properties).

## 4) Get queue URL

```bash
docker exec -it andd3dfx-localstack awslocal sqs get-queue-url --queue-name <QUEUE_NAME>
```

Expected:

- valid `QueueUrl` in output.

## 5) Send test message

```bash
docker exec -it andd3dfx-localstack awslocal sqs send-message --queue-url <QUEUE_URL> --message-body '{"test":true,"source":"manual"}'
```

Important:

- do not send ad-hoc JSON messages to application queues (for example, `local_SendSmsQueue`, `local_SendMailQueue`);
- those queues are consumed by backend listeners that expect specific payload formats (usually existing log IDs).

Expected:

- response contains `MessageId`.

## 6) Receive message

```bash
docker exec -it andd3dfx-localstack awslocal sqs receive-message --queue-url <QUEUE_URL> --max-number-of-messages 10
```

Expected:

- message appears in response.

## 7) Purge queue (optional cleanup)

```bash
docker exec -it andd3dfx-localstack awslocal sqs purge-queue --queue-url <QUEUE_URL>
```

Expected:

- queue is emptied.

---

## Appendix. Example of how to check LocalStack SQS using dedicated manual queue

### Create dedicated manual queue:

```bash
docker exec -it andd3dfx-localstack awslocal sqs create-queue --queue-name local_ManualSmokeQueue
```

### Get queue URL:

```bash
docker exec -it andd3dfx-localstack awslocal sqs get-queue-url --queue-name local_ManualSmokeQueue
```

Got response:

```json
{
    "QueueUrl": "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_ManualSmokeQueue"
}
```

Optional cleanup before test:

```bash
docker exec -it andd3dfx-localstack awslocal sqs purge-queue --queue-url "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_ManualSmokeQueue"
```

### Send test message:

```bash
docker exec -it andd3dfx-localstack awslocal sqs send-message --queue-url "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_ManualSmokeQueue" --message-body '{"test":true,"source":"manual","channel":"sqs-smoke"}'
```

Got response:

```json
{
    "MD5OfMessageBody": "b7fc0bfad8efdb9b615fcf69d088bf47",
    "MessageId": "86141b42-3b67-43e6-a889-eccf5fd68a7a"
}
```

### Check queue attributes:

```bash
docker exec -it andd3dfx-localstack awslocal sqs get-queue-attributes --queue-url "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_ManualSmokeQueue" --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible
```

Got response:

```json
{
    "Attributes": {
        "ApproximateNumberOfMessages": "2",
        "ApproximateNumberOfMessagesNotVisible": "0"
    }
}
```

### Receive message from manual queue:

```bash
docker exec -it andd3dfx-localstack awslocal sqs receive-message --queue-url "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_ManualSmokeQueue" --max-number-of-messages 10
```

Got an answer:

```json
{
    "Messages": [
        {
            "MessageId": "86141b42-3b67-43e6-a889-eccf5fd68a7a",
            "ReceiptHandle": "OTI1M2Y4MWMtYmQ0ZC00OGJmLWFjNWEtNmQzYTcwMTlkZTVjIGFybjphd3M6c3FzOnVzLWVhc3QtMjowMDAwMDAwMDAwMDA6bG9jYWxfTWFudWFsU21va2VRdWV1ZSA4NjE0MWI0Mi0zYjY3LTQzZTYtYTg4OS1lY2NmNWZkNjhhN2EgMTc3MzA5MTQ0MS4yNTE5NTYy",
            "MD5OfBody": "b7fc0bfad8efdb9b615fcf69d088bf47",
            "Body": "{\"test\":true,\"source\":\"manual\",\"channel\":\"sqs-smoke\"}"
        }
    ]
}
```

Message is present in response (if backend listener did not consume it yet).
