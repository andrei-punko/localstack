# SES Smoke Checklist (LocalStack)

## 1) Start infrastructure

From repository root:

```bat
docker\1.start-db-container-n-localstack.bat
```

Expected:

- `andd3dfx-localstack` container is up.

## 2) Check SES availability

```bash
docker exec -it andd3dfx-localstack awslocal ses list-identities
```

Expected:

- command succeeds and returns an identities list (possibly empty).

## 3) Verify test identity

```bash
docker exec -it andd3dfx-localstack awslocal ses verify-email-identity --email-address test-local@andd3dfx-software.com
```

Then check:

```bash
docker exec -it andd3dfx-localstack awslocal ses list-identities
```

Expected:

- identity `test-local@andd3dfx-software.com` is present.

## 4) Send test email via SES

Send email:

```bash
docker exec -it andd3dfx-localstack awslocal ses send-email --from test-local@andd3dfx-software.com --destination ToAddresses=test-local@andd3dfx-software.com --message "Subject={Data=LocalStackTest},Body={Text={Data=SES_smoke_test}}"
```

Expected:

- response contains `MessageId`.

## 5) Verify app-side SES flow

Run backend in `localstack` profile:

```bat
docker\2.start-backend-vs-localstack.bat
```

Trigger any app action that sends email and check logs:

- no SES endpoint/credentials errors;
- no queue polling errors related to SES callback queue.

---

## Appendix. Example of how to check LocalStack SES using application API

For multi-line console commands we are using `^`-endings which are dedicated to usual commandline console, not PowerShell console!

```text
Authorization: Bearer <TOKEN>
context: {"company":{"id":1,"agencies":[{"id":-1,"regions":[{"id":-7,"selected":true}]}]}}
```

### Send email to provider (SES path through app):

Firstly, you need to add sender to list of verified identities:
```bash
docker exec andd3dfx-localstack awslocal ses verify-email-identity --email-address test-local@andd3dfx-software.com
```

And check are you present in this list of verified identities:
```bash
docker exec andd3dfx-localstack awslocal ses list-identities
```

Then got response:
```json
{
    "Identities": [
        "test-local@andd3dfx-software.com"
    ]
}
```

### How to purge pending SES tasks

Clearance of queue better to make on stopped application.

Easiest way is to purge SQS-queue, where email sending tasks situated (local_SendMailQueue)

#### Get URL of SendMail queue:

```bash
docker exec andd3dfx-localstack awslocal sqs get-queue-url --queue-name local_SendMailQueue
```

Got an answer:

```json
{
    "QueueUrl": "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_SendMailQueue"
}
```

#### Purge SendMail queue

```bash
docker exec andd3dfx-localstack awslocal sqs purge-queue --queue-url "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_SendMailQueue"
```

(purge-queue could not be called often than 1 time per 60 sec per queue)

#### Check is SendMail queue cleared

```bash
docker exec andd3dfx-localstack awslocal sqs get-queue-attributes --queue-url "http://sqs.us-east-2.localhost.localstack.cloud:4566/000000000000/local_SendMailQueue" --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible
```

Got an answer:

```json
{
    "Attributes": {
        "ApproximateNumberOfMessages": "0",
        "ApproximateNumberOfMessagesNotVisible": "0"
    }
}
```
