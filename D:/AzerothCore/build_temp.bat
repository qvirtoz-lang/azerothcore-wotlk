@echo off
setlocal enabledelayedexpansion

:: ============================================
:: AzerothCore Windows Build Script (VS2019)
:: ============================================

cd /d "D:\AzerothCore"

echo.
echo ========================================
echo   AzerothCore Windows Builder v1.0
echo   WotLK Classic Server Emulator
echo ========================================
echo.

:: --- Step 1: Check CMake ---
set "CMAKE_PATH=%ProgramFiles%\CMake\bin\cmake.exe"
if not exist "%CMAKE_PATH%" (
    set "CMAKE_PATH=%ProgramFiles(x86)%\CMake\bin\cmake.exe"
)

echo [INFO] Checking for CMake...
if not exist "%CMAKE_PATH%" (
    echo [ERROR] CMake is NOT installed!
    echo Please install from: https://cmake.org/download/
    exit /b 1
)
echo [OK] Found CMake at %CMAKE_PATH%

:: --- Step 2: Create build directory ---
mkdir build_temp ^>nul 2>&1
cd build_temp

echo.
echo ========================================
echo   Step 1: CMake Configuration
echo ========================================
echo.

set /p BUILD_TYPE="Build type [Release|Debug] (default: Release): "
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Release

echo Running cmake with Visual Studio 2019 generator...
"cmake.exe" -G "Visual Studio 16 2019" ^
    -A x64 ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -DBUILD_TESTING=OFF ^
    "..\" > cmake.log 2>&1

set /p CMKE_RESULT=<cmake.log | findstr /C:"-- Build succeeded in" | findstr /C:"succeeded"
if not defined CMKE_RESULT (
    echo [ERROR] CMake failed! Check cmake.log for details.
    exit /b 1
)
echo [OK] CMake configuration completed

:: --- Step 3: Find MSBuild ---
for %%i in ("C:\Program Files\Microsoft Visual Studio\2019\Common7\Tools\MSBuild.exe") do if exist "%%i" set "MSBUILD=%%~fi"
if not defined MSBUILD (
    for %%i in ("C:\Program Files (x86)\Microsoft Visual Studio\2019\Common7\Tools\MSBuild.exe") do if exist "%%i" set "MSBUILD=%%~fi"
)

if not defined MSBUILD (
    echo [ERROR] MSBuild.exe not found!
    echo Install Visual Studio 2019 with "Desktop development with C++".
    exit /b 1
)
echo [OK] Found MSBuild at %MSBUILD%

:: --- Step 4: Build ---
echo.
echo ========================================
echo   Step 2: Building
echo ========================================
echo.

set /p CONFIG="Configuration [Release|Debug] (default: Release): "
if "%CONFIG%"=="" set CONFIG=Release

"%MSBUILD%" AzerothCore.sln ^
    /p:Configuration=%CONFIG% ^
    /p:Platform=x64 ^
    /m:8 ^
    /verbosity:minimal > msbuild.log 2>&1

set /p BUILD_RESULT=<msbuild.log | findstr /C:"Build succeeded" | findstr /C:"succeeded"
if not defined BUILD_RESULT (
    echo.
    echo [ERROR] Build FAILED! Check msbuild.log for details.
    echo.
    echo Output: D:\AzerothCore\bin\x64\%CONFIG%\
) else (
    echo [OK] Build succeeded in %CONFIG%!
)

:: --- Step 5: Summary ---
echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo Configuration: %BUILD_TYPE%
echo Output: D:\AzerothCore\bin\x64\%CONFIG%\acore_server.exe
echo.
echo Next steps:
echo 1. cd apps\server\bin\x64\%CONFIG%
echo 2. acore_server.exe --config-file conf\acore.json
echo.

endlocal