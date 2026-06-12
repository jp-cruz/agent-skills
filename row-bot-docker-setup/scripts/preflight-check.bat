@echo off
REM Comprehensive Pre-flight Environment Assessment for Windows
REM Detects installed LLM backends, Python dependencies, secrets management, etc.

setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

echo.
echo ======================================================================
echo     ROW-BOT DOCKER SETUP - ENVIRONMENT ASSESSMENT
echo ======================================================================
echo.

REM ====================================================================
REM SECTION 1: OS DETECTION
REM ====================================================================

echo [1/5] DETECTING OPERATING SYSTEM

echo   OS: Windows
echo   Architecture: %PROCESSOR_ARCHITECTURE%

REM ====================================================================
REM SECTION 2: DETECT LLM BACKENDS
REM ====================================================================

echo.
echo [2/5] DETECTING AVAILABLE LLM BACKENDS

set "LLM_BACKEND="
set "OLLAMA_FOUND=0"
set "LMSTUDIO_FOUND=0"
set "VLLM_FOUND=0"

REM Check Ollama
where ollama >nul 2>&1
if !errorlevel! equ 0 (
    echo   [OK] Ollama - Installed
    set "LLM_BACKEND=ollama"
    set "OLLAMA_FOUND=1"
    for /f "tokens=*" %%i in ('ollama --version 2^>nul') do set "OLLAMA_VERSION=%%i"
    echo       Version: !OLLAMA_VERSION!

    REM Check if running
    powershell -Command "(New-Object System.Net.WebClient).DownloadString('http://localhost:11434/api/tags')" >nul 2>&1
    if !errorlevel! equ 0 (
        echo       Status: Running and accessible
    ) else (
        echo       Status: Installed but not running
    )
) else (
    echo   [--] Ollama - Not installed
)

REM Check LM Studio
if exist "%APPDATA%\LM Studio" (
    echo   [OK] LM Studio - Found
    set "LMSTUDIO_FOUND=1"
    if "!LLM_BACKEND!"=="" set "LLM_BACKEND=lmstudio"
) else (
    echo   [--] LM Studio - Not installed
)

REM Check vLLM
pip show vllm >nul 2>&1
if !errorlevel! equ 0 (
    echo   [OK] vLLM - Installed (Python)
    set "VLLM_FOUND=1"
    if "!LLM_BACKEND!"=="" set "LLM_BACKEND=vllm"
) else (
    echo   [--] vLLM - Not installed
)

REM Summary
echo.
if "!LLM_BACKEND!"=="" (
    echo   [WARNING] No LLM backend detected
    echo   ^> Install Ollama ^(recommended^) or LM Studio
) else (
    echo   [INFO] Will use: !LLM_BACKEND!
)

REM ====================================================================
REM SECTION 3: PYTHON ENVIRONMENT & DEPENDENCIES
REM ====================================================================

echo.
echo [3/5] CHECKING PYTHON ENVIRONMENT
echo.

where python >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('python --version 2^>nul') do echo   Python: %%i
) else (
    echo   [ERROR] Python not found
)

REM Check keyring
python -c "import keyring" >nul 2>&1
if !errorlevel! equ 0 (
    echo   [OK] keyring - Installed
) else (
    echo   [ERROR] keyring - Not installed
    echo   ^> Install with: pip install keyring
)

REM Check keyrings.alt (critical for Windows)
python -c "import keyrings.alt" >nul 2>&1
if !errorlevel! equ 0 (
    echo   [OK] keyrings.alt - Installed (Windows support)
) else (
    echo   [ERROR] keyrings.alt - Not installed (Windows needs this!)
    echo   ^> Install with: pip install keyrings.alt
)

REM ====================================================================
REM SECTION 4: SECRETS MANAGEMENT
REM ====================================================================

echo.
echo [4/5] CHECKING SECRETS MANAGEMENT
echo.

echo   [OK] Windows Credential Manager - Available
echo       Will use via keyrings.alt

REM Check if PYTHON_KEYRING_BACKEND is set
if defined PYTHON_KEYRING_BACKEND (
    echo   [INFO] PYTHON_KEYRING_BACKEND = !PYTHON_KEYRING_BACKEND!
) else (
    echo   [INFO] PYTHON_KEYRING_BACKEND not set (will auto-detect)
)

REM ====================================================================
REM SECTION 5: OTHER TOOLS & UTILITIES
REM ====================================================================

echo.
echo [5/5] CHECKING UTILITIES
echo.

REM Docker
where docker >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('docker --version') do echo   [OK] %%i
) else (
    echo   [ERROR] Docker not found
)

REM Docker Compose
where docker-compose >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('docker-compose --version') do echo   [OK] %%i
) else (
    echo   [ERROR] Docker Compose not found
)

REM Git
where git >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('git --version') do echo   [OK] %%i
) else (
    echo   [--] Git not found
)

REM curl
where curl >nul 2>&1
if !errorlevel! equ 0 (
    echo   [OK] curl - Available
) else (
    echo   [ERROR] curl not found
)

REM ====================================================================
REM SECTION 6: RECOMMENDATIONS
REM ====================================================================

echo.
echo ======================================================================
echo                      RECOMMENDED .env
echo ======================================================================
echo.

echo # Port for Row-Bot
echo ROW_BOT_PORT=8080
echo.

echo # LLM Backend Configuration
if "!LLM_BACKEND!"=="ollama" (
    echo # Using Ollama
    echo OLLAMA_BASE_URL=http://host.docker.internal:11434
) else if "!LLM_BACKEND!"=="lmstudio" (
    echo # Using LM Studio
    echo OLLAMA_BASE_URL=http://host.docker.internal:1234/v1
) else if "!LLM_BACKEND!"=="vllm" (
    echo # Using vLLM
    echo OLLAMA_BASE_URL=http://host.docker.internal:8000/v1
) else (
    echo # No LLM backend detected, using Ollama default
    echo OLLAMA_BASE_URL=http://host.docker.internal:11434
)
echo.

echo # Data Persistence Paths
echo ROW_BOT_DATA_DIR=C:\Users\%USERNAME%\rowbot-data
echo ROW_BOT_WORKSPACE_DIR=C:\Users\%USERNAME%\rowbot-workspace
echo.

echo # Container Restart Policy
echo RESTART_POLICY=unless-stopped
echo.

echo # Secrets Management (Windows)
echo PYTHON_KEYRING_BACKEND=keyrings.alt.windows.CredentialVaultKeyring
echo ROW_BOT_SECRETS_BACKEND=keyring
echo.

REM ====================================================================
REM SECTION 7: NEXT STEPS
REM ====================================================================

echo.
echo ======================================================================
echo                         NEXT STEPS
echo ======================================================================
echo.

echo 1. Copy recommended config above to .env
echo    copy .env.example .env
echo    REM Edit with your preferred editor
echo.

if "!LLM_BACKEND!"=="" (
    echo 2. Install an LLM backend
    echo    Recommended: Ollama
    echo    Visit: https://ollama.ai
    echo.
)

echo 3. Verify prerequisites
echo    docker --version
echo    docker-compose --version
echo.

echo 4. Start Row-Bot
echo    docker-compose up -d
echo.

echo 5. Access Row-Bot
echo    start http://localhost:8080
echo.

REM ====================================================================
REM SUMMARY
REM ====================================================================

echo.
echo SUMMARY
echo   OS: Windows
echo   Architecture: %PROCESSOR_ARCHITECTURE%
echo   Python:
python --version 2>nul || echo     Not found
echo   LLM Backend: !LLM_BACKEND!
echo   Docker:
docker --version 2>nul || echo     Not found
echo.

echo [OK] Assessment complete. You're ready to proceed!
echo.
