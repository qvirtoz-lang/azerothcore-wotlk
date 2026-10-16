@echo off
setlocal enabledelayedexpansion

:: ============================================
:: AzerothCore Windows Build Script
:: ============================================

echo.
echo ========================================
echo   AzerothCore Windows Builder v1.0
echo   WotLK Classic Server Emulator
echo ========================================
echo.

:: --- Check Visual Studio ---
set "VSINSTALLDIR="
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer" (
    set "VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\Installer" (
    set "VSINSTALLDIR=%ProgramFiles%\Microsoft Visual Studio\"
)

if not defined VSINSTALLDIR (
    echo [ERROR] Visual Studio is NOT installed!
    echo Please install Visual Studio 2019/2022 with "Desktop development with C++" workload.
    echo.
    exit /b 1
)

echo [INFO] Found Visual Studio at: %VSINSTALLDIR%
echo.

:: --- Check CMake ---
set "CMAKE_BIN=%ProgramFiles%\CMake\bin"
if not exist "%CMAKE_BIN%\cmake.exe" (
    set "CMAKE_BIN=%ProgramFiles(x86)%\CMake\bin"
)
if not exist "%CMAKE_BIN%\cmake.exe" (
    echo [ERROR] CMake is NOT found!
    echo Please install CMake from https://cmake.org/download/
    exit /b 1
)

echo [INFO] Found CMake at: %CMAKE_BIN%
echo.

:: --- Create build directory ---
if not exist "build" mkdir build
cd build

echo ========================================
echo   Step 1: Configure (CMake)
echo ========================================
echo.

set /p CONFIG="Build configuration [Debug|Release|RelWithDebInfo] (default: Release): "
if errorlevel 1 set CONFIG=Release

echo Building with %CONFIG%...
echo.

"%CMAKE_BIN%\cmake.exe" ^
    -G "Visual Studio 17 2022" ^
    -A x64 ^
    -DCMAKE_BUILD_TYPE=%CONFIG% ^
    -DBUILD_TESTING=OFF ^
    -DENABLE_UNIT_TESTS=OFF ^
    ..\..

if errorlevel 1 (
    echo [ERROR] CMake configuration failed!
    exit /b 1
)

echo.
echo ========================================
echo   Step 2: Build
echo ========================================
echo.

set "CONFIGS=Debug Release RelWithDebInfo MinSizeRel"

for %%C in (%CONFIGS%) do (
    echo --- Building %%C ---
    
    "msbuild.exe" AzerothCore.sln ^
        /p:Configuration=%%C ^
        /p:Platform=x64 ^
        /m:8 ^
        /p:UpgradeProjectContentsOnSave=false ^
        /verbosity:minimal
    
    if errorlevel 1 (
        echo [ERROR] Build failed for configuration %%C!
        exit /b 1
    )
    
    echo [INFO] %CONFIG% build completed successfully.
)

echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo Output directory: ..\..\bin\x64\Release\
echo.
echo Next steps:
echo 1. Run: cd apps\server\bin\x64\Release && acore_server.exe --config-file conf/acore.json
echo 2. Configure acore.json and start MySQL database
echo.

endlocal