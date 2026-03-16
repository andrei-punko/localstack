#!/bin/sh
set -eu

PROPS_FILE="${AWS_RESOURCES_PROPS_FILE:-/etc/localstack/application-aws-resources.properties}"
AWS_REGION="${AWS_DEFAULT_REGION:-us-east-2}"

# Expected properties in $PROPS_FILE (mounted from application-localstack.properties):
# - required for S3 bootstrap: aws.document-bucket
# - used for SQS auto-creation: every key matching aws.*-queue
# - optional for SES bootstrap: sender.email-address

if [ ! -f "$PROPS_FILE" ]; then
  echo "LocalStack init: properties file not found: $PROPS_FILE"
  exit 1
fi

echo "LocalStack init: creating resources from $PROPS_FILE (region: $AWS_REGION)"

# Create S3 bucket from aws.document-bucket property.
BUCKET_NAME="$(awk -F= '/^[[:space:]]*aws\.document-bucket[[:space:]]*=/{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}' "$PROPS_FILE")"
if [ -n "${BUCKET_NAME:-}" ]; then
  if awslocal --region "$AWS_REGION" s3api head-bucket --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
    echo "LocalStack init: S3 bucket already exists: $BUCKET_NAME"
  else
    awslocal --region "$AWS_REGION" s3api create-bucket --bucket "$BUCKET_NAME" \
      --create-bucket-configuration "LocationConstraint=$AWS_REGION" >/dev/null
    echo "LocalStack init: S3 bucket created: $BUCKET_NAME (region: $AWS_REGION)"
  fi
fi

# Create every queue defined as aws.*-queue.
awk -F= '
  /^[[:space:]]*aws\..*-queue[[:space:]]*=/ {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
    if ($2 != "") print $2
  }
' "$PROPS_FILE" | while IFS= read -r queue_name; do
  awslocal --region "$AWS_REGION" sqs create-queue --queue-name "$queue_name" >/dev/null 2>&1 || true
  echo "LocalStack init: SQS queue ready: $queue_name"
done

# Verify sender identity for SES if provided by properties.
SENDER_EMAIL="$(awk -F= '/^[[:space:]]*sender\.email-address[[:space:]]*=/{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}' "$PROPS_FILE")"
if [ -n "${SENDER_EMAIL:-}" ]; then
  awslocal --region "$AWS_REGION" ses verify-email-identity --email-address "$SENDER_EMAIL" >/dev/null 2>&1 || true
  echo "LocalStack init: SES sender identity ready: $SENDER_EMAIL"
fi
