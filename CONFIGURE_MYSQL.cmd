@echo off
setlocal
cd /d "%~dp0"
title Configure Excel Price App for MySQL

echo.
echo Excel Price App - MySQL Configuration
echo ======================================
echo.
echo You will be prompted for the local MySQL root password.
echo The password will not be displayed or saved.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0server\scripts\configure-mysql.ps1"
set "CONFIGURE_EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%CONFIGURE_EXIT_CODE%"=="0" (
  echo Configuration did not complete. The app remains on SQLite if verification failed.
  echo Review the error above, then run this file again.
) else (
  echo Configuration and migration finished successfully.
  echo You can now start the app with START_APP.cmd.
)
echo.
pause
exit /b %CONFIGURE_EXIT_CODE%
