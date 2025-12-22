@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo {> manifest.json
echo   "images": [>> manifest.json

set first=1

for %%f in (*.png *.jpg *.jpeg *.webp) do (
    if !first! == 0 (
        echo ,>> manifest.json
    )
    set first=0
    echo     { "img": "%%f", "label": "%%~nf" }>> manifest.json
)

echo.>> manifest.json
echo   ]>> manifest.json
echo }>> manifest.json

echo.
echo ✅ تم إنشاء manifest.json بنجاح داخل مجلد G2
pause
