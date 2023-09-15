@echo off
setlocal EnableDelayedExpansion

set ROOTPATH=%~dp0

pushd %ROOTPATH%

REM Default to the latest Unreal Engine 5 version but can be overriden by any other version, a source build from Github, or even UE4
if [%1] == [] (
  set ENGINE=5.3
) else (
  set ENGINE=%1
)

if "%ENGINE%" == "4.27" (
  set ENGINEPATH="C:\Program Files\Epic Games\UE_%ENGINE%"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool.exe
  REM Legacy "Rocket" binary build of Unreal Engine 4 (using -Engine would try and fail to build the tools)
  set ROCKETENGINE=-Rocket
) else if "%ENGINE%" == "S" (
  set ENGINEPATH="C:\Workspace\UnrealEngine"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
  REM Source code Engine
  set ROCKETENGINE=-Engine
) else (
  set ENGINEPATH="C:\Program Files\Epic Games\UE_%ENGINE%"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
  set ROCKETENGINE=-Engine
)

if not exist %UBT% (
  echo %UBT% not found
  exit /b
)

echo Unsing Unreal Engine %ENGINE% from %ENGINEPATH%

for %%a in (*.uproject) do set "UPROJECT=%CD%\%%a"
if not defined UPROJECT (
  echo *.uproject file not found
  exit /b
)

for %%i in ("%UPROJECT%") do (
  set PROJECT=%%~ni
)

echo Generate Project Files for %UPROJECT% (project '%PROJECT%')


REM See Engine\Source\Programs\UnrealBuildTool\Modes\GenerateProjectFilesMode.cs
REM extract:
REM [CommandLine("-2019", Value = nameof(ProjectFileFormat.VisualStudio2019))] // + override compiler
REM [CommandLine("-2022", Value = nameof(ProjectFileFormat.VisualStudio2022))] // + override compiler
REM [CommandLine("-Makefile", Value = nameof(ProjectFileFormat.Make))]
REM [CommandLine("-CMakefile", Value = nameof(ProjectFileFormat.CMake))]
REM [CommandLine("-QMakefile", Value = nameof(ProjectFileFormat.QMake))]
REM [CommandLine("-KDevelopfile", Value = nameof(ProjectFileFormat.KDevelop))]
REM [CommandLine("-CodeLiteFiles", Value = nameof(ProjectFileFormat.CodeLite))]
REM [CommandLine("-XCodeProjectFiles", Value = nameof(ProjectFileFormat.XCode))]
REM [CommandLine("-EddieProjectFiles", Value = nameof(ProjectFileFormat.Eddie))]
REM [CommandLine("-VSCode", Value = nameof(ProjectFileFormat.VisualStudioCode))]
REM [CommandLine("-VSMac", Value = nameof(ProjectFileFormat.VisualStudioMac))]
REM [CommandLine("-CLion", Value = nameof(ProjectFileFormat.CLion))]
REM [CommandLine("-Rider", Value = nameof(ProjectFileFormat.Rider))]
echo on
@echo.
@echo ## Visual Studio 2019/2022:
%UBT% %UPROJECT% -ProjectFiles -Game %ROCKETENGINE%
@echo.
@REM @echo ## Visual Studio Code:
@REM %UBT% %UPROJECT% -ProjectFiles -Game %ROCKETENGINE% -VSCode
@REM @echo.
@REM @echo ## Rider:
@REM %UBT% %UPROJECT% -ProjectFiles -Game %ROCKETENGINE% -Rider
@REM @echo.
@echo Done
@echo off
