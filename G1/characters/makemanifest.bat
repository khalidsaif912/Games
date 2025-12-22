@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "OUT=manifest.json"
set "CHAR_DIR=characters"
set "Q=""

set "KEYS=%TEMP%\m1_char_keys_%RANDOM%.txt"
if exist "%KEYS%" del /q "%KEYS%" >nul 2>&1

> "%OUT%" echo(
>>"%OUT%" echo {

REM ===== PAIRS (M1 root) =====
>>"%OUT%" echo   "pairs": [
set "firstPair=1"

for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  set "img1="
  set "img2="

  for %%E in (png jpg jpeg webp) do (
    if not defined img1 if exist "%%L1.%%E" set "img1=%%L1.%%E"
    if not defined img2 if exist "%%L2.%%E" set "img2=%%L2.%%E"
  )

  if defined img1 if defined img2 (
    if "!firstPair!"=="1" (
      set "firstPair=0"
      >>"%OUT%" echo     {"id":"%%L","img1":"!img1!","img2":"!img2!"}
    ) else (
      >>"%OUT%" echo     ,{"id":"%%L","img1":"!img1!","img2":"!img2!"}
    )
  )
)

>>"%OUT%" echo   ],
>>"%OUT%" echo   "characters": {

REM ===== DISCOVER KEYS ONLY FROM characters\ =====
if not exist "%CHAR_DIR%\" (
  >>"%OUT%" echo   }
  >>"%OUT%" echo }
  echo(
  echo ⚠️ Folder not found: %CD%\%CHAR_DIR%
  echo ✅ manifest.json generated but characters is empty.
  pause
  exit /b 0
)

for %%E in (png jpg jpeg webp) do (
  for %%F in ("%CHAR_DIR%\*-*.%%E") do (
    if exist "%%~fF" (
      for /f "delims=-" %%K in ("%%~nF") do (
        findstr /I /X /C:"%%K" "%KEYS%" >nul 2>&1 || echo %%K>>"%KEYS%"
      )
    )
  )
)

REM ===== WRITE CHARACTERS (ONLY characters/...) =====
set "firstChar=1"

if exist "%KEYS%" (
  for /f "usebackq delims=" %%N in ("%KEYS%") do (
    if "!firstChar!"=="1" (
      set "firstChar=0"
    ) else (
      >>"%OUT%" echo ,
    )

    >>"%OUT%" <nul set /p ="    !Q!%%N!Q!: ["
    set "firstItem=1"

    for %%E in (png jpg jpeg webp) do (
      for %%F in ("%CHAR_DIR%\%%N-*.%%E") do (
        if exist "%%~fF" (
          if "!firstItem!"=="1" (
            set "firstItem=0"
            >>"%OUT%" <nul set /p ="!Q!%CHAR_DIR%/%%~nxF!Q!"
          ) else (
            >>"%OUT%" <nul set /p =", !Q!%CHAR_DIR%/%%~nxF!Q!"
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

if exist "%KEYS%" del /q "%KEYS%" >nul 2>&1

echo(
echo ✅ manifest.json generated (characters ONLY from %CHAR_DIR%\)
pause
