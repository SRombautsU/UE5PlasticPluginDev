@echo off
setlocal

set ROOT_PATH=%~dp0

pushd %ROOT_PATH%

echo Plugins\UEPlasticPlugin\PlasticSourceControl.uplugin:
type Plugins\UEPlasticPlugin\PlasticSourceControl.uplugin
echo.

REM Read the plugin version from uplugin file and prompt the user to check, and name zip files from the version
if [%1] == [] (
  set /p VERSION="Enter the version name exactly as in the UE4PlasticPlugin.uplugin above: "
) else (
  set VERSION=%1
)
if [%VERSION%] == [] (
  echo Version is empty
  exit /b 1
)

REM TODO: double check with the uplugin and also search in the README

REM Let's also check we are on main
echo on
git branch
@echo off

REM Ask the user if they agree to do a git clean & a git reset!
set /p GIT_CLEAN_RESET="Git clean & reset before building. WARNING: All your local changes will be stashed away! (ENTER/N)? "
if [%GIT_CLEAN_RESET%] == [] (
  echo on
  git stash --message "Automatic stash from BuildAndPackageForRelease %VERSION%"
  git clean -fdx
  git reset --hard
  pushd Plugins\UEPlasticPlugin
  git stash --message "Automatic stash from BuildAndPackageForRelease %VERSION%"
  git clean -fdx
  git reset --hard
  popd
  @echo off
) else (
  echo WARNING: Skipping git clean should only be for testing purpose!
)

REM create a tag on the current branch
set /p GIT_TAG="Git tag version %VERSION% of the plugin on the current branch (ENTER/N)? "
if [%GIT_TAG%] == [] (
  echo on
  pushd Plugins\UEPlasticPlugin
  git tag %VERSION%
  popd
  @echo off
)


REM
REM #####################
REM
call :BuildAndPackage 5.0
call :BuildAndPackage 5.1
call :BuildAndPackage 5.2
call :BuildAndPackage 5.3
call :BuildAndPackage 5.4
REM
REM #####################
REM

echo.
echo NOTE: After validation, push the new tag using:
echo   git push https://github.com/PlasticSCM/UEPlasticPlugin.git %VERSION%

exit /b %ERRORLEVEL%



REM
REM ################# BuildAndPackage Function
REM

:BuildAndPackage

set UNREAL_ENGINE=%~1

REM Let's ensure that the plugin correctly builds
del /Q Plugins\UEPlasticPlugin\Binaries\Win64\*
call Build.bat %UNREAL_ENGINE%

if "%UNREAL_ENGINE%" == "4.27" (
  if NOT exist Plugins\UEPlasticPlugin\Binaries\Win64\UE4Editor-PlasticSourceControl.dll (
    echo Something is wrong, UE4Editor-PlasticSourceControl.dll binaries are missing.
    exit /b 1
  )
) else (
  if NOT exist Plugins\UEPlasticPlugin\Binaries\Win64\UnrealEditor-PlasticSourceControl.dll (
    echo Something is wrong, UnrealEditor-PlasticSourceControl.dll binaries are missing.
    exit /b 1
  )
)

set ARCHIVE_NAME_REL=UE%UNREAL_ENGINE%_PlasticPlugin-%VERSION%.zip
set ARCHIVE_NAME_DBG=UE%UNREAL_ENGINE%_PlasticPlugin-%VERSION%-with-debug-symbols.zip

echo on
del %ARCHIVE_NAME_REL%
del %ARCHIVE_NAME_DBG%

Tools\7-Zip\x64\7za.exe a -tzip %ARCHIVE_NAME_REL% Plugins -xr!".git*" -xr!Intermediate -xr!.editorconfig -xr!_config.yml -xr!Screenshots -xr!"*.pdb"
Tools\7-Zip\x64\7za.exe a -tzip %ARCHIVE_NAME_DBG% Plugins -xr!".git*" -xr!Intermediate -xr!.editorconfig -xr!_config.yml -xr!Screenshots
@echo off

echo Done for Unreal Engine %UNREAL_ENGINE%
echo.

exit /b %ERRORLEVEL%

REM
REM #################
REM
