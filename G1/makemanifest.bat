@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "OUT=manifest.json"
set "LIST=%TEMP%\G1_num_list_%RANDOM%.txt"

if exist "%OUT%" del /q "%OUT%" >nul 2>&1
if exist "%LIST%" del /q "%LIST%" >nul 2>&1

REM ===== Collect numeric-only filenames in root: 1.jpg, 2.png, 10.webp ... =====
for %%E in (png jpg jpeg webp) do (
  for %%F in (*."%%E") do (
    echo %%~nF| findstr /R "^[0-9][0-9]*$" >nul
    if not errorlevel 1 echo %%~nF.%%E>>"%LIST%"
  )
)

if not exist "%LIST%" (
  echo ⚠️ لم يتم العثور على صور رقمية مثل 1.jpg داخل %CD%
  pause
  exit /b 0
)

REM Sort so 1,2,3..10,11.. (ترتيب نصي، لكنه مناسب غالباً)
sort /L C "%LIST%" /O "%LIST%"

> "%OUT%" echo {
>>"%OUT%" echo   "images": [

set "first=1"
for /f "usebackq delims=" %%S in ("%LIST%") do (
  REM label = filename without extension
  for %%A in ("%%S") do set "NAME=%%~nA"

  if "!first!"=="1" (
    set "first=0"
    >>"%OUT%" echo     { "img": "%%S", "label": "!NAME!" }
  ) else (
    >>"%OUT%" echo     ,{ "img": "%%S", "label": "!NAME!" }
  )
)

>>"%OUT%" echo   ]
>>"%OUT%" echo }

del /q "%LIST%" >nul 2>&1

echo ✅ تم إنشاء manifest.json للمتشابهات (images) بنجاح داخل G1
pause
