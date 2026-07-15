@echo off
if "%BUILD_VER%"=="" set BUILD_VER=8.0.26

DEL /s /q *.wixobj
DEL /s /q net10.0.wxs
RMDIR /S /Q BIN
RMDIR /S /Q xdm-helper-chrome

MKDIR BIN
MKDIR BIN\chrome-extension
MKDIR BIN\ext-loader
MKDIR BIN\XDM.App.Host

dotnet build -c Release -f net10.0-windows ..\XDM.Wpf.UI\XDM.Wpf.UI.csproj -o BIN
dotnet build -c Release -f net10.0 ..\XDM.App.Host\XDM.App.Host.csproj -o BIN\XDM.App.Host

copy /B /Y ffmpeg-x86.exe BIN
git clone https://github.com/subhra74/xdm-helper-chrome.git

xcopy /E /Y /I xdm-helper-chrome\chrome\chrome-extension BIN\chrome-extension
xcopy /E /Y /I xdm-helper-chrome\ext-loader BIN\ext-loader

heat dir BIN -o net10.0.wxs -scom -frag -srd -sreg -gg -cg NET100 -dr INSTALLFOLDER

powershell -Command "(Get-Content product.wxs) -replace 'NET460', 'NET100' | Set-Content product.wxs"

candle product.wxs net10.0.wxs
light -ext WixUIExtension -ext WixUtilExtension -cultures:en-us product.wixobj net10.0.wixobj -b BIN -out xdmsetup-%BUILD_VER%-x86.msi
