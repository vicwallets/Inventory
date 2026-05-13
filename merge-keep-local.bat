@echo off
REM Merges remote main into local, keeping local version for any conflicts.
REM Use this after Abort merge in GitHub Desktop, to set up a clean push.

setlocal
cd /d "%~dp0"

REM Locate git (GitHub Desktop's embedded copy)
set "GIT="
for /f "delims=" %%i in ('dir /b /a-d /od "%LOCALAPPDATA%\GitHubDesktop\app-*" 2^>nul') do set "GHD=%%i"
if defined GHD set "GIT=%LOCALAPPDATA%\GitHubDesktop\%GHD%\resources\app\git\cmd\git.exe"
if not exist "%GIT%" set "GIT=C:\Program Files\Git\cmd\git.exe"
if not exist "%GIT%" (
  echo Could not find git.exe. Aborting.
  pause
  exit /b 1
)

echo Using git: %GIT%
echo.

"%GIT%" merge --abort >nul 2>&1

if exist ".git\index.lock" del /f /q ".git\index.lock"

echo Fetching remote...
"%GIT%" fetch origin

echo Merging origin/main, keeping local version for conflicts...
"%GIT%" merge origin/main -X ours --no-edit

if %ERRORLEVEL%==0 (
  echo.
  echo SUCCESS: Local now contains merge of remote with local files preserved.
  echo Next step: open GitHub Desktop and click Push origin.
) else (
  echo.
  echo Merge failed. Check git output above.
)

pause
