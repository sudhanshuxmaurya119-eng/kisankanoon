@echo off
set "SHORT_USER=C:\Users\SUDHAN~1"
set "SHORT_PROJECT=%SHORT_USER%\Desktop\FARMER~1\KISANK~1"
set "SHORT_FLUTTER=%SHORT_USER%\flutter\bin"
set "PATH=%SHORT_FLUTTER%;C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin;%PATH%"
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot"
set "PUB_CACHE=%SHORT_USER%\AppData\Local\Pub\Cache"
set "DART_ROOT=%SHORT_USER%\flutter\bin\cache\dart-sdk"

echo.
echo ==========================================
echo  Checking for google-services.json ...
echo ==========================================
if not exist "%SHORT_PROJECT%\android\app\google-services.json" (
    echo ERROR: google-services.json NOT found in android\app\
    pause
    exit /b 1
)
echo  Found! Building APK...

cd /d "%SHORT_PROJECT%"

echo Cleaning previous build...
call flutter clean

echo Getting packages...
call flutter pub get

echo.
echo ==========================================
echo  Building APK... (2-3 minutes)
echo ==========================================
call flutter build apk --debug

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo.
    echo ==========================================
    echo  SUCCESS! APK ready. Opening folder...
    echo ==========================================
    explorer "build\app\outputs\flutter-apk\"
) else (
    echo.
    echo  BUILD FAILED. See errors above.
)
pause
