@echo off
SETLOCAL ENABLEEXTENSIONS EnableDelayedExpansion
SET VER=0.1

rem Left Todo
rem file reorganize - depends for binary depot and temp for created files
rem command line parameter passing
rem player specific command line flag parameters
rem Tasklist and Taskkill
rem Powershell clipboard output helper
rem clip2stereoplayer batch shortcut
rem openyt3d-stereoplayer shorthand
rem media2clip shorthand
rem openyt3d-bino shorthand
rem clip2bino batch shortcut
rem playlist parser

CLS
rem ################ You can edit this stuff with the right directories and files ######
rem It will check params
rem Then it will check current path and these directories for the PLAYER
SET NVDIR=%ProgramFiles(x86)%\NVIDIA Corporation\NVIDIA 3D Vision Video Player\
SET PLAYERDIR=%ProgramFiles(x86)%\Stereoscopic Player\
SET YTDLDIR=%ProgramFiles(x86)%\youtube-dl\
SET PLAYER=StereoPlayer.exe
SET YTDL=youtube-dl.exe

rem Call the parameter override file if one exists
IF EXIST params.ini (
	for /F "eol=; tokens=1-2 delims==" %%G in (params.ini) DO (
		rem echo %%G %%H
		IF NOT %%G=="" ( IF NOT %%H=="" (
			SET %%G=%%~H
		))
	)
)	

IF /I NOT "!NOTES!"=="SKIP" (
	cls
	echo HELLO TO YOU! 
	echo.
	echo This batch script will help you open a Youtube Video in your 3DVision PLAYER
	echo You can find the latest version in GitHub here -- https://github.com/brookep1/OpenYT3D
	echo.
	echo ---------------
	echo -- NOTES --    Edit the params.ini to permanently skip this
	echo ---------------
	type NOTES.txt
	echo.
	echo.
	echo ---------------
	echo Press CONTROL-C to discontinue
	pause 
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
GOTO EOF


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
GOTO EOF

:YOUTUBE
rem CLS
IF NOT "%1"=="" (
	SET INPUT=%1
) ELSE (
	ECHO version: %VER%
	ECHO -------------------------------------------------------------
	echo COPY The YouTube URL without any trailing items after the ID
	echo -- or COPY just the 11 character ID
	ECHO --------------------------------------------------------------
	echo.
	ECHO --------------------------------------------------------------
	echo -- Example: FpSR2xUc-CI or https://www.youtube.com/watch?v=FpSR2xUc-CI
	echo -- for YouTube URLs it must end with the video ID
	echo.
	echo -- Type "other" for other youtube-dl supported site URLs
	echo --    VIMEO for example. Refer to youtube-dl docs for full list.
	echo -- Type "playlist" to pick from your playlist.txt file
	echo -- Type "dry" to show the video URL
	echo -- Type "exit" to end the script
	ECHO --------------------------------------------------------------
	echo.
	:ASK
	SET /P INPUT="YouTube URL or ID -->  " || ECHO "Invalid Entry" && GOTO ASK
	echo.
	if /I "!INPUT!"=="test" (
		SET URL=https://www.youtube.com/v/FpSR2xUc-CI
		GOTO GET
	)
	if /I "!INPUT!"=="other" (
		SET /P INPUT="Other Video URL -->  " || ECHO "Invalid Entry" && GOTO ASK
		SET URL=!INPUT!
		GOTO GET
	)
	if /I "!INPUT!"=="dry" (
		echo Doing a dry run.
		SET /P INPUT="Other Video URL -->  " || ECHO "Invalid Entry" && GOTO ASK
		echo -------- Media URL -------------
		youtube-dl -g !INPUT!
		echo -------- Formats ---------------
		youtube-dl -F !INPUT!
		echo ---------------------------------
		SET URL=!INPUT!
		pause
		GOTO YOUTUBE
	)

)

IF /I !INPUT:~1-4! == "http" (
) ELSE (
	SET PREFIX=https://www.youtube.com/v/
	SET URL=!PREFIX!!ID!
)

rem Don't care just make it go
IF /I "!FORMAT!"=="AUTO" DO (
	GOTO GET
)

rem getting available formats that are not DASH
youtube-dl -F !URL!  > ytformats.txt || ECHO Does not appear to be a valid youtube URL or ID && GOTO BAD
FOR %%A IN (ytformats.txt) DO set size=%%~zA

rem There are no formats returned. This is probably not a YouTube URL
IF NOT %%A GTR 1 DO (
	FMT=""
	ECHO There is only one video resolution available for this video
	GOTO GET 
)

CLS
ECHO Video ID: !ID!
ECHO. --------------------------------------------------------------
ECHO ENTER ONE OF THE AVAILABLE FORMAT CODES FROM THE FIRST COLUMN
ECHO. --------------------------------------------------------------
ECHO. "(best)" may or may not be true.
ECHO.
TYPE ytformats.txt | find /v "DASH" | find /v "]"

:Pick
SET /P CHOICE="Type the format code -->  " || ECHO Invalid Entry Try Again && GOTO Pick
FMT="-f "!CHOICE!

rem retrieve the video URL for that format and forward it
ECHO Retrieving direct URL for the video
DEL playurl.txt

:GET
!YTDL!!FMT! -g !URL! > playurl.txt || ECHO. && echo PROBLEM: COULD NOT GET YT VIDEO URL && goto BAD
SET /P VID=<playurl.txt 

:Play
rem Set flags to automatically go to parallel HalfSBS for input and 3DVision for output

SET FlAGS=-il:SideBySideLF -ihw -fp -ol:NVIDIA
ECHO.
ECHO.
rem Using !PLAYER! to run !VID!
ECHO Launching Video Player. Enjoy the show!
START /W /I /B "" "!PLAYER!" %FLAGS% -url:"!VID!" || ECHO. && echo PROBLEM: COULD NOT START PLAYER OR VIDEO && goto BAD
pause
CLS
ECHO.
SET VID=""
SET CHOICE=""
SET URL=""
SET INPUT=""
GOTO YOUTUBE

:BAD
ECHO.
ECHO. && echo Something went wrong. Ending the script now.
ECHO.
pause

:EOF