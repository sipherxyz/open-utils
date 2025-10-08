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

:: ========================================
:: Additional Tools Confirmation
:: ========================================
echo [SECTION] Additional Development Tools (For building Sipher)
echo.
echo Install additional development tools? (Default: No)
echo - AWS CLI
echo - Android Studio  
echo - Node.js
echo - Ruby with DevKit
echo.
set /p "INSTALL_ADDITIONAL=Install additional tools? (y/N): "

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

:: Disable passwordless authentication
echo [INFO] Disabling passwordless authentication...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" /v DevicePasswordLessBuildVersion /t REG_DWORD /d 0 /f

:: Configure Git for long paths
echo [INFO] Configuring Git for long paths...
git config --system core.longpaths true

:: Git LFS
echo [INFO] Installing Git LFS...
winget install --id GitHub.GitLFS -e %WINGET_COMMON%

:: CMake
echo [INFO] Installing CMake...
winget install --id Kitware.CMake -e --version 3.31.6 %WINGET_COMMON%

echo.

:: Java
echo [INFO] Installing Java...
winget install -e --id Oracle.JDK.18 %WINGET_COMMON%
winget install --id=Oracle.JavaRuntimeEnvironment -e %WINGET_COMMON%

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

:: Fork Git Client
echo [INFO] Installing Fork Git Client...
winget install --id=Fork.Fork -e %WINGET_COMMON%

echo.

:: Apache Ant
echo [INFO] Checking if Apache Ant is already installed...
set "ANT_FOUND=0"
for /f "tokens=*" %%i in ('where ant 2^>nul') do set "ANT_FOUND=1"
if %ANT_FOUND%==0 (
    echo [INFO] Apache Ant not found, installing...
    curl -LO "https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.15-bin.zip"
    powershell -Command "Expand-Archive -Path 'apache-ant-1.10.15-bin.zip' -DestinationPath '.' -Force"
    move apache-ant-1.10.15 "C:\Program Files\apache-ant-1.10.15"
    del apache-ant-1.10.15-bin.zip
    echo [INFO] Apache Ant installed successfully

    echo [INFO] Downloading ant-contrib.jar library...
    curl -LO "https://github.com/sipherxyz/open-utils/raw/refs/heads/main/ant-contrib.jar"
    move ant-contrib.jar "C:\Program Files\apache-ant-1.10.15\lib\"
    echo [INFO] ant-contrib.jar library installed successfully
) else (
    echo [INFO] Apache Ant already installed, skipping installation
)

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

echo.

:: ========================================
:: Install Additional Development Tools
:: ========================================
if /i "%INSTALL_ADDITIONAL%"=="y" (
    echo [SECTION] Installing Additional Development Tools
    echo.

    :: AWS CLI
    echo [INFO] Installing AWS CLI...
    winget install -e --id Amazon.AWSCLI

    :: Android Studio
    echo [INFO] Installing Android Studio...
    winget install -e --id Google.AndroidStudio

    :: Node.js
    echo [INFO] Installing Node.js...
    winget install -e --id OpenJS.NodeJS

    :: Ruby with DevKit
    echo [INFO] Installing Ruby with DevKit...
    winget install RubyInstallerTeam.RubyWithDevKit.3.2

    echo.

    :: ========================================
    :: Install Package Managers and Tools
    :: ========================================
    echo [SECTION] Installing Package Managers and Tools
    echo.

    :: Python packages
    echo [INFO] Installing Python packages...
    pip install GitPython boto3 cryptography pysftp requests pycryptodome

    :: Node.js global packages
    echo [INFO] Installing Node.js global packages...
    npm install -g appcenter-cli

    :: Ruby gems
    echo [INFO] Installing Ruby gems...
    gem install fastlane

    echo.
) else (
    echo [INFO] Skipping additional development tools installation
)

echo.

:: ========================================
:: Set Environment Variables
:: ========================================
echo [SECTION] Setting Environment Variables
echo.

:: Set JAVA_HOME for Apache Ant
echo [INFO] Setting JAVA_HOME, ANDROID_HOME, NDKROOT environment variable...
setx JAVA_HOME "C:\Program Files\Java\jdk-18.0.2.1" /M
setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk" /M
setx NDKROOT "C:\Users\%USERNAME%\AppData\Local\Android\Sdk\ndk\26.0.10792818" /M

:: Add tools to PATH
echo [INFO] Adding development tools to PATH...
set "LIST_PATH=C:\Program Files\apache-ant-1.10.15\bin;C:\Program Files\Git\bin;C:\Program Files\CMake\bin;C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin;C:\Users\%USERNAME%\AppData\Local\Android\Sdk\build-tools\36.1.0"
powershell -Command "$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'Machine'); $pathsToAdd = '%LIST_PATH%'.Split(';'); $updatedPath = $currentPath; foreach ($path in $pathsToAdd) { if ($path -and $updatedPath -notlike ('*' + $path + '*')) { $updatedPath += ';' + $path; Write-Host ('Added ' + $path + ' to PATH') } else { Write-Host ($path + ' already in PATH or empty') } }; [Environment]::SetEnvironmentVariable('PATH', $updatedPath, 'Machine')"

echo [INFO] Environment variables set successfully!
echo [NOTE] You may need to restart your command prompt or IDE for changes to take effect.
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
echo 2. Verify environment variables (JAVA_HOME, ANDROID_HOME, NDKROOT, PATH, ...) are set correctly
echo 3. Open Visual Studio and start building

echo.
echo ========================================
echo Setup complete!
echo ========================================

pause