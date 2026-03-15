# S3 Smoke Checklist (LocalStack)

## 1) Start infrastructure

From repository root:

```bat
docker\1.start-db-container-n-localstack.bat
```

Expected:

- `andd3dfx-localstack` container is up.

Check:

```bash
docker ps --filter "name=andd3dfx-localstack"
```

## 2) Check S3 availability

```bash
docker exec -it andd3dfx-localstack awslocal s3 ls
```

Expected:

- command succeeds without connection errors.

## 3) Check document bucket from profile

Bucket from `application-localstack.properties`:

- `aws.document-bucket=local-andd3dfx-backend-document-s3`

```bash
docker exec -it andd3dfx-localstack awslocal s3 ls s3://local-andd3dfx-backend-document-s3
```

Expected:

- no `NoSuchBucket` error.

If bucket is missing (`NoSuchBucket`), create it manually:

```bash
docker exec -it andd3dfx-localstack awslocal --region us-east-2 s3api create-bucket --bucket local-andd3dfx-backend-document-s3 --create-bucket-configuration LocationConstraint=us-east-2
```

## 4) Run backend in `localstack` profile

```bat
docker\2.start-backend-vs-localstack.bat
```

Expected:

- backend starts without S3-related errors.

## 5) Verify object write/read

After any app action that stores a document:

```bash
docker exec -it andd3dfx-localstack awslocal s3 ls s3://local-andd3dfx-backend-document-s3 --recursive
```

Take one key from output and check metadata:

```bash
docker exec -it andd3dfx-localstack awslocal s3api head-object --bucket local-andd3dfx-backend-document-s3 --key "<OBJECT_KEY>"
```

Expected:

- object is present and metadata is returned.

---

## Appendix. Example of how to check LocalStack S3 using application API

For multi-line console commands we are using `^`-endings which are dedicated to usual commandline console, not PowerShell console!

### Prepare File for `File upload`:

```bash
echo 'Tmp file content' > C:\tmp-file-to-send.txt
```

### Check presence of object in LocalStack S3:

```bash
docker exec andd3dfx-localstack awslocal s3 ls s3://local-andd3dfx-backend-document-s3 --recursive
```

Got an answer:

```
2026-03-09 14:34:04         18 userfile/2026/03/262
```

### Check object metadata in LocalStack S3:

```bash
docker exec andd3dfx-localstack awslocal s3api head-object --bucket local-andd3dfx-backend-document-s3 --key "userfile/2026/03/262"
```

Got an answer:

```json
{
    "AcceptRanges": "bytes",
    "LastModified": "Mon, 09 Mar 2026 14:34:04 GMT",
    "ContentLength": 18,
    "ETag": "\"8008fc219e955ad56e92a58936a99e4d\"",
    "ContentType": "application/octet-stream",
    "ServerSideEncryption": "AES256",
    "Metadata": {}
}
```
