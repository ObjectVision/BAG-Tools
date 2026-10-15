@echo off
rem ---------------------------------------------------------------------------
rem  BAG 2.0 XML > MMD-stores, in een GeoDmsRun-proces met een geheugenbudget.
rem
rem  Xml2MMD parseert pand, vbo en nummeraanduiding per fileset van 50
rem  XML-bestanden naar een tussenstore in %LocalDataProjDir%/Temp/<date>
rem  (stap 1, Step1_Make_Temp_Files) en voegt die in een tweede aanroep samen
rem  tot een store per objecttype in StoreDir (stap 2, Step2_Make_MMD_Files). Een
rem  driver per fileset laat het geheugen van een fileset los zodra de
rem  tussenstore ervan geschreven is (ObjectVision/GeoDMS#1259). Het budget
rem  /SB<MB> begrenst hoeveel filesets tegelijk in bewerking zijn: de update-
rem  loop stelt commits uit zolang het procesgeheugen plus het onderhanden werk
rem  onder het budget blijft.
rem
rem  Gemeten op het extract van 2026-10-08 (GeoDMS 20.23.1, 32 threads, budget
rem  8000 MB): stap 1 31 minuten met een piek van 2,2 GB, stap 2 35 seconden
rem  met 1,6 GB. Beide stappen in een proces hield alle filesets vast: 75 GB.
rem
rem  Gebruik:   RunXml2MMD.bat [GEO_ENGINE=geos|dms] [MEM_BUDGET_MB=8000] [BAG_DIR=<map>] [PER_FILESET=0|1]
rem    GEO_ENGINE     familie polygoonoperatoren voor het samenvoegen per pand:
rem                   geos (default) of dms; doorgegeven als de
rem                   ConfigSettings/Overridable-instelling GEODMS_Overridable_GEO_ENGINE
rem    MEM_BUDGET_MB  geheugenbudget in MB voor /SB (default 8000)
rem    BAG_DIR        de map met per extract een submap <date> (default
rem                   %SourceDataDir%/BAG); de XML staat in <BAG_DIR>/<date>/NGR,
rem                   de stores komen in <BAG_DIR>/<date>/mmd
rem    PER_FILESET=1  elke fileset in een apart GeoDmsRun-proces, voor wie het
rem                   geheugen hard wil begrenzen op een fileset; daarna voegt
rem                   een proces de tussenstores samen
rem  Instelbaar via omgevingsvariabelen (met de defaults hieronder):
rem    GEODMS_DIR   map met GeoDmsRun.exe (20.23.1 of later)
rem    XML2MMD_CFG  pad naar Xml2MMD.dms
rem    XML2MMD_LOG  pad naar het logbestand
rem ---------------------------------------------------------------------------

setlocal enabledelayedexpansion

rem  De map van dit batchbestand, vastgelegd voor de argumentenlus: shift schuift ook
rem  %%0 op, zodat %%~dp0 daarna de map van een argument geeft en niet die van dit bestand.
set "BATDIR=%~dp0"

set MEM_BUDGET_MB=8000
set PER_FILESET=0

rem --- argumenten -------------------------------------------------------------
rem  cmd splitst "NAAM=waarde" op de = in twee argumenten; tussen aanhalingstekens
rem  blijft het een argument. Beide vormen worden hier begrepen.
:Args
if "%~1"=="" goto :ArgsDone
set "_key="
set "_val="
for /f "tokens=1,* delims==" %%a in ("%~1") do (set "_key=%%a" & set "_val=%%b")
if "%_val%"=="" (
	set "_val=%~2"
	shift
)
if /i "%_key%"=="GEO_ENGINE" (
	if /i "%_val%"=="geos" (set GEODMS_Overridable_GEO_ENGINE=geos) else if /i "%_val%"=="dms" (set GEODMS_Overridable_GEO_ENGINE=dms) else (
		echo Onbekende GEO_ENGINE: %_val%; kies geos of dms.
		exit /b 2
	)
) else if /i "%_key%"=="MEM_BUDGET_MB" (
	set "MEM_BUDGET_MB=%_val%"
) else if /i "%_key%"=="BAG_DIR" (
	set "GEODMS_Overridable_BAG_DIR=%_val:\=/%"
) else if /i "%_key%"=="PER_FILESET" (
	set "PER_FILESET=%_val%"
) else (
	echo Onbekend argument: %_key%
	exit /b 2
)
shift
goto :Args
:ArgsDone
if not "%GEODMS_Overridable_GEO_ENGINE%"=="" echo GEO_ENGINE=%GEODMS_Overridable_GEO_ENGINE%
if not "%GEODMS_Overridable_BAG_DIR%"=="" echo BAG_DIR=%GEODMS_Overridable_BAG_DIR%
echo MEM_BUDGET_MB=%MEM_BUDGET_MB%

if "%GEODMS_DIR%"==""  set GEODMS_DIR=C:\Program Files\ObjectVision\GeoDms20.23.1.m
if "%XML2MMD_CFG%"=="" set XML2MMD_CFG=%BATDIR%..\cfg\Xml2MMD.dms
if "%XML2MMD_LOG%"=="" set XML2MMD_LOG=%BATDIR%..\Xml2MMD.log

set ProgramPath=%GEODMS_DIR%\GeoDmsRun.exe
set Budget=/SB%MEM_BUDGET_MB%

if not exist "%ProgramPath%" (
	echo GeoDmsRun.exe niet gevonden in %GEODMS_DIR%; zet GEODMS_DIR.
	exit /b 2
)
if not exist "%XML2MMD_CFG%" (
	echo Configuratie niet gevonden: %XML2MMD_CFG%; zet XML2MMD_CFG.
	exit /b 2
)

echo %DATE% %TIME%  start

if "%PER_FILESET%"=="1" goto :PerFileSetMode

rem --- stap 1 en stap 2, elk in een eigen proces, met budget ---------------
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /Step1_Make_Temp_Files
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT in stap 1; zie %XML2MMD_LOG%
	exit /b 1
)
echo %DATE% %TIME%  stap 1 klaar, de tussenstores staan in %%LocalDataProjDir%%/Temp
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /Step2_Make_MMD_Files
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT in stap 2; zie %XML2MMD_LOG%
	exit /b 1
)
echo %DATE% %TIME%  klaar
exit /b 0

rem --- een proces per fileset ----------------------------------------------
rem  Elke fileset schrijft zijn tussenstore in een eigen proces; het laatste
rem  proces vindt die tussenstores en voegt ze samen tot de stores in StoreDir.
:PerFileSetMode
call :PerFileSet pand
if errorlevel 1 exit /b 1
call :PerFileSet vbo
if errorlevel 1 exit /b 1
call :PerFileSet nummeraanduiding
if errorlevel 1 exit /b 1

echo %DATE% %TIME%  samenvoegen en de overige stores
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /Step2_Make_MMD_Files
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT bij het samenvoegen; zie %XML2MMD_LOG%
	exit /b 1
)
echo %DATE% %TIME%  klaar
exit /b 0

rem ---------------------------------------------------------------------------
rem  :PerFileSet <objecttype>
rem  Draait fs_1, fs_2, ... elk in een eigen proces en stopt zodra GeoDmsRun het
rem  item niet meer vindt. Een echte rekenfout geeft hetzelfde ErrorLevel, dus
rem  het log is leidend bij een vroegtijdige stop.
rem ---------------------------------------------------------------------------
:PerFileSet
set _type=%~1
set _i=0
:PerFileSetLoop
set /a _i+=1
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /SourceData/%_type%/PerFileSet/fs_%_i%/%_type%
if errorlevel 1 goto :PerFileSetDone
echo %DATE% %TIME%  %_type% fileset %_i% geschreven
goto :PerFileSetLoop

:PerFileSetDone
set /a _i-=1
if %_i%==0 (
	echo %DATE% %TIME%  FOUT: geen enkele %_type%-fileset verwerkt; zie %XML2MMD_LOG%
	exit /b 1
)
echo %DATE% %TIME%  %_type%: %_i% filesets verwerkt
exit /b 0
