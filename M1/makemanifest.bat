@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ===== Always run from this BAT folder (M1) =====
cd /d "%~dp0"

set "OUT=manifest.json"
set "CHAR_DIR=characters"
set "Q=""

set "KEYS=%TEMP%\m1_char_keys_%RANDOM%.txt"
if exist "%KEYS%" del /q "%KEYS%" >nul 2>&1

REM ================== START JSON ==================
> "%OUT%" echo(
>>"%OUT%" echo {

REM ================== PAIRS (from M1 root) ==================
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

REM ================== DISCOVER CHARACTER KEYS ==================
REM From M1\characters\ (recommended)
if exist "%CHAR_DIR%\" (
  for %%E in (png jpg jpeg webp) do (
    for %%F in ("%CHAR_DIR%\*-*.%%E") do (
      if exist "%%~fF" (
        for /f "delims=-" %%K in ("%%~nF") do (
          findstr /I /X /C:"%%K" "%KEYS%" >nul 2>&1 || echo %%K>>"%KEYS%"
        )
      )
    )
  )
)

REM Also discover from M1 root (optional)
for %%E in (png jpg jpeg webp) do (
  for %%F in ("*-*.%%E") do (
    if exist "%%~fF" (
      for /f "delims=-" %%K in ("%%~nF") do (
        findstr /I /X /C:"%%K" "%KEYS%" >nul 2>&1 || echo %%K>>"%KEYS%"
      )
    )
  )
)

REM ================== WRITE CHARACTERS OBJECT ==================
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

    REM 1) files in characters\ (write as characters/filename.ext)
    if exist "%CHAR_DIR%\" (
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
    )

    REM 2) files in M1 root (write as filename.ext)
    for %%E in (png jpg jpeg webp) do (
      for %%F in ("%%N-*.%%E") do (
        if exist "%%~fF" (
          if "!firstItem!"=="1" (
            set "firstItem=0"
            >>"%OUT%" <nul set /p ="!Q!%%~nxF!Q!"
          ) else (
            >>"%OUT%" <nul set /p =", !Q!%%~nxF!Q!"
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

REM Cleanup
if exist "%KEYS%" del /q "%KEYS%" >nul 2>&1

echo(
echo ✅ manifest.json generated: %CD%\%OUT%
pause
