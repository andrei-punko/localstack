@echo off
setlocal

REM Run backend locally with AWS beans + LocalStack endpoints.
set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%run-backend.bat" localstack "" %*
exit /b %ERRORLEVEL%
