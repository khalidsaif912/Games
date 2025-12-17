@echo off
title Push Games to GitHub
cd /d "%~dp0"

echo ===============================
echo   Uploading to GitHub (Games)
echo ===============================

git status

git add .
git commit -m "Update games %date% %time%"
git push origin main

echo.
echo Done ✅ Files pushed to GitHub
pause
