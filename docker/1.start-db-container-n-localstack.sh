#!/usr/bin/env bash
set -euo pipefail

# Start local infrastructure containers for backend.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
DB_SERVICE="db-andd3dfx-server"
LOCALSTACK_SERVICE="localstack"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "[ERROR] docker-compose file not found: $COMPOSE_FILE"
  exit 1
fi

echo "Starting infrastructure containers \"$DB_SERVICE\" and \"$LOCALSTACK_SERVICE\" using:"
echo "  $COMPOSE_FILE"
echo

docker compose -f "$COMPOSE_FILE" up -d --build "$DB_SERVICE" "$LOCALSTACK_SERVICE"

echo
echo "Infrastructure containers are up."
echo "To check status: docker compose -f \"$COMPOSE_FILE\" ps $DB_SERVICE $LOCALSTACK_SERVICE"
echo "DB logs:         docker compose -f \"$COMPOSE_FILE\" logs -f $DB_SERVICE"
echo "LocalStack logs: docker compose -f \"$COMPOSE_FILE\" logs -f $LOCALSTACK_SERVICE"
echo "To stop:         docker compose -f \"$COMPOSE_FILE\" stop $DB_SERVICE $LOCALSTACK_SERVICE"
