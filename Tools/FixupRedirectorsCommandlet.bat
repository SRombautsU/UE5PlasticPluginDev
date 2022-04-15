@echo off
setlocal

set BATCHPATH=%~dp0
set ROOTPATH="%~dp0\.."

pushd %ROOTPATH%

REM Default to Unreal Engine 5, but can be overriden to UE4
if [%1] == [] (
  set ENGINE=5
) else (
  set ENGINE=%1
)

if "%ENGINE%" == "4" (
  set UE4EDITOR="C:\Program Files\Epic Games\UE_4.27\Engine\Binaries\Win64\UE4Editor-Cmd.exe"
) else if "%ENGINE%" == "5" (
  set UE4EDITOR="C:\Program Files\Epic Games\UE_5.0\Engine\Binaries\Win64\UnrealEditor-Cmd.exe"
) else (
  echo Engine version '%ENGINE%' need to be 4 or 5
  exit /b 1
)

if not exist %UE4EDITOR% (
    echo %UE4EDITOR% not found
    exit /b
)

for %%a in (*.uproject) do set "UPROJECT=%CD%\%%a"
if not defined UPROJECT (
    echo *.uproject file not found
    exit /b
)

for %%i in ("%UPROJECT%") do (
  set PROJECT=%%~ni
)

REM Using "ResavePackages" commandlet (see https://docs.unrealengine.com/en-us/Engine/Basics/Redirectors#resavepackagescommandlet)
REM -ProjectOnly:	Exclude Engine Packages
REM -unattended:	Editor is not monitored or is unable to receive user input. Disable UI pop-ups or other dialogs.
echo on
%UE4EDITOR% %UPROJECT% -run=ResavePackages -FixupRedirectors -AutoCheckOut -AutoCheckIn -ProjectOnly -unattended -Log=FixupRedirectors.log
@echo off
if %errorlevel% neq 0 (
	echo %TIME% ERROR: Exit code %ERRORLEVEL%
	exit /b %errorlevel%
)
