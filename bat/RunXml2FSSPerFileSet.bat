@echo off
rem ---------------------------------------------------------------------------
rem  BAG 2.0 XML > FSS, maar met een eigen GeoDmsRun-proces per fileset.
rem
rem  Werkomweg voor ObjectVision/GeoDMS#1259: zolang een aanvrager belang houdt
rem  op de store-items van meerdere filesets tegelijk, blijven de bronnen van
rem  ELKE fileset in het geheugen staan (de ingelezen XML-tekst en het
rem  parse_xml-resultaat), ook nadat de .mmd al geschreven is. Het geheugen
rem  groeit dan mee met het totale extract in plaats van met een fileset.
rem  Een apart proces per fileset laat het belang bij het proceseinde los,
rem  waarna de piek gelijk is aan die van de grootste enkele fileset.
rem
rem  Gemeten met deze configuratie op een synthetische PND-set van 10 filesets
rem  (1,7 GB XML, 169 MB per fileset): een proces voor alle filesets piekt op
rem  3809 MB, een los proces per fileset op 651 MB. De piek per fileset is
rem  ongeveer 3,1x de XML van die fileset en groeit niet mee met het aantal.
rem
rem  Gebruik:   RunXml2FSSPerFileSet.bat
rem  Instelbaar via omgevingsvariabelen (met de defaults hieronder):
rem    GEODMS_DIR   map met GeoDmsRun.exe
rem    XML2FSS_CFG  pad naar BAG20_Xml2FSS.dms
rem    XML2FSS_LOG  pad naar het logbestand
rem ---------------------------------------------------------------------------

setlocal enabledelayedexpansion

if "%GEODMS_DIR%"==""  set GEODMS_DIR=C:\Program Files\ObjectVision\GeoDms20.19.3.m
if "%XML2FSS_CFG%"=="" set XML2FSS_CFG=%~dp0..\cfg\BAG20_Xml2FSS.dms
if "%XML2FSS_LOG%"=="" set XML2FSS_LOG=%~dp0..\BAG20_Xml2FSS.log

set ProgramPath=%GEODMS_DIR%\GeoDmsRun.exe

if not exist "%ProgramPath%" (
	echo GeoDmsRun.exe niet gevonden in %GEODMS_DIR%; zet GEODMS_DIR.
	exit /b 2
)
if not exist "%XML2FSS_CFG%" (
	echo Configuratie niet gevonden: %XML2FSS_CFG%; zet XML2FSS_CFG.
	exit /b 2
)

echo %DATE% %TIME%  start

rem --- 1. de stores zonder filesets, plus het aantal filesets per objecttype ---
rem  nr_stores schrijft '<n>;' naar <StoreDir>/<type>/nr_stores.csv en is
rem  daarmee ook de controle dat de bestandenlijst gelezen kan worden.
"%ProgramPath%" /L"%XML2FSS_LOG%" "%XML2FSS_CFG%" /Store/pand/nr_stores /Store/vbo/nr_stores
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT bij het bepalen van het aantal filesets; zie %XML2FSS_LOG%
	exit /b 1
)

rem --- 2. per fileset een eigen proces, tot de fileset niet meer bestaat -------
call :PerFileSet pand
if errorlevel 1 exit /b 1
call :PerFileSet vbo
if errorlevel 1 exit /b 1

rem --- 3. de overige stores ---------------------------------------------------
rem  LET OP: /Store/nummeraanduiding is een union_unit over ALLE NUM-filesets en
rem  is dus niet per fileset te splitsen; die houdt zijn filesets wel samen in
rem  het geheugen. Voor NUM is dat tot nu toe geen probleem gebleken.
echo %DATE% %TIME%  overige stores
"%ProgramPath%" /L"%XML2FSS_LOG%" "%XML2FSS_CFG%" /Store/ligplaats /Store/standplaats /Store/openbareruimte /Store/woonplaats /Store/nummeraanduiding /Store/overzicht
if errorlevel 1 (
	echo %DATE% %TIME%  FOUT bij de overige stores; zie %XML2FSS_LOG%
	exit /b 1
)

echo %DATE% %TIME%  klaar
exit /b 0

rem ---------------------------------------------------------------------------
rem  :PerFileSet <objecttype>
rem  Draait fs_1, fs_2, ... elk in een eigen proces en stopt zodra GeoDmsRun het
rem  item niet meer vindt. Dat is meteen de fileset-telling: een niet bestaande
rem  fs_N geeft 'item not found' en ErrorLevel 1. Een echte rekenfout geeft
rem  hetzelfde ErrorLevel, dus het log is leidend bij een vroegtijdige stop.
rem ---------------------------------------------------------------------------
:PerFileSet
set _type=%~1
set _i=0
:PerFileSetLoop
set /a _i+=1
"%ProgramPath%" /L"%XML2FSS_LOG%" "%XML2FSS_CFG%" /XML/%_type%/PerFileSet/fs_%_i%/%_type%
if errorlevel 1 goto :PerFileSetDone
echo %DATE% %TIME%  %_type% fileset %_i% geschreven
goto :PerFileSetLoop

:PerFileSetDone
set /a _i-=1
if %_i%==0 (
	echo %DATE% %TIME%  FOUT: geen enkele %_type%-fileset verwerkt; zie %XML2FSS_LOG%
	exit /b 1
)
echo %DATE% %TIME%  %_type%: %_i% filesets verwerkt
exit /b 0
