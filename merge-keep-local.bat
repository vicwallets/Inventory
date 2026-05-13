@echo off
REM Merges remote main into local, keeping local versions for any conflicts.
REM Then leaves the result ready for Push origin in GitHub Desktop.

setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo Working dir: %CD%
echo.

REM Find git in GitHub Desktop install
set "GIT="
if exist "%LOCALAPPDATA%\GitHubDesktop" (
  for /f "delims=" %%i in ('dir /b /ad /od "%LOCALAPPDATA%\GitHubDesktop\app-*" 2^>nul') do set "GHD=%%i"
  if defined GHD (
    set "CANDIDATE=%LOCALAPPDATA%\GitHubDesktop\!GHD!\resources\app\git\cmd\git.exe"
    if exist "!CANDIDATE!" set "GIT=!CANDIDATE!"
  )
)
if not defined GIT (
  if exist "C:\Program Files\Git\cmd\git.exe" set "GIT=C:\Program Files\Git\cmd\git.exe"
)
if not defined GIT (
  echo ERROR: could not find git.exe
  echo Looked in: %LOCALAPPDATA%\GitHubDesktop\app-*\resources\app\git\cmd\git.exe
  echo            C:\Program Files\Git\cmd\git.exe
  pause
  exit /b 1
)

echo Git: %GIT%
echo.

echo --- removing any stale locks ---
if exist ".git\index.lock"  del /f /q ".git\index.lock"
if exist ".git\MERGE_HEAD"  del /f /q ".git\MERGE_HEAD"
if exist ".git\MERGE_MODE"  del /f /q ".git\MERGE_MODE"
if exist ".git\MERGE_MSG"   del /f /q ".git\MERGE_MSG"
echo done.
echo.

echo --- git fetch origin ---
"%GIT%" fetch origin
echo.

echo --- git status ---
"%GIT%" status
echo.

echo --- git merge origin/main -X ours ---
"%GIT%" merge origin/main -X ours --no-edit
set "RESULT=%ERRORLEVEL%"
echo.

if "%RESULT%"=="0" (
  echo SUCCESS. Open GitHub Desktop and click Push origin.
) else (
  echo Merge returned exit code %RESULT%. Check messages above.
)

echo.
pause
