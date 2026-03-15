@echo off
setlocal

REM Start local infrastructure containers for backend.
set "SCRIPT_DIR=%~dp0"
set "COMPOSE_FILE=%SCRIPT_DIR%docker-compose.yml"
set "DB_SERVICE=db-andd3dfx-server"
set "LOCALSTACK_SERVICE=localstack"

if not exist "%COMPOSE_FILE%" (
    echo [ERROR] docker-compose file not found: "%COMPOSE_FILE%"
    exit /b 1
)

echo Starting infrastructure containers "%DB_SERVICE%" and "%LOCALSTACK_SERVICE%" using:
echo   %COMPOSE_FILE%
echo.

docker compose -f "%COMPOSE_FILE%" up -d --build %DB_SERVICE% %LOCALSTACK_SERVICE%
if errorlevel 1 (
    echo.
    echo [ERROR] Failed to start infrastructure containers.
    exit /b 1
)

echo.
echo Infrastructure containers are up.
echo To check status: docker compose -f "%COMPOSE_FILE%" ps %DB_SERVICE% %LOCALSTACK_SERVICE%
echo DB logs:         docker compose -f "%COMPOSE_FILE%" logs -f %DB_SERVICE%
echo LocalStack logs: docker compose -f "%COMPOSE_FILE%" logs -f %LOCALSTACK_SERVICE%
echo To stop:         docker compose -f "%COMPOSE_FILE%" stop %DB_SERVICE% %LOCALSTACK_SERVICE%
