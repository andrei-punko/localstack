# Example of LocalStack usage 

This setup allows running the backend locally with AWS beans enabled and AWS infrastructure emulated by LocalStack.

## Quick way

Windows:

```bat
docker\1.start-db-container-n-localstack.bat
```

Linux/macOS:

```bash
chmod +x docker/1.start-db-container-n-localstack.sh docker/run-backend.sh docker/2.start-backend-vs-localstack.sh
docker/1.start-db-container-n-localstack.sh
```

## Non-quick way

### 1) Start infrastructure (DB + LocalStack)

From repository root:

```bash
docker compose -f docker/docker-compose.yml up -d --build db-andd3dfx-server localstack
```

On Windows you can use:

```bat
docker\1.start-db-container-n-localstack.bat
```

On Linux/macOS you can use:

```bash
chmod +x docker/1.start-db-container-n-localstack.sh
docker/1.start-db-container-n-localstack.sh
```

### 2) Start backend application with `localstack` profile

***! IMPORTANT: The backend application itself is not part of this repository.  
This repository contains only LocalStack-related configuration and startup scripts used by that application.***

Use Spring profile `localstack`:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=localstack
```

Or with JVM argument:

```bash
./mvnw spring-boot:run -Dspring-boot.run.jvmArguments="-Dspring.profiles.active=localstack"
```

On Windows from repository root you can use:

```bat
docker\2.start-backend-vs-localstack.bat
```

On Linux/macOS from repository root you can use:

```bash
chmod +x docker/run-backend.sh docker/2.start-backend-vs-localstack.sh
docker/2.start-backend-vs-localstack.sh
```

If you need a clean rebuild before start (for example after branch switch), run:

```bash
./mvnw clean
docker/2.start-backend-vs-localstack.sh
```

The script validates local DB readiness before backend startup:

- checks that `db-andd3dfx-server` container is running (hard check);
- if DB is not running, it prints a hint to start infrastructure with `docker\1.start-db-container-n-localstack.bat`.

## Notes

- `application-localstack.properties` is the source of AWS resource names both for Spring app and LocalStack bootstrap.
- This file is mounted into LocalStack container as `/etc/localstack/application-aws-resources.properties` (see `docker/docker-compose.yml`).
- Script `docker/localstack/init/10-create-resources.sh` reads `aws.document-bucket` from this config and creates S3 bucket with this exact name.
- The same script reads all properties matching `aws.*-queue` and auto-creates corresponding SQS queues.
- AWS clients are redirected to `http://localhost:4566`.
- LocalStack resources are initialized from the same `application-localstack.properties` file.

## Service checklists

- [S3 checklist](docker/localstack/S3-checklist.md)
- [SQS checklist](docker/localstack/SQS-checklist.md)
- [SES checklist](docker/localstack/SES-checklist.md)
