@echo off
setlocal EnableDelayedExpansion

set ROOTPATH=%~dp0

pushd %ROOTPATH%

echo on

rd /s /q Binaries
rd /s /q DerivedDataCache
rd /s /q Intermediate
rd /s /q Saved
rd /s /q Script
rd /s /q enc_temp_folder

rd /s /q Plugins\UEPlasticPlugin\Binaries
rd /s /q Plugins\UEPlasticPlugin\Intermediate
@echo off

for %%a in (*.sln) do set "SLN=%CD%\%%a"
if defined SLN (
  @echo on
  del %SLN%
  @echo off
)

