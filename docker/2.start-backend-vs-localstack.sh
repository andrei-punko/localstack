#!/usr/bin/env bash
set -euo pipefail

# Run backend locally with AWS beans + LocalStack endpoints.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/run-backend.sh" localstack "" "$@"
