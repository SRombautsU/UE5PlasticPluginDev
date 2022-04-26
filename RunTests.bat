@echo off
setlocal

set ROOTPATH=%~dp0

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

REM see https://docs.unrealengine.com/en-US/Programming/Basics/CommandLineArguments
REM see UnrealEngine\Engine\Source\Editor\UnrealEd\Private\UnrealEdSrv.cpp
REM -unattended: Set as unattended. Disable anything requiring feedback from user.
REM -NullRHI: disable rendering of the Editor
REM NOTE: cannot redirect std output to a file since we are not using a Commandlet here
echo.
echo %TIME% Running Unit Tests (~30s, logs in Game\Saved\Logs)
echo on
%UE4EDITOR% %UPROJECT% -ExecCmds="Automation RunTests PlasticSCM" -TestExit="Automation Test Queue Empty" -Unattended -NullRHI -Log -Log=RunTests.log
@echo off

if %errorlevel% neq 0 (
	echo %TIME% ERROR: Exit code %ERRORLEVEL% for command RunTests
	exit /b %errorlevel%
)
echo %TIME% Exit code %ERRORLEVEL% for command RunTests

popd
