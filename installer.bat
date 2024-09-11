@echo off
title MILILX OS Installer
color 1F

:MENU
cls
echo =========================
echo MILILX OS Installer
echo =========================
echo.
echo 1. Install MILILX OS
echo 2. View Installation Instructions
echo 3. Exit
echo.
set /p choice=Select an option (1-3):

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto INSTRUCTIONS
if "%choice%"=="3" goto EXIT

:INSTALL
cls
echo Installing MILILX OS...
echo.

:: Create necessary directories
mkdir C:\MILILX

:: Copy files to the target directory
copy C:\source\kernel.com C:\MILILX\kernel.com
copy C:\source\busybox.com C:\MILILX\busybox.com
copy C:\source\editor.com C:\MILILX\editor.com
copy C:\source\shell.com C:\MILILX\shell.com
copy C:\source\bootscreen.com C:\MILILX\bootscreen.com
copy C:\source\milix.com C:\MILILX\milix.com

:: Create a configuration file
echo [config] > C:\MILILX\milix.cfg
echo kernel=kernel.com >> C:\MILILX\milix.cfg
echo busybox=busybox.com >> C:\MILILX\milix.cfg
echo editor=editor.com >> C:\MILILX\milix.cfg
echo shell=shell.com >> C:\MILILX\milix.cfg

echo Installation completed successfully.
pause
goto MENU

:INSTRUCTIONS
cls
echo =========================
echo Installation Instructions
echo =========================
echo.
echo To install MILILX OS:
echo 1. Run this installer batch script.
echo 2. Follow the on-screen instructions.
echo 3. Reboot your system to start MILILX OS.
echo.
pause
goto MENU

:EXIT
cls
echo Exiting installer...
pause
exit
