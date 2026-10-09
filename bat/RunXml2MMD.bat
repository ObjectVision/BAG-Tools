@echo off
rem ---------------------------------------------------------------------------
rem  BAG 2.0 XML > MMD-stores, in een GeoDmsRun-proces met een geheugenbudget.
rem
rem  GeoDMS 20.20.0 verwerkt de filesets van een objecttype naast elkaar en
rem  laat het geheugen van een fileset los zodra de store ervan geschreven is
rem  (ObjectVision/GeoDMS#1259). Het budget /SB<MB> bepaalt hoeveel filesets
rem  tegelijk in bewerking zijn: de update-loop stelt commits uit zolang het
rem  procesgeheugen plus het onderhanden werk onder het budget blijft.
rem
rem  Gemeten op het PND-extract van 20260808 (2452 bestanden, 12,2 GB XML,
rem  50 filesets), GeoDMS 20.20.0 dev 4d422d9d9, machine met 32 threads:
rem                   geos                 dms
rem    /SB4000     177 s  19,8 GB       169 s  13,0 GB
rem    /SB8000     132 s  20,0 GB       137 s  20,4 GB
rem    /SB16000    161 s  30,8 GB       163 s  31,4 GB
rem    serieel (GeoDMS 20.19)  310 s  3,3 GB
rem  De piek ligt boven het budget, ongeveer 2,5x bij 8000 MB, omdat het
rem  budget het onderhanden werk schat en niet meet. Een lager budget is niet
rem  per se langzamer: bij 16000 MB hinderen negen gelijktijdige parses elkaar.
rem  De stores van beide engines zijn gelijk (identificaties identiek,
rem  oppervlakten binnen 1e-6 relatief).
rem
rem  Gebruik:   RunXml2MMD.bat [GEO_ENGINE=geos|dms] [MEM_BUDGET_MB=8000] [PER_FILESET=0|1]
rem    GEO_ENGINE     familie polygoonoperatoren voor het samenvoegen per pand:
rem                   geos (default) of dms; doorgegeven als de
rem                   ConfigSettings/Overridable-instelling GEODMS_Overridable_GEO_ENGINE
rem    MEM_BUDGET_MB  geheugenbudget in MB voor /SB (default 8000)
rem    PER_FILESET=1  de oude werkwijze: een apart GeoDmsRun-proces per fileset,
rem                   voor wie het geheugen hard wil begrenzen op een fileset
rem  Instelbaar via omgevingsvariabelen (met de defaults hieronder):
rem    GEODMS_DIR   map met GeoDmsRun.exe (20.20.0 of later)
rem    XML2MMD_CFG  pad naar BAG20_Xml2MMD.dms
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
echo MEM_BUDGET_MB=%MEM_BUDGET_MB%

if "%GEODMS_DIR%"==""  set GEODMS_DIR=C:\Program Files\ObjectVision\GeoDms20.20.0.m
if "%XML2MMD_CFG%"=="" set XML2MMD_CFG=%BATDIR%..\cfg\BAG20_Xml2MMD.dms
if "%XML2MMD_LOG%"=="" set XML2MMD_LOG=%BATDIR%..\BAG20_Xml2MMD.log

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

rem --- een proces voor alles, met budget -----------------------------------
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /Store/pand/generate_all /Store/vbo/generate_all /Store/ligplaats /Store/standplaats /Store/openbareruimte /Store/woonplaats /Store/nummeraanduiding /Store/overzicht
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT; zie %XML2MMD_LOG%
	exit /b 1
)
echo %DATE% %TIME%  klaar
exit /b 0

rem --- de oude werkwijze: een proces per fileset ------------------------------
rem  nr_stores schrijft '<n>;' naar <StoreDir>/<type>/nr_stores.csv en is
rem  daarmee ook de controle dat de bestandenlijst gelezen kan worden.
:PerFileSetMode
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /Store/pand/nr_stores /Store/vbo/nr_stores
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT bij het bepalen van het aantal filesets; zie %XML2MMD_LOG%
	exit /b 1
)
call :PerFileSet pand
if errorlevel 1 exit /b 1
call :PerFileSet vbo
if errorlevel 1 exit /b 1

rem  LET OP: /Store/nummeraanduiding is een union_unit over ALLE NUM-filesets en
rem  is dus niet per fileset te splitsen.
echo %DATE% %TIME%  overige stores
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /Store/ligplaats /Store/standplaats /Store/openbareruimte /Store/woonplaats /Store/nummeraanduiding /Store/overzicht
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT bij de overige stores; zie %XML2MMD_LOG%
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
"%ProgramPath%" /L"%XML2MMD_LOG%" %Budget% "%XML2MMD_CFG%" /XML/%_type%/PerFileSet/fs_%_i%/%_type%
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
