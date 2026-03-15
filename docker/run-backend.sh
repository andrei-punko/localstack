#!/usr/bin/env bash
set -euo pipefail

# Common backend launcher:
#   arg1 - spring profile
#   arg2 - optional single JVM arg (for spring-boot.run.jvmArguments), pass "" if not needed
#   arg3+ - additional mvn arguments

SPRING_PROFILE="${1:-}"
EXTRA_JVM_ARG="${2:-}"
if [ $# -gt 0 ]; then shift; fi
if [ $# -gt 0 ]; then shift; fi
declare -a EXTRA_ARGS=()
if [ $# -gt 0 ]; then
  EXTRA_ARGS=("$@")
fi

if [ -z "$SPRING_PROFILE" ]; then
  echo "[ERROR] Missing required profile argument."
  echo "[INFO] Do not run this script directly."
  echo "[INFO] Use the entry script instead:"
  echo "[INFO]   docker/2.start-backend-vs-localstack.sh"
  echo "Usage: docker/run-backend.sh <profile> [\"-Dprop=value\"] [extra maven args...]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# docker/run-backend.sh -> repo root is parent directory.
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_CONTAINER="db-andd3dfx-server"

DB_RUNNING="$(docker inspect -f '{{.State.Running}}' "$DB_CONTAINER" 2>/dev/null || true)"
if [ "$DB_RUNNING" != "true" ]; then
  echo "[ERROR] DB container \"$DB_CONTAINER\" is not running."
  echo "        Start DB first: docker/1.start-db-container-n-localstack.sh"
  echo
  echo "Detected running postgres containers:"
  docker ps --filter "ancestor=postgres" --format "  - {{.Names}}"
  exit 1
fi

echo "Starting backend with Spring profile: $SPRING_PROFILE"
echo

cd "$REPO_ROOT"

if [ -n "$EXTRA_JVM_ARG" ]; then
  if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    ./mvnw spring-boot:run \
      -Dspring-boot.run.profiles="$SPRING_PROFILE" \
      "-Dspring-boot.run.jvmArguments=$EXTRA_JVM_ARG" \
      "${EXTRA_ARGS[@]}"
  else
    ./mvnw spring-boot:run \
      -Dspring-boot.run.profiles="$SPRING_PROFILE" \
      "-Dspring-boot.run.jvmArguments=$EXTRA_JVM_ARG"
  fi
else
  if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    ./mvnw spring-boot:run \
      -Dspring-boot.run.profiles="$SPRING_PROFILE" \
      "${EXTRA_ARGS[@]}"
  else
    ./mvnw spring-boot:run \
      -Dspring-boot.run.profiles="$SPRING_PROFILE"
  fi
fi
