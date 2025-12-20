@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Output file
set "OUT=manifest.json"

REM Start JSON
> "%OUT%" echo {
>>"%OUT%" echo   "pairs": [

set "firstPair=1"

REM Loop over files like A1.*, B1.*, ... (one pair per letter)
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  set "img1="
  set "img2="

  REM Find A1.* and A2.* with any common image extension
  for %%E in (png jpg jpeg webp gif) do (
    if exist "%%L1.%%E" set "img1=%%L1.%%E"
    if exist "%%L2.%%E" set "img2=%%L2.%%E"
  )

  REM If both exist, write pair
  if defined img1 if defined img2 (
    if "!firstPair!"=="1" (
      set "firstPair=0"
      >>"%OUT%" echo     {"id":"%%L","img1":"!img1!","img2":"!img2!"}
    ) else (
      >>"%OUT%" echo     ,{"id":"%%L","img1":"!img1!","img2":"!img2!"}
    )
  )
)

REM End JSON
>>"%OUT%" echo   ]
>>"%OUT%" echo }

echo Done. Created "%OUT%" in: %cd%
pause
