@echo off
REM
REM This script assumes that the GDeskTunes repository is cloned 
REM into this parent directory
REM

REM Find the location of QT and QTIFW
IF NOT EXIST C:\Qt\5.4\msvc2013_opengl\bin GOTO :D
PATH=%PATH%;C:\Qt\5.4\msvc2013_opengl\bin
SET QTIFW=C:\Qt\QtIFW-1.5.0
GOTO QT_FOUND
:D
IF NOT EXIST D:\Source\Qt\5.4\msvc2013_opengl\bin GOTO :E
PATH=%PATH%;D:\Source\Qt\5.4\msvc2013_opengl\bin
SET QTIFW=D:\Source\QtIFW-1.5.0
GOTO QT_FOUND
:E
PATH=%PATH%;E:\Source\Qt\5.4\msvc2013_opengl\bin
SET QTIFW=E:\Source\Qt\QtIFW-1.5.0
:QT_FOUND

setlocal enabledelayedexpansion

set argCount=0
for %%x in (%*) do (
   set /A argCount+=1
   set "argVec[!argCount!]=%%~x"
   if "%%~x" == "clean" set CLEAN=0
)

REM echo Number of processed arguments: %argCount%
REM for /L %%i in (1,1,%argCount%) do echo %%i- "!argVec[%%i]!"

REM Build GDeskTunes Completely
cd build
qmake ..\..\GDeskTunes\GDeskTunes.pro
if DEFINED CLEAN (
	nmake clean
)
nmake release install
cd ..

REM Create Qt distribution Files
rmdir /S /Q GDeskTunesTmp
mkdir GDeskTunesTmp

xcopy /S build\src\release\GDeskTunes.exe GDeskTunesTmp
windeployQt GDeskTunesTmp\GDeskTunes.exe
del /S GDeskTunesTmp\GDeskTunes.exe

rmdir /Q /S installer\packages\io.qt\data
mkdir installer\packages\io.qt\data
xcopy /S /Y GDeskTunesTmp\* installer\packages\io.qt\data

REM Create GDeskTunes program
rmdir /S /Q GDeskTunesTmp
mkdir GDeskTunesTmp

xcopy /S build\src\release\*.exe GDeskTunesTmp
xcopy /S build\src\release\*.dll GDeskTunesTmp
xcopy /S build\lib\mmshellhook\release\*.dll GDeskTunesTmp
xcopy /S build\src\release\js GDeskTunesTmp\js\
xcopy /S build\src\release\userstyles GDeskTunesTmp\userstyles\

rmdir /Q /S installer\packages\org.gearlux.gdesktunes\data
mkdir installer\packages\org.gearlux.gdesktunes\data
xcopy /S /Y GDeskTunesTmp\* installer\packages\org.gearlux.gdesktunes\data

REM del /Q GDeskTunesInstaller.exe
REM del /Q GDeskSetup.exe
REM rmdir /Q /S windows

%QTIFW%\bin\repogen.exe -p installer\packages --update -e io.qt,com.microsoft.vcredist_2008,com.microsoft.vcredist_2013,com.slproweb.openssl windows
%QTIFW%\bin\binarycreator.exe --offline-only -c installer\config\windows_config.xml -p installer\packages GDeskInstaller.exe
%QTIFW%\bin\binarycreator.exe -c installer\config\windows_config.xml -p installer\packages -e io.qt,com.microsoft.vcredist_2008,com.microsoft.vcredist_2013,com.slproweb.openssl GDeskSetup.exe

REM move GDeskTunesInstaller.exe windows
move GDeskSetup.exe windows
