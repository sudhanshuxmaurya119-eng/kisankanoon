@echo off
setlocal

for %%I in ("%~dp0") do set "APP_DIR=%%~fsI"
for %%I in ("%USERPROFILE%\flutter") do set "FLUTTER_DIR=%%~fsI"

set "PUB_CACHE=C:\pubcache"
if not exist "%PUB_CACHE%" mkdir "%PUB_CACHE%"

if not exist "%FLUTTER_DIR%\bin\flutter.bat" (
  echo Flutter SDK not found at "%USERPROFILE%\flutter".
  exit /b 1
)

echo Building Flutter web app...
set "PUB_CACHE=%PUB_CACHE%"
call "%FLUTTER_DIR%\bin\flutter.bat" build web
if errorlevel 1 exit /b 1

echo Writing Vercel SPA config...
>"%APP_DIR%build\web\vercel.json" (
  echo {
  echo   "rewrites": [
  echo     { "source": "/(.*)", "destination": "/index.html" }
  echo   ]
  echo }
)

echo Deploying build\web to Vercel...
pushd "%APP_DIR%build\web"
call npx --yes vercel deploy --prod --yes
set "EXIT_CODE=%ERRORLEVEL%"
popd

exit /b %EXIT_CODE%
