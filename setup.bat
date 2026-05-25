@echo off
REM Thoth Docker Template Setup Script for Windows
REM Initializes .env, creates data directories, and validates prerequisites

setlocal enabledelayedexpansion

echo.
echo ================================================================
echo     Thoth Docker Template Setup
echo ================================================================
echo.

REM Check if .env exists
if exist .env (
    echo [WARNING] .env already exists. Skipping creation.
) else (
    echo [INFO] Creating .env from .env.example
    copy .env.example .env
    echo [INFO] .env created. Please edit to customize paths and settings.
)

echo [INFO] Detected OS: Windows

REM Read .env values (simple version - assumes standard paths)
for /f "tokens=2 delims==" %%i in ('findstr "^THOTH_DATA_DIR=" .env') do set THOTH_DATA_DIR=%%i
for /f "tokens=2 delims==" %%i in ('findstr "^THOTH_WORKSPACE_DIR=" .env') do set THOTH_WORKSPACE_DIR=%%i
for /f "tokens=2 delims==" %%i in ('findstr "^THOTH_PORT=" .env') do set THOTH_PORT=%%i
for /f "tokens=2 delims==" %%i in ('findstr "^OLLAMA_BASE_URL=" .env') do set OLLAMA_BASE_URL=%%i

echo.
echo Configuration:
echo   Data Directory:      %THOTH_DATA_DIR%
echo   Workspace Directory: %THOTH_WORKSPACE_DIR%
echo   Thoth Port:          %THOTH_PORT%
echo   Ollama URL:          %OLLAMA_BASE_URL%

echo.
echo [INFO] Creating data directories
if not exist "%THOTH_DATA_DIR%" mkdir "%THOTH_DATA_DIR%"
if not exist "%THOTH_WORKSPACE_DIR%" mkdir "%THOTH_WORKSPACE_DIR%"
echo [INFO] Directories created

echo.
echo [INFO] Checking Docker installation
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker not found. Please install Docker Desktop for Windows.
    exit /b 1
)
for /f "tokens=*" %%i in ('docker --version') do echo   ✓ %%i

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose not found
    exit /b 1
)
echo [INFO] Docker Compose is installed

echo.
echo [INFO] Checking Ollama connectivity
powershell -Command "(New-Object System.Net.WebClient).DownloadString('%OLLAMA_BASE_URL%/api/tags')" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Ollama is not reachable at %OLLAMA_BASE_URL%
    echo [INFO] Start Ollama before running docker-compose up
) else (
    echo [INFO] Ollama is running and reachable
)

echo.
echo ================================================================
echo [SUCCESS] Setup complete!
echo ================================================================
echo.
echo Next steps:
echo   1. Review and customize .env if needed
echo   2. Ensure Ollama is running
echo   3. Start Thoth: docker-compose up -d
echo   4. Open http://localhost:%THOTH_PORT%
echo.
echo Useful commands:
echo   docker-compose up -d          # Start in background
echo   docker-compose logs -f        # View logs
echo   docker-compose ps             # Check status
echo   docker-compose exec thoth bash # Open shell in container
echo.
