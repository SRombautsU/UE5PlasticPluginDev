@echo off
setlocal EnableDelayedExpansion

set ROOTPATH=%~dp0

pushd %ROOTPATH%

REM Default to Unreal Engine 5, but can be overriden to Sources from Github or to UE4
if [%1] == [] (
  set ENGINE=5
) else (
  set ENGINE=%1
)

if "%ENGINE%" == "4" (
  set ENGINEPATH="C:\Program Files\Epic Games\UE_4.27"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool.exe
) else if "%ENGINE%" == "50" (
  set ENGINEPATH="C:\Program Files\Epic Games\UE_5.0"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
) else if "%ENGINE%" == "51" (
  set ENGINEPATH="C:\Program Files\Epic Games\UE_5.1"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
) else if "%ENGINE%" == "5" (
  set ENGINEPATH="C:\Program Files\Epic Games\UE_5.1"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
) else if "%ENGINE%" == "S" (
  set ENGINEPATH="C:\Workspace\UnrealEngine"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
) else (
  echo Engine version '%ENGINE%' need to be 4, 5 or S for Sources from Github
  exit /b 1
)

if not exist %UBT% (
    echo %UBT% not found
    exit /b
)

echo Unsing Unreal Engine from %ENGINEPATH%

for %%a in (*.uproject) do set "UPROJECT=%CD%\%%a"
if not defined UPROJECT (
    echo *.uproject file not found
    exit /b
)

for %%i in ("%UPROJECT%") do (
  set PROJECT=%%~ni
)

echo Generate Project Files for %UPROJECT% (project '%PROJECT%')


echo on
%UBT% %UPROJECT% Win64 Development %PROJECT%Editor
@echo off
