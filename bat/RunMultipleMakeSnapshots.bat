@echo off
rem ---------------------------------------------------------------------------
rem  Een reeks snapshots uit dezelfde stores van Xml2MMD, een per peildatum.
rem  MakeSnapshot leest de peildatum uit de omgevingsvariabele snapshot_date_env,
rem  die voor Snapshot_Date_Input in de configuratie gaat. Pas de lijst van
rem  peildata onderaan aan, en BAG_Date in cfg\MakeSnapshot.dms.
rem
rem  Instelbaar via omgevingsvariabelen (met de defaults hieronder):
rem    GEODMS_DIR        map met GeoDmsRun.exe (20.23.1 of later)
rem    MAKESNAPSHOT_CFG  pad naar MakeSnapshot.dms
rem    MAKESNAPSHOT_LOG  pad naar het logbestand
rem    SNAPSHOT_ITEM     het snapshot-item; zie de container snapshots in de configuratie
rem ---------------------------------------------------------------------------

setlocal
set "BATDIR=%~dp0"
if "%GEODMS_DIR%"==""       set GEODMS_DIR=C:\Program Files\ObjectVision\GeoDms20.23.1.m
if "%MAKESNAPSHOT_CFG%"=="" set MAKESNAPSHOT_CFG=%BATDIR%..\cfg\MakeSnapshot.dms
if "%MAKESNAPSHOT_LOG%"=="" set MAKESNAPSHOT_LOG=%BATDIR%..\MakeSnapshot.log
if "%SNAPSHOT_ITEM%"==""    set SNAPSHOT_ITEM=/snapshots/nl_status_sel_without_strangevalues_no_height_mmd/MaakVolledigeSnapshot

set ProgramPath=%GEODMS_DIR%\GeoDmsRun.exe
if not exist "%ProgramPath%" (
	echo GeoDmsRun.exe niet gevonden in %GEODMS_DIR%; zet GEODMS_DIR.
	exit /b 2
)

for %%d in (20120101 20130101 20140101 20150101 20160101 20170101 20180101 20190101 20200101 20210101 20220101 20230101 20240101 20250101 20260101) do (
	echo %DATE% %TIME%  peildatum %%d
	set snapshot_date_env=%%d
	"%ProgramPath%" /L"%MAKESNAPSHOT_LOG%" "%MAKESNAPSHOT_CFG%" %SNAPSHOT_ITEM%
	if errorlevel 1 (
		echo %DATE% %TIME%  FOUT bij peildatum %%d; zie %MAKESNAPSHOT_LOG%
		exit /b 1
	)
)
echo %DATE% %TIME%  klaar
