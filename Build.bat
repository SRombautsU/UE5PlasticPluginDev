@echo off
setlocal EnableDelayedExpansion

set ROOTPATH=%~dp0

pushd %ROOTPATH%

REM Default to the latest Unreal Engine 5 version but can be overriden by any other version, a source build from Github, or even UE4
if [%1] == [] (
  set ENGINE=5.7
) else (
  set ENGINE=%1
)

if "%ENGINE%" == "S" (
  REM Source code Engine
  set ENGINEPATH=C:\Workspace\UnrealEngine
  set ROCKETENGINE=-Engine
) else (
  set ENGINEPATH=C:\Program Files\Epic Games\UE_%ENGINE%
  set ROCKETENGINE=-Rocket
)

set UBT="%ENGINEPATH%\Engine\Build\BatchFiles\Build.bat"

if not exist %UBT% (
  echo %UBT% not found
  exit /b
)

echo Unsing Unreal Engine %ENGINE% from "%ENGINEPATH%"

for %%a in (*.uproject) do set UPROJECT="%CD%\%%a"
if not defined UPROJECT (
  echo *.uproject file not found
  exit /b
)

for %%i in (%UPROJECT%) do (
  set PROJECT=%%~ni
)

echo Build %UPROJECT% (project '%PROJECT%')

echo on
%UBT% %UPROJECT% Win64 Development %PROJECT%Editor
@echo off
