@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "OUT=manifest.json"
set "CHAR_DIR=characters"
set "LIST=%TEMP%\G1_num_list_%RANDOM%.txt"
set "KEYS=%TEMP%\G1_char_keys_%RANDOM%.txt"

if exist "%LIST%" del /q "%LIST%" >nul 2>&1
if exist "%KEYS%" del /q "%KEYS%" >nul 2>&1

REM =========================
REM 1) IMAGES (numeric only)
REM =========================
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

sort /L C "%LIST%" /O "%LIST%"

> "%OUT%" echo {
>>"%OUT%" echo   "images": [

set "first=1"
for /f "usebackq delims=" %%S in ("%LIST%") do (
  for %%A in ("%%S") do set "NAME=%%~nA"
  if "!first!"=="1" (
    set "first=0"
    >>"%OUT%" echo     { "img": "%%S", "label": "!NAME!" }
  ) else (
    >>"%OUT%" echo     ,{ "img": "%%S", "label": "!NAME!" }
  )
)

>>"%OUT%" echo   ],
>>"%OUT%" echo   "characters": {

REM =========================
REM 2) CHARACTERS (from characters\)
REM =========================
if not exist "%CHAR_DIR%\" (
  >>"%OUT%" echo   }
  >>"%OUT%" echo }
  del /q "%LIST%" >nul 2>&1
  echo ⚠️ لم يتم العثور على مجلد characters داخل %CD%
  echo ✅ تم إنشاء manifest.json لكن بدون شخصيات.
  pause
  exit /b 0
)

REM Discover character keys from files like name-state.png
for %%E in (png jpg jpeg webp) do (
  for %%F in ("%CHAR_DIR%\*-*.%%E") do (
    if exist "%%~fF" (
      for /f "delims=-" %%K in ("%%~nF") do (
        findstr /I /X /C:"%%K" "%KEYS%" >nul 2>&1 || echo %%K>>"%KEYS%"
      )
    )
  )
)

set "firstChar=1"
if exist "%KEYS%" (
  for /f "usebackq delims=" %%N in ("%KEYS%") do (
    if "!firstChar!"=="1" (set "firstChar=0") else (>>"%OUT%" echo ,)

    >>"%OUT%" <nul set /p ="    "%%N": ["
    set "firstItem=1"

    for %%E in (png jpg jpeg webp) do (
      for %%F in ("%CHAR_DIR%\%%N-*.%%E") do (
        if exist "%%~fF" (
          if "!firstItem!"=="1" (
            set "firstItem=0"
            >>"%OUT%" <nul set /p =""%CHAR_DIR%/%%~nxF""
          ) else (
            >>"%OUT%" <nul set /p =", "%CHAR_DIR%/%%~nxF""
          )
        )
      )
    )

    >>"%OUT%" echo ]
  )
)

>>"%OUT%" echo(
>>"%OUT%" echo   }
>>"%OUT%" echo }

del /q "%LIST%" >nul 2>&1
del /q "%KEYS%" >nul 2>&1

echo ✅ تم إنشاء manifest.json (images + characters) داخل G1 بنجاح
pause
