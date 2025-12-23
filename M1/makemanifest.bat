@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "OUT=manifest.json"
set "CHAR_DIR=characters"
set "LIST=%TEMP%\G1_img_list_%RANDOM%.txt"
set "KEYS=%TEMP%\G1_char_keys_%RANDOM%.txt"

if exist "%LIST%" del /q "%LIST%" >nul 2>&1
if exist "%KEYS%" del /q "%KEYS%" >nul 2>&1

REM =========================
REM 1) Collect ALL images in root (any name)
REM =========================
for %%E in (png jpg jpeg webp) do (
  for /f "delims=" %%F in ('dir /b /a-d "*.%%E" 2^>nul') do (
    REM Skip card-back (optional)
    if /I not "%%F"=="card-back.%%E" (
      echo %%F>>"%LIST%"
    )
  )
)

if not exist "%LIST%" (
  echo ⚠️ لم يتم العثور على صور في %CD%
  echo    تأكد أن الصور موجودة داخل G1 وليس داخل مجلد آخر.
  pause
  exit /b 0
)

sort /L C "%LIST%" /O "%LIST%"

REM =========================
REM 2) Write images section
REM =========================
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
REM 3) Characters from characters\ (name-win.png OR name_win.png)
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

REM Discover unique keys
for %%E in (png jpg jpeg webp) do (
  for /f "delims=" %%F in ('dir /b /a-d "%CHAR_DIR%\*.%%E" 2^>nul') do (
    set "FN=%%~nF"
    set "KEY=!FN!"

    REM split by "-" if exists
    for /f "tokens=1 delims=-" %%K in ("!KEY!") do set "KEY=%%K"
    REM then split by "_" if exists
    for /f "tokens=1 delims=_" %%K in ("!KEY!") do set "KEY=%%K"

    findstr /I /X /C:"!KEY!" "%KEYS%" >nul 2>&1 || echo !KEY!>>"%KEYS%"
  )
)

set "firstChar=1"
if exist "%KEYS%" (
  for /f "usebackq delims=" %%N in ("%KEYS%") do (
    if "!firstChar!"=="1" (set "firstChar=0") else (>>"%OUT%" echo ,)

    >>"%OUT%" <nul set /p ="    "%%N": ["
    set "firstItem=1"

    for %%E in (png jpg jpeg webp) do (
      for /f "delims=" %%F in ('dir /b /a-d "%CHAR_DIR%\%%N-*.%%E" 2^>nul') do (
        if "!firstItem!"=="1" (
          set "firstItem=0"
          >>"%OUT%" <nul set /p =""%CHAR_DIR%/%%F""
        ) else (
          >>"%OUT%" <nul set /p =", "%CHAR_DIR%/%%F""
        )
      )
      for /f "delims=" %%F in ('dir /b /a-d "%CHAR_DIR%\%%N_*.%%E" 2^>nul') do (
        if "!firstItem!"=="1" (
          set "firstItem=0"
          >>"%OUT%" <nul set /p =""%CHAR_DIR%/%%F""
        ) else (
          >>"%OUT%" <nul set /p =", "%CHAR_DIR%/%%F""
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

echo(
echo ✅ تم إنشاء manifest.json (images + characters) داخل G1 بنجاح
pause
