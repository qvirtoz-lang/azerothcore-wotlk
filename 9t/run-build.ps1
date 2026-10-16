# AzerothCore Build Script for Windows (VS2019)
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  AzerothCore Windows Builder v1.0" -ForegroundColor Yellow
Write-Host "  WotLK Classic Server Emulator" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# --- Step 1: Check CMake ---
$cmakePath = "C:\Program Files\CMake\bin\cmake.exe"
if (-not (Test-Path $cmakePath)) {
    $cmakePath = "C:\Program Files(x86)\CMake\bin\cmake.exe"
}

Write-Host "[INFO] Checking CMake..." -ForegroundColor Gray
if (-not (Test-Path $cmakePath)) {
    Write-Host "[ERROR] CMake is NOT found!" -ForegroundColor Red
    Write-Host "Please install CMake from https://cmake.org/download/" -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Found CMake at: $cmakePath`n" -ForegroundColor Green

# --- Step 2: Create build directory ---
$buildDir = Join-Path $PSScriptRoot "..\..\build_test"
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
}
Set-Location $buildDir

Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "Step 1: CMake Configuration" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Gray

# --- Step 3: Run CMake configuration ---
$cmakeArgs = @(
    $cmakePath,
    "-G", "Visual Studio 16 2019",
    "-A", "x64",
    "-DCMAKE_BUILD_TYPE=Release",
    "-DBUILD_TESTING=OFF",
    "..\"
)

Write-Host "Running cmake..." -ForegroundColor Gray
& $cmakeArgs | Out-File -FilePath "cmake_output.log" -Encoding utf8

$exitCode = $?
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] CMake configuration failed!" -ForegroundColor Red
    Write-Host "Check cmake_output.log for details." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] CMake configuration completed successfully`n" -ForegroundColor Green

# --- Step 4: Build with MSBuild ---
Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "Step 2: Building with MSBuild" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Gray

# Find MSBuild.exe from VS2019
$msbuildPath = "C:\Program Files\Microsoft Visual Studio\2019\Common7\Tools\MSBuild.exe"
if (-not (Test-Path $msbuildPath)) {
    # Try alternative paths
    foreach ($path in @(
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Common7\Tools\MSBuild.exe",
        "$env:ProgramFiles(x86)\Microsoft Visual Studio\2019\Common7\Tools\MSBuild.exe"
    )) {
        if (Test-Path $path) {
            $msbuildPath = $path
            break
        }
    }
}

if (-not (Test-Path $msbuildPath)) {
    Write-Host "`n[ERROR] MSBuild.exe not found!" -ForegroundColor Red
    Write-Host "Visual Studio 2019 must be installed with 'Desktop development with C++' workload." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Using: $msbuildPath`n" -ForegroundColor Green

$configs = @("Debug", "Release", "RelWithDebInfo")

foreach ($config in $configs) {
    Write-Host "--- Building $config ---" -ForegroundColor Gray
    
    $args = @(
        $msbuildPath,
        "..\..\AzerothCore.sln",
        "/p:Configuration=$config",
        "/p:Platform=x64",
        "/m:8",
        "/verbosity:minimal"
    )
    
    & $args | Out-File -FilePath "msbuild_$config.log" -Encoding utf8
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[ERROR] Build failed for configuration $config!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[INFO] $config build completed successfully.`n" -ForegroundColor Green
}

Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Gray
Write-Host "Output directory: D:\AzerothCore\bin\x64\Release\" -ForegroundColor Yellow
Write-Host "`nNext steps:" -ForegroundColor Gray
Write-Host "1. cd apps\server\bin\x64\Release" -ForegroundColor White
Write-Host "2. acore_server.exe --config-file conf\acore.json`n" -ForegroundColor Cyan

exit 0