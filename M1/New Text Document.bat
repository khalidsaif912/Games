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

for %%L in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
  set "list="

  for %%E in (png jpg jpeg webp) do (
    for %%F in (sats-%%L*.%%E) do (
      if exist "%%F" (
        if defined list (
          set "list=!list!, "%%F""
        ) else (
          set "list="%%F""
        )
      )
    )
  )

  if defined list (
    if "!firstChar!"=="1" (
      set "firstChar=0"
      >>"%OUT%" echo     "%%L": [!list!]
    ) else (
      >>"%OUT%" echo     , "%%L": [!list!]
    )
  )
)

>>"%OUT%" echo   }
>>"%OUT%" echo }

echo.
echo ✅ manifest.json updated successfully
pause
