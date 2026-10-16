@echo off
setlocal enabledelayedexpansion

:: ============================================
:: AzerothCore Windows Build Script
:: Fixed for Visual Studio 2019
:: ============================================

echo.
echo ========================================
echo   AzerothCore Windows Builder v1.0
echo   WotLK Classic Server Emulator
echo ========================================
echo.

:: --- Check CMake directly (no vswhere needed) ---
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
echo   Step 1: Configure (CMake with VS2019)
echo ========================================
echo.

set /p CONFIG="Build configuration [Debug|Release|RelWithDebInfo] (default: Release): "
if errorlevel 1 set CONFIG=Release

echo Building with %CONFIG%...
echo.

"%CMAKE_BIN%\cmake.exe" ^
    -G "Visual Studio 16 2019" ^
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
echo   Step 2: Build with MSBuild
echo ========================================
echo.

:: Find MSBuild.exe from VS2019
for /f "tokens=*" %%i in ('"where msbuild.exe ^| findstr /C:"MSBuild.exe"') do set "MSBUILD=%%~dpni"

if not exist "%MSBUILD%" (
    echo [ERROR] MSBuild.exe not found! Visual Studio 2019 must be installed with C++ workload.
    exit /b 1
)

echo Using: %MSBUILD%
echo.

set "CONFIGS=Debug Release RelWithDebInfo"

for %%C in (%CONFIGS%) do (
    echo --- Building %%C ---
    
    "%MSBUILD%" AzerothCore.sln ^
        /p:Configuration=%%C ^
        /p:Platform=x64 ^
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