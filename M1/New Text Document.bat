@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ================== SETTINGS ==================
set "OUT=manifest.json"
set "CHAR_DIR=characters"
set "Q=""

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
    if exist "%%L1.%%E" set "img1=%%L1.%%E"
    if exist "%%L2.%%E" set "img2=%%L2.%%E"
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

REM ================== CHARACTERS (from M1\characters) ==================
set "firstChar=1"

REM ✅ أسماء الشخصيات (lowercase)
for %%N in (khalid sats ali saleh omar wissam haitham) do (

  if "!firstChar!"=="1" (
    set "firstChar=0"
  ) else (
    >>"%OUT%" echo     ,
  )

  REM "name": [
  >>"%OUT%" <nul set /p ="    !Q!%%N!Q!: ["

  set "firstItem=1"

  REM اقرأ من مجلد الشخصيات
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

>>"%OUT%" echo(
>>"%OUT%" echo   }
>>"%OUT%" echo }

echo(
echo ✅ manifest.json updated successfully (pairs from M1 root + characters from %CHAR_DIR%\)
pause
