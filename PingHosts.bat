:: Purpose: Check host reachability from an input list.
@echo off
setlocal
if "%~1"=="" (
  echo Usage: PingHosts.bat hosts.txt
  exit /b 1
)

for /f "usebackq tokens=*" %%H in ("%~1") do (
  echo Checking %%H...
  :: One quick ping per host with short timeout for faster list scans.
  ping -n 1 -w 800 %%H | find "TTL=" >nul
  if errorlevel 1 (
    echo %%H,DOWN
  ) else (
    echo %%H,UP
  )
)