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

:: Check for WinGet and install if not present
echo [INFO] Checking for WinGet...
winget --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [INFO] WinGet not found. Installing WinGet...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$progressPreference = 'silentlyContinue'; Write-Host '[INFO] Installing WinGet PowerShell module from PSGallery...'; Install-PackageProvider -Name NuGet -Force | Out-Null; Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null; Write-Host '[INFO] Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet...'; Repair-WinGetPackageManager -AllUsers; Write-Host '[OK] WinGet installation complete.'"
    echo.
    :: Verify WinGet installation
    winget --version >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] WinGet installation failed. Please install WinGet manually and try again.
        pause
        exit /b 1
    )
    echo [OK] WinGet is now available
) else (
    echo [OK] WinGet is already installed
)
echo.

:: Configuration
set "VS_INSTALL_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"
set "VS_INSTALLER_PATH=C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
set "CONFIG_URL=https://raw.githubusercontent.com/sipherxyz/open-utils/refs/heads/main/setup-machine/vsconfig"
set "CONFIG_FILE=vsconfig"

:: Common winget parameters
set "WINGET_COMMON=--accept-source-agreements --accept-package-agreements --silent"

echo ========================================
echo Environment Setup
echo ========================================
echo.

:: Fork Git Client
echo [INFO] Installing Fork Git Client...
winget install --id=Fork.Fork -e %WINGET_COMMON%
echo.

:: ========================================
:: Install Development Tools
:: ========================================
echo [SECTION] Installing Development Tools
echo.

:: Git
echo [INFO] Installing Git...
winget install --id Git.Git -e --source winget %WINGET_COMMON%

:: Enable long paths in Windows
echo [INFO] Enabling long paths in Windows...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f

:: Configure Git for long paths
echo [INFO] Configuring Git for long paths...
git config --system core.longpaths true

echo.

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

:: Visual Studio Code
echo [INFO] Installing Visual Studio Code...
winget install --id Microsoft.VisualStudioCode -e %WINGET_COMMON%

:: Epic Games Launcher
echo [INFO] Installing Epic Games Launcher...
winget install -e --id EpicGames.EpicGamesLauncher %WINGET_COMMON%

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