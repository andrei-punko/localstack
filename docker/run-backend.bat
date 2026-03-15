@echo off
setlocal

REM Common backend launcher:
REM   arg1 - spring profile
REM   arg2 - optional single JVM arg (for spring-boot.run.jvmArguments), pass "" if not needed
REM   arg3+ - additional mvn arguments

set "SPRING_PROFILE=%~1"
set "EXTRA_JVM_ARG=%~2"
shift
shift
set "EXTRA_ARGS="

:collect_extra_args
if "%~1"=="" goto after_collect
set "EXTRA_ARGS=%EXTRA_ARGS% "%~1""
shift
goto collect_extra_args

:after_collect

if "%SPRING_PROFILE%"=="" (
    echo [ERROR] Missing required profile argument.
    echo [INFO] Do not run this script directly.
    echo [INFO] Use the entry script instead:
    echo [INFO]   docker\2.start-backend-vs-localstack.bat
    echo Usage: docker\run-backend.bat ^<profile^> ["-Dprop=value"] [extra maven args...]
    goto :fail
)

set "SCRIPT_DIR=%~dp0"
REM docker\run-backend.bat -> repo root is parent directory.
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
set "DB_CONTAINER=db-andd3dfx-server"

set "DB_RUNNING="
for /f "usebackq delims=" %%A in (`docker inspect -f "{{.State.Running}}" %DB_CONTAINER% 2^>nul`) do set "DB_RUNNING=%%A"
if /I not "%DB_RUNNING%"=="true" (
    echo [ERROR] DB container "%DB_CONTAINER%" is not running.
    echo         Start DB first: docker\1.start-db-container-n-localstack.bat
    echo.
    echo Detected running postgres containers:
    docker ps --filter "ancestor=postgres" --format "  - {{.Names}}"
    goto :fail
)

echo Starting backend with Spring profile: %SPRING_PROFILE%
echo.

pushd "%REPO_ROOT%" >nul
if defined EXTRA_JVM_ARG (
    call mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=%SPRING_PROFILE% -Dspring-boot.run.jvmArguments="%EXTRA_JVM_ARG%" %EXTRA_ARGS%
) else (
    call mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=%SPRING_PROFILE% %EXTRA_ARGS%
)
set "EXIT_CODE=%ERRORLEVEL%"
popd >nul

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Backend startup failed.
    goto :fail_with_code
)

exit /b 0

:fail
echo.
pause
exit /b 1

:fail_with_code
echo.
pause
exit /b %EXIT_CODE%
