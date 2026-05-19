@echo off
REM Registers a Windows Scheduled Task that runs the rebuild+deploy
REM pipeline every day at 10:00 AM. Replaces any existing task with the same name.

schtasks /Create ^
  /TN "STW Inventory Daily Deploy" ^
  /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%~dp0rebuild-and-deploy.ps1\"" ^
  /SC DAILY ^
  /ST 10:00 ^
  /F

if %ERRORLEVEL%==0 (
  echo.
  echo Scheduled task "STW Inventory Daily Deploy" created.
  echo It will run rebuild-and-deploy.ps1 every day at 10:00 AM.
  echo.
  echo To remove later, run:  schtasks /Delete /TN "STW Inventory Daily Deploy" /F
) else (
  echo.
  echo Failed to create scheduled task. Try right-clicking this file and "Run as administrator".
)
pause
