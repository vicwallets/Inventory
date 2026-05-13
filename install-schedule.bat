@echo off
REM Registers a Windows Scheduled Task to run deploy.ps1 every day at 10:00 AM.
REM Existing task with same name is replaced (/F).

schtasks /Create ^
  /TN "STW Inventory Deploy" ^
  /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%~dp0deploy.ps1\"" ^
  /SC DAILY ^
  /ST 10:00 ^
  /F

if %ERRORLEVEL%==0 (
  echo.
  echo Scheduled task "STW Inventory Deploy" created. It will run daily at 10:00 AM.
) else (
  echo.
  echo Failed to create scheduled task. Try running this file as Administrator.
)
pause
