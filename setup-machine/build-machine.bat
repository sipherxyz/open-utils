@echo off
setlocal enabledelayedexpansion

:: Environment Setup Script
:: This script installs all required tools and dependencies

:: Check for administrator privileges
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] This script requires administrator privileges to install software.
    echo Please run this script as Administrator.
    echo.
    echo Right-click on this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [OK] Running with administrator privileges
echo.

:: Configuration
set "VS_INSTALL_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"
set "VS_INSTALLER_PATH=C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
set "CONFIG_URL=https://github.com/sipherxyz/open-utils/blob/main/setup-machine/vsconfig"
set "CONFIG_FILE=vsconfig"

:: Common winget parameters
set "WINGET_COMMON=--accept-source-agreements --accept-package-agreements --silent"

echo ========================================
echo Environment Setup
echo ========================================
echo.

:: ========================================
:: Install Development Tools
:: ========================================
echo [SECTION] Installing Development Tools
echo.

:: Git
echo [INFO] Installing Git...
winget install --id Git.Git -e --source winget %WINGET_COMMON%

:: Git LFS
echo [INFO] Installing Git LFS...
winget install --id GitHub.GitLFS -e %WINGET_COMMON%

:: CMake
echo [INFO] Installing CMake...
winget install --id Kitware.CMake -e --version 3.31.6 %WINGET_COMMON%

echo.

:: ========================================
:: Install Visual Studio 2022 Community
:: ========================================
echo [SECTION] Installing Visual Studio 2022 Community
echo.

echo [INFO] Installing Visual Studio 2022 Community with workloads...
winget install --id Microsoft.VisualStudio.2022.Community -e --silent --disable-interactivity %WINGET_COMMON%

echo.

:: ========================================
:: Install Additional Tools
:: ========================================
echo [SECTION] Installing Additional Tools
echo.

:: Python
echo [INFO] Installing Python...
winget install --id Python.Python.3.12 -e %WINGET_COMMON%

:: Visual Studio Code
echo [INFO] Installing Visual Studio Code...
winget install --id Microsoft.VisualStudioCode -e %WINGET_COMMON%

:: Epic Games Launcher
echo [INFO] Installing Epic Games Launcher...
winget install -e --id EpicGames.EpicGamesLauncher %WINGET_COMMON%

:: Fork Git Client
echo [INFO] Installing Fork Git Client...
winget install --id=Fork.Fork -e %WINGET_COMMON%

echo.

:: Apache Ant
echo [INFO] Installing Apache Ant...
curl -LO "https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.15-bin.zip"
unzip apache-ant-1.10.15-bin.zip
move apache-ant-1.10.15 "C:\Program Files\apache-ant-1.10.15"

echo.

:: ========================================
:: Configure Visual Studio
:: ========================================
echo [SECTION] Configuring Visual Studio
echo.

:: Download VS configuration file
echo [INFO] Downloading Visual Studio configuration...
curl -LO "%CONFIG_URL%"

:: Get absolute path to downloaded config file
set "CONFIG_FILE_ABS=%CD%\%CONFIG_FILE%"

:: Apply VS configuration
if exist "%VS_INSTALLER_PATH%" (
    echo [INFO] Applying Visual Studio configuration...
    "%VS_INSTALLER_PATH%" modify --installPath "%VS_INSTALL_PATH%" --config "%CONFIG_FILE_ABS%" --installWhileDownloading --passive --force
) else (
    echo [WARNING] Visual Studio installer not found at expected path
    echo [INFO] Skipping Visual Studio configuration
)

:: Clean up downloaded file
if exist "%CONFIG_FILE%" (
    del "%CONFIG_FILE%"
    echo [INFO] Cleaned up configuration file
)

echo.

:: ========================================
:: Summary
:: ========================================
echo [SECTION] Setup Summary
echo.

echo [SUCCESS] All components installed successfully!
echo.
echo Next steps:
echo 1. Restart your computer to ensure all tools are properly registered
echo 2. Open Visual Studio and sign in with your Microsoft account

echo.
echo ========================================
echo Setup complete!
echo ========================================

pause