@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "OUT=manifest.json"
set "CHAR_DIR=characters"

set "LIST=%TEMP%\G1_img_list_%RANDOM%.txt"
set "PAIRKEYS=%TEMP%\G1_pair_keys_%RANDOM%.txt"
set "CHARKEYS=%TEMP%\G1_char_keys_%RANDOM%.txt"

del /q "%LIST%" "%PAIRKEYS%" "%CHARKEYS%" 2>nul

REM =========================
REM 1) Collect ALL images in root
REM =========================
for %%E in (png jpg jpeg webp) do (
  for /f "delims=" %%F in ('dir /b /a-d "*.%%E" 2^>nul') do (
    REM Skip card-back
    echo %%F | findstr /I /R "^card-back\." >nul
    if errorlevel 1 (
      echo %%F>>"%LIST%"
    )
  )
)

if not exist "%LIST%" (
  echo ⚠️ لم يتم العثور على صور في %CD%
  echo    تأكد أن الصور موجودة في نفس المجلد.
  pause
  exit /b 0
)

sort /L C "%LIST%" /O "%LIST%"

REM =========================
REM 2) Build PAIRS from filenames (A1/A2 or A-a1/A-a2 or A-1/A-2 etc)
REM =========================
for /f "usebackq delims=" %%F in ("%LIST%") do (
  set "FILE=%%F"
  for %%A in ("%%F") do set "BASE=%%~nA"

  REM تنظيف لاحقة مثل (2) من الاسم لو موجودة
  set "NAME=!BASE!"
  echo !NAME! | findstr /R ".*(.*)" >nul
  REM إزالة " (رقم)" في نهاية الاسم إن وجدت
  for /f "delims=" %%Z in ('echo !NAME! ^| powershell -NoProfile -Command "$i=Get-Content -Raw -; $i -replace '\s*\(\d+\)\s*$',''"') do set "NAME=%%Z"

  set "SIDE="
  set "KEY=!NAME!"

  REM ===== patterns: a1/a2 at end
  if /I "!NAME:~-2!"=="a1" (set "SIDE=1" & set "KEY=!NAME:~0,-2!")
  if /I "!NAME:~-2!"=="a2" (set "SIDE=2" & set "KEY=!NAME:~0,-2!")

  REM ===== patterns: 1/2 at end
  if not defined SIDE (
    if "!NAME:~-1!"=="1" (set "SIDE=1" & set "KEY=!NAME:~0,-1!")
    if "!NAME:~-1!"=="2" (set "SIDE=2" & set "KEY=!NAME:~0,-1!")
  )

  REM إزالة فاصل أخير "-" أو "_" أو " " من المفتاح
  if defined SIDE (
    set "LAST=!KEY:~-1!"
    if "!LAST!"=="-" set "KEY=!KEY:~0,-1!"
    if "!LAST!"=="_" set "KEY=!KEY:~0,-1!"
    if "!LAST!"==" " set "KEY=!KEY:~0,-1!"

    if not defined KEY set "KEY=!NAME!"

    findstr /I /X /C:"!KEY!" "%PAIRKEYS%" >nul 2>&1 || echo !KEY!>>"%PAIRKEYS%"

    if "!SIDE!"=="1" set "P1_!KEY!=!FILE!"
    if "!SIDE!"=="2" set "P2_!KEY!=!FILE!"
  )
)

REM =========================
REM 3) Write manifest.json: pairs + images + characters
REM =========================
> "%OUT%" echo {
>>"%OUT%" echo   "pairs": [

set "firstPair=1"
if exist "%PAIRKEYS%" (
  for /f "usebackq delims=" %%K in ("%PAIRKEYS%") do (
    call set "F1=%%P1_%%K%%"
    call set "F2=%%P2_%%K%%"
    if defined F1 if defined F2 (
      if "!firstPair!"=="1" (
        set "firstPair=0"
        >>"%OUT%" echo     { "id": "%%K", "img1": "!F1!", "img2": "!F2!" }
      ) else (
        >>"%OUT%" echo     ,{ "id": "%%K", "img1": "!F1!", "img2": "!F2!" }
      )
    )
  )
)
>>"%OUT%" echo   ],

REM ===== images section (optional - useful for other games)
>>"%OUT%" echo   "images": [
set "firstImg=1"
for /f "usebackq delims=" %%S in ("%LIST%") do (
  for %%A in ("%%S") do set "LBL=%%~nA"
  if "!firstImg!"=="1" (
    set "firstImg=0"
    >>"%OUT%" echo     { "img": "%%S", "label": "!LBL!" }
  ) else (
    >>"%OUT%" echo     ,{ "img": "%%S", "label": "!LBL!" }
  )
)
>>"%OUT%" echo   ],

REM ===== characters
>>"%OUT%" echo   "characters": {

if not exist "%CHAR_DIR%\" (
  >>"%OUT%" echo   }
  >>"%OUT%" echo }
  del /q "%LIST%" "%PAIRKEYS%" "%CHARKEYS%" 2>nul
  echo(
  echo ✅ تم إنشاء manifest.json (pairs + images) بنجاح — بدون شخصيات
  pause
  exit /b 0
)

REM Discover unique character keys
for %%E in (png jpg jpeg webp) do (
  for /f "delims=" %%F in ('dir /b /a-d "%CHAR_DIR%\*.%%E" 2^>nul') do (
    set "FN=%%~nF"
    set "KEY=!FN!"
    for /f "tokens=1 delims=-" %%K in ("!KEY!") do set "KEY=%%K"
    for /f "tokens=1 delims=_" %%K in ("!KEY!") do set "KEY=%%K"
    findstr /I /X /C:"!KEY!" "%CHARKEYS%" >nul 2>&1 || echo !KEY!>>"%CHARKEYS%"
  )
)

set "firstChar=1"
if exist "%CHARKEYS%" (
  for /f "usebackq delims=" %%N in ("%CHARKEYS%") do (
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

del /q "%LIST%" "%PAIRKEYS%" "%CHARKEYS%" 2>nul

echo(
echo ✅ تم إنشاء manifest.json (pairs + images + characters) بنجاح
echo 📌 ملاحظة: أي صورة بدون زوج (مثل w.png) سيتم تجاهلها داخل pairs.
pause
