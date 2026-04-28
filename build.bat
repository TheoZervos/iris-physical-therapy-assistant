@echo off
:: --- Starting Iris Build Process ---
echo --- Starting Iris Build Process ---

cd iris

:: Run Flutter commands and check for success
call flutter clean
if %ERRORLEVEL% neq 0 (
    echo Flutter clean failed. Exiting...
    exit /b %ERRORLEVEL%
)

call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo Flutter pub get failed. Exiting...
    exit /b %ERRORLEVEL%
)

call flutter run