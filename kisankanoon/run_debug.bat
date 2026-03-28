@echo off
set "SHORT_USER=C:\Users\SUDHAN~1"
set "SHORT_PROJECT=%SHORT_USER%\Desktop\FARMER~1\KISANK~1"
set "PATH=%SHORT_USER%\flutter\bin;C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin;%PATH%"
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot"
set "PUB_CACHE=%SHORT_USER%\AppData\Local\Pub\Cache"

cd /d "%SHORT_PROJECT%"
echo Running app on connected Android device...
echo (Press q in this window to stop)
call flutter run --debug
pause
