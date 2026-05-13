@echo off
REM Removes stale git lock files so commit/push can proceed.
cd /d "%~dp0"
if exist ".git\index.lock" (
  del /f /q ".git\index.lock"
  echo Removed .git\index.lock
) else (
  echo No lock file found at .git\index.lock
)
if exist ".git\HEAD.lock"  del /f /q ".git\HEAD.lock"
if exist ".git\config.lock" del /f /q ".git\config.lock"
echo Done.
pause
