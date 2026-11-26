@echo off
setlocal
cd /d "%~dp0"
title Reset MySQL 8.4 Root Password

echo.
echo MySQL 8.4 Root Password Reset
echo =============================
echo.
echo Windows will request Administrator approval.
echo Enter the new password only in the protected prompt.
echo Do not type the password into chat or save it in this file.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0server\scripts\reset-mysql-root.ps1"
set "RESET_EXIT_CODE=%ERRORLEVEL%"

if not "%RESET_EXIT_CODE%"=="0" (
  echo.
  echo Password reset did not complete. Review the error above.
  echo.
  pause
)

exit /b %RESET_EXIT_CODE%
