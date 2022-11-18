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
  REM Legacy "Rocket" binary build of Unreal Engine 4 (using -Engine would try and fail to build the tools)
  set ROCKETENGINE=-Rocket
) else if "%ENGINE%" == "5" (
  set ENGINEPATH="C:\Program Files\Epic Games\UE_5.1"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
  REM Binary Unreal Engine 5 got rid of the legacy -Rocket flag for binary builds
  set ROCKETENGINE=-Engine
) else if "%ENGINE%" == "S" (
  set ENGINEPATH="C:\Workspace\UnrealEngine"
  set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe
  REM Source code Engine
  set ROCKETENGINE=-Engine
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

echo Generate Project Files for %UPROJECT%


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
@echo ## Visual Studio Code:
%UBT% %UPROJECT% -ProjectFiles -Game %ROCKETENGINE% -VSCode
@echo.
@echo ## Rider:
%UBT% %UPROJECT% -ProjectFiles -Game %ROCKETENGINE% -Rider
@echo.
@echo Done
@echo off
