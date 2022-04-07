@echo off
setlocal

set ROOTPATH=%~dp0

pushd %ROOTPATH%

if [%1] == [] (
  set /p ENGINE="Select the version of the Engine to build with [4/5]: "
) else (
  set ENGINE=%1
)
if [%ENGINE%] == [] (
  echo Engine version is empty
  exit /b 1
) else if "%ENGINE%" == "4" (
  set UBT="C:\Program Files\Epic Games\UE_4.27\Engine\Binaries\DotNET\UnrealBuildTool.exe"
) else if "%ENGINE%" == "5" (
  set UBT="C:\Program Files\Epic Games\UE_5.0\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"
) else (
  echo Engine version '%ENGINE%' need to be 4 or 5
  exit /b 1
)

if not exist %UBT% (
    echo %UBT% not found
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

echo on
%UBT% %UPROJECT% Win64 Development %PROJECT%Editor
@echo off
