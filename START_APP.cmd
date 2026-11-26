@echo off
setlocal

for %%I in ("%~dp0.") do set "PROJECT=%%~fI"

where node.exe >nul 2>nul
if not errorlevel 1 (
  set "NODE=node.exe"
) else if exist "C:\Users\Lenovo\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe" (
  set "NODE=C:\Users\Lenovo\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
) else (
  echo Node.js was not found. Install Node.js LTS, reopen this folder, and run START_APP.cmd again.
  pause
  exit /b 1
)

cd /d "%PROJECT%"
"%NODE%" node_modules\concurrently\dist\bin\concurrently.js --names backend,frontend --kill-others-on-fail "%NODE% --disable-warning=ExperimentalWarning server/src/server.js" "%NODE% client/node_modules/vite/bin/vite.js client --host 127.0.0.1 --port 5173 --strictPort"
exit /b %ERRORLEVEL%


