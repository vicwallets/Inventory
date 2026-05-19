@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0rebuild-and-deploy.ps1"
echo.
echo Pipeline finished. Check deploy.log for details.
pause
