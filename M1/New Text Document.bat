@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "OUT=manifest.json"

> "%OUT%" echo {
>>"%OUT%" echo   "pairs": [

REM ---- PAIRS ----
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

REM ---- CHARACTERS ----
set "firstChar=1"

REM ✅ أسماء الشخصيات (لازم lowercase)
for %%N in (khalid sats ali saleh omar wissam haitham) do (
  REM سنكتب: "name": [ ... ]
  set "wroteAny=0"
  set "firstItem=1"

  REM ابدأ سطر الشخصية
  if "!firstChar!"=="1" (
    set "firstChar=0"
    >>"%OUT%" <nul set /p ="    ""%%N"": ["
  ) else (
    >>"%OUT%" <nul set /p =",    ""%%N"": ["
  )

  REM اجمع الملفات من كل الامتدادات
  for %%E in (png jpg jpeg webp) do (
    for %%F in ("%%N-*.%%E") do (
      if exist "%%~fF" (
        set "wroteAny=1"
        if "!firstItem!"=="1" (
          set "firstItem=0"
          >>"%OUT%" <nul set /p ="""%%~nxF"""
        ) else (
          >>"%OUT%" <nul set /p =", ""%%~nxF"""
        )
      )
    )
  )

  REM اغلق مصفوفة الشخصية
  >>"%OUT%" echo ]
)

>>"%OUT%" echo   }
>>"%OUT%" echo }

echo.
echo ✅ manifest.json updated successfully
pause
