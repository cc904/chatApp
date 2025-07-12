@echo off
echo Building Windows Release Version...

:: Enable Windows desktop support
flutter config --enable-windows-desktop

:: Clean previous builds
flutter clean

:: Get dependencies
flutter pub get

:: Build Windows release
flutter build windows --release

:: Create distribution folder
if not exist "dist" mkdir dist
if not exist "dist\windows" mkdir dist\windows

:: Copy release files
xcopy "build\windows\x64\runner\Release\*" "dist\windows\" /E /Y

echo.
echo Build completed successfully!
echo Release files are in: dist\windows\
echo.
echo You can run the app with: dist\windows\cc.exe
pause