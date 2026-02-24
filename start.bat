@echo off
REM SMS Campaign Manager - Windows Batch Launcher
REM Starts backend on port 8500 and frontend on port 3500
REM Automatically kills any existing processes using these ports

setlocal enabledelayedexpansion

set BACKEND_PORT=8500
set FRONTEND_PORT=3500
set PROJECT_DIR=%~dp0

REM Colors (Windows 10+)
cls

echo.
echo === SMS Campaign Manager - Windows Launcher ===
echo.

REM Function to kill process on port (Windows)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%BACKEND_PORT%') do (
    echo Killing process on port %BACKEND_PORT% (PID: %%a)
    taskkill /PID %%a /F >nul 2>&1
)

for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%FRONTEND_PORT%') do (
    echo Killing process on port %FRONTEND_PORT% (PID: %%a)
    taskkill /PID %%a /F >nul 2>&1
)

echo Ports cleared
echo.

REM Check if .env files exist
if not exist "%PROJECT_DIR%backend\.env" (
    echo Error: backend\.env not found
    echo Please run: cd backend ^& copy .env.example .env
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%frontend\.env.local" (
    echo Error: frontend\.env.local not found
    echo Please run: cd frontend ^& copy .env.example .env.local
    pause
    exit /b 1
)

echo Starting applications...
echo.
echo Backend: http://localhost:%BACKEND_PORT%
echo Frontend: http://localhost:3500
echo API Docs: http://localhost:%BACKEND_PORT%/docs
echo.

REM Start backend in new window
start "SMS Backend" cmd /k "cd /d %PROJECT_DIR%backend && python main.py"

REM Wait a bit before starting frontend
timeout /t 2 /nobreak

REM Start frontend in new window
start "SMS Frontend" cmd /k "cd /d %PROJECT_DIR%frontend && npm run dev"

echo.
echo Applications started in separate windows.
echo Close the windows or press Ctrl+C to stop the services.
echo.
pause
