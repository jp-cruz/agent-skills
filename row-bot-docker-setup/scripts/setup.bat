@echo off
REM Row-Bot Docker Setup - Windows preflight
REM
REM The full interactive setup (network binding, multi-instance naming,
REM LLM API keys, smart defaults) lives in setup.sh. On Windows, run it
REM through WSL or Git Bash. This script checks prerequisites and points
REM you to the right path; it also offers a minimal manual fallback.

setlocal

REM Work from the repo root (this script lives in scripts\)
pushd "%~dp0.."

echo.
echo ================================================================
echo     Row-Bot Docker Setup - Windows Preflight
echo ================================================================
echo.

REM ----------------------------------------------------------------
REM 1. Docker installed?
REM ----------------------------------------------------------------
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker not found.
    echo         Install Docker Desktop: https://www.docker.com/products/docker-desktop
    echo         During install, enable the WSL 2 option.
    echo         See DOCKER_GUIDE_FOR_BEGINNERS.md for a walkthrough.
    popd
    exit /b 1
)
for /f "tokens=*" %%i in ('docker --version') do echo [OK] %%i

REM ----------------------------------------------------------------
REM 2. Docker daemon running?
REM ----------------------------------------------------------------
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is installed but not running.
    echo         Start Docker Desktop, wait for "Docker is running", then re-run this script.
    popd
    exit /b 1
)
echo [OK] Docker daemon is running

REM ----------------------------------------------------------------
REM 3. Docker Compose?
REM ----------------------------------------------------------------
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Docker Compose not found. Reinstall Docker Desktop.
        popd
        exit /b 1
    )
)
echo [OK] Docker Compose is available

REM ----------------------------------------------------------------
REM 4. Find a bash for the full interactive setup
REM ----------------------------------------------------------------
echo.
echo ----------------------------------------------------------------
echo  RECOMMENDED: run the full interactive setup
echo ----------------------------------------------------------------
echo.
echo  setup.sh asks the questions that matter (localhost vs LAN access,
echo  one or multiple Row-Bot instances, local Ollama vs cloud API keys)
echo  and writes a safe .env for you.
echo.

set BASH_FOUND=0

wsl.exe --status >nul 2>&1
if not errorlevel 1 (
    set BASH_FOUND=1
    echo  Option A - WSL detected. Run:
    echo      wsl bash ./setup.sh
    echo.
)

where bash >nul 2>&1
if not errorlevel 1 (
    set BASH_FOUND=1
    echo  Option B - bash detected ^(Git Bash^). Run:
    echo      bash ./setup.sh
    echo.
)

if "%BASH_FOUND%"=="0" (
    echo  No WSL or Git Bash found. Easiest fixes:
    echo    - Install Git for Windows ^(includes Git Bash^): https://git-scm.com/download/win
    echo    - Or enable WSL: open PowerShell as admin and run  wsl --install
    echo.
)

REM ----------------------------------------------------------------
REM 5. Manual fallback (no bash): minimal .env + edit by hand
REM ----------------------------------------------------------------
echo ----------------------------------------------------------------
echo  FALLBACK: manual setup ^(no bash needed^)
echo ----------------------------------------------------------------
echo.
if exist .env (
    echo  [OK] .env already exists - review it in a text editor.
) else (
    copy .env.example .env >nul
    echo  [OK] Created .env from .env.example
)
echo.
echo  1. Open .env in Notepad and review:
echo       ROW_BOT_BIND   ^(keep 127.0.0.1 for localhost-only - most secure^)
echo       ROW_BOT_PORT   ^(default 8080^)
echo       Uncomment an API key line if you use OpenRouter/OpenAI/Anthropic
echo       ^(pick the provider and model later inside Row-Bot: Settings - Models^)
echo  2. Start Row-Bot:    docker-compose up -d
echo  3. Open:             http://localhost:8080
echo  4. Verify:           scripts\preflight-check.bat
echo.
echo  Data lives in Docker volumes - safe across restarts and upgrades.
echo.

popd
endlocal
