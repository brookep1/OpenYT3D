@echo off
SETLOCAL ENABLEEXTENSIONS EnableDelayedExpansion
SET VER=0.1

CLS
rem ################ You can edit this stuff with the right directories and files ######
rem It will check params
rem Then it will check current path and these directories for the PLAYER

rem set some defaults that can be overridden
SET NVDIR=%ProgramFiles(x86)%\NVIDIA Corporation\NVIDIA 3D Vision Video Player\
SET PLAYERDIR=%ProgramFiles(x86)%\Stereoscopic Player\
SET PLAYER=StereoPlayer.exe
SET PLAYFLAGS=-il:SideBySideLF -ihw -fp -ol:NVIDIA -url:
SET YTDL=youtube-dl.exe

rem Call the parameter override file if one exists
IF EXIST params.ini (
	for /F "eol=; tokens=1-2 delims==" %%G in (params.ini) DO (
		rem echo %%G %%H
		IF NOT "%%G"=="" ( IF NOT "%%H"=="" (
			SET %%G=%%~H
		))
	)
)

rem Command line parameter definitions override everything
IF /I NOT "!NOTES!"=="SKIP" (
	cls
	ECHO version: %VER%
	echo.
	echo This batch script will help you open a 
	echo Youtube Video in your 3DVision PLAYER
	echo You can find the latest version in GitHub
	echo https://github.com/brookep1/OpenYT3D
	echo ---------------
	echo ---------------
	echo see notes.txt for interesting stuff
	echo ---------------
	echo ---------------
	echo Press CONTROL-C to discontinue
	cls
)

if EXIST !YTDL! (
	rem youtube-dl in local directory
	GOTO FINDPLAYER
)

if EXIST !YTDLDIR!!YTDL! (
	rem youtube-dl in local directory
	SET YTDL=!YTDLDIR!!YTDL!
	GOTO FINDPLAYER
)

echo PROBLEM:  No youtube-dl.exe found
echo see the README for more information
pause
GOTO:EOF


:FINDPLAYER
rem check for existence of %PLAYER%
IF EXIST !PLAYER! (
	rem player in local directory
	GOTO YOUTUBE
)

IF EXIST !NVDIR!!PLAYER! (
	SET PLAYER=!NVDIR!!PLAYER!
	GOTO YOUTUBE
)

IF EXIST !PLAYERDIR!!PLAYER! (
    SET PLAYER=!PLAYERDIR!!PLAYER!
	GOTO YOUTUBE
)

ECHO PROBLEM: No Stereo Player could be found. 
echo see the README for more information
pause
GOTO:EOF

ECHO OpenYT3D Version: %VER%
echo Auto updating youtube-dl extractors
youtube-dl -U

:YOUTUBE
rem CLS
IF NOT "%1"=="" (
	SET INPUT=%1
) ELSE (
	echo.
	echo ------  Command Prompt Options: -----------------
	echo --
	echo -- Type/Paste the YouTube URL or ID 
	echo -- Type "dry" to show the video URL
	echo -- Type "other" for any other supported site URLs
	echo -- Type "test", "test2", or "test3" to use test URLs
	echo -- Type "examples" to show the example test URL info
	echo -- Type "exit" when done watching videos
	echo --
	echo -- Note: 
	echo -- If the player gives a format error, try again. 
	echo    It's usually just a glitch.
	echo -- If you get "library error" click OK. There are zombies
	echo    Use Task Manager to end the leftover stereo.exe procs	
	echo --
	ECHO --------------------------------------------------------------
	echo.
	
	:ASK
	SET /P INPUT="YouTube URL/ID or command -->  " || ECHO "Invalid Entry" && GOTO ASK
	echo.
	if /I "!INPUT!"=="test" (
		SET URL=https://www.youtube.com/v/FpSR2xUc-CI
		SET FORMAT=AUTO
		echo "Using YouTube test URL with default format"
		GOTO FORMATS
	)
	if /I "!INPUT!"=="test2" (
		SET URL=https://vimeo.com/116929521
		SET FMT=
		echo "Formats only supported for YouTube URLs" > ytformats.txt
		echo "Using VIMEO test URL"
		GOTO GET
	)
		if /I "!INPUT!"=="test3" (
		SET URL=http://dai.ly/x2h7385
		SET FMT=
		echo "Formats only supported for YouTube URLs" > ytformats.txt
		echo "Using Daily Motion test URL"
		GOTO GET
	)
	
	if /I "!INPUT!"=="other" (
		echo **Warning: If you use a YouTube URL here it will be formatted wrong**
		echo Refer to youtube-dl docs for full list of supported sites
		SET /P INPUT="Other Video URL -->  " || ECHO "Invalid Entry" && GOTO ASK
		SET URL=!INPUT!
		echo "Formats only supported for YouTube URLs" > ytformats.txt
		SET FMT=
		GOTO GET
	)
	if /I "!INPUT!"=="dry" (
		echo Doing a dry run.
		SET DRY=TRUE
		GOTO ASK
	)
	if /I "!INPUT!"=="examples" (
		echo -- test: YouTube Example by NVidia: 
		echo --   FpSR2xUc-CI or the full url https://www.youtube.com/watch?v=FpSR2xUc-CI
		echo --
		echo -- test2: VIMEO Example has a "link" that is often diffferent from URL bar
		echo --   THIS WORKS: https://vimeo.com/116929521
		echo --   THIS DOES NOT https://vimeo.com/groups/168408/videos/116929521
		echo --        video by Ganja Clause used without prior permission
		echo --
		echo -- test3: Daily Motion Example by Hot Animation - used without permission
		echo --	  http://dai.ly/x2h7385
		echo.
		pause
		cls
		GOTO YOUTUBE
	)
	if /I "!INPUT!"=="exit" GOTO:EOF
	if /I "!INPUT!"=="quit" GOTO:EOF
	)

IF /I NOT "%INPUT:~0,4%"=="http" (
	SET PREFIX=https://www.youtube.com/v/
	SET URL=!PREFIX!!INPUT!
) ELSE (
	SET URL=!INPUT!
)

:FORMATS
rem getting available formats that are not DASH

youtube-dl -F !URL! > ytformats.txt || ECHO Does not appear to be a valid youtube URL or ID && GOTO BAD

rem Don't care what those were just make it go
IF /I "!FORMAT!"=="AUTO" (
	SET FMT=-f best	
	GOTO GET
)

FOR /F %%A IN ('find /v "DASH" ytformats.txt ^| find /c /v "]"') DO set LINES=%%A
rem There are no formats returned. This is probably not a YouTube URL
echo Number of Formats: %LINES%
IF !LINES! LSS 1 (
	FMT= 
	ECHO No Formats Returned.
	GOTO GET
	IF !LINES! LSS 2 (
		SET FMT= 
		ECHO There is only one video resolution available for this video
		GOTO GET 
	)
)

CLS
ECHO URL: !URL!
ECHO. --------------------------------------------------------------
ECHO ENTER ONE OF THE AVAILABLE FORMAT CODES FROM THE FIRST COLUMN
ECHO. --------------------------------------------------------------
ECHO. "(best)" may or may not be true.
ECHO.
TYPE ytformats.txt | find /v "DASH" | find /v "]"

:Pick
SET /P CHOICE="Type the format code -->  " || ECHO Invalid Entry Try Again && GOTO Pick
SET FMT=-f !CHOICE!

rem retrieve the video URL for that format and forward it
ECHO Retrieving direct URL for the video
DEL playurl.txt

:GET
!YTDL! !FMT! -g !URL! > playurl.txt || ECHO. && echo PROBLEM: COULD NOT GET YT VIDEO URL && goto BAD
SET /P VID=<playurl.txt 

if /I "!DRY!"=="TRUE" (
	echo.
	echo -------- Media URL -------------
	echo.
	echo !VID!
	echo.
	echo -------- Formats ---------------
	echo.
	type ytformats.txt
	echo.
	echo ---------------------------------
	SET VID=
	SET CHOICE=
	SET URL=
	SET FMT=
	SET LINES=
	SET INPUT=
	SET DRY=
	pause
	cls
	GOTO YOUTUBE
)

:Play

ECHO.
ECHO.
rem Using !PLAYER! to run !VID!
ECHO Launching Video Player. Enjoy the show!
IF /I NOT "x!PLAYER:Stereo=!"=="x!PLAYER!" (
	rem Stereoplayer.exe has the -url: with no space to the URL
	START /W /I /B "" "!PLAYER!" !PLAYFLAGS!"!VID!" || ECHO. && echo PROBLEM: COULD NOT START PLAYER OR VIDEO && goto BAD
) ELSE (
	START /W /I /B "" "!PLAYER!" !PLAYFLAGS! "!VID!" || ECHO. && echo PROBLEM: COULD NOT START PLAYER OR VIDEO && goto BAD
)

CLS
ECHO ********Ready for Another Video?************
SET VID=
SET CHOICE=
SET URL=
SET FMT=
SET LINES=
SET INPUT=
SET DRY=
GOTO YOUTUBE

:BAD
ECHO.
ECHO. && echo Something went wrong. Ending the script now.
ECHO.
pause
