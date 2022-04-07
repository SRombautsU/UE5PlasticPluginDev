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
%UBT% %UPROJECT% -ProjectFiles
@echo off
