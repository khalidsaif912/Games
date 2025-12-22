@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "OUT=manifest.json"

REM ========== START ==========
> "%OUT%" echo {
>>"%OUT%" echo   "pairs": [

set "firstPair=1"

REM ---- PAIRS ----
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

REM ---- CHARACTERS ----
set "firstChar=1"

REM ✅ أسماء الشخصيات (اكتبها lowercase)
for %%N in (khalid sats ali saleh omar wissam haitham) do (
  set "list="

  for %%E in (png jpg jpeg webp) do (
    for %%F in ("%%N-*.%%E") do (
      if exist "%%~fF" (
        if defined list (
          set "list=!list!, ""%%~nxF"""
        ) else (
          set "list=""%%~nxF"""
        )
      )
    )
  )

  if defined list (
    if "!firstChar!"=="1" (
      set "firstChar=0"
      >>"%OUT%" echo     "%%N": [!list!]
    ) else (
      >>"%OUT%" echo     , "%%N": [!list!]
    )
  )
)

>>"%OUT%" echo   }
>>"%OUT%" echo }

echo.
echo ✅ manifest.json updated successfully
pause
