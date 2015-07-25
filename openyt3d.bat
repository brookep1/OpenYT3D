@echo off

SETLOCAL ENABLEEXTENSIONS EnableDelayedExpansion
CLS
rem ################ You can edit this stuff with the right directories and files ######
rem It will check params
rem Then it will check current path and these directories for the PLAYER
SET NVDIR=%ProgramFiles(x86)%\NVIDIA Corporation\NVIDIA 3D Vision Video Player\
SET PLAYERDIR=%ProgramFiles(x86)%\Stereoscopic Player\
SET PLAYER=StereoPlayer.exe

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
	echo ---------------
	echo -- NOTES --    Edit params.ini to skip the notes
	echo ---------------
	type NOTES.txt
	echo.
	echo.
	echo ---------------
	pause 
	cls
)

if NOT EXIST youtube-dl.exe (
	echo.
	echo Missing Dependencies
	echo see the README for more information
	pause
	GOTO EOF
)

rem check for existence of %PLAYER%
IF EXIST !PLAYER! (
	rem player in local directory
	GOTO YOUTUBE
)

IF EXIST %NVDIR%!PLAYER! (
	SET PLAYER=!%NVDIR%!PLAYER!!
	GOTO YOUTUBE
)

IF EXIST %PLAYERDIR%!PLAYER! (
    SET PLAYER=%PLAYERDIR%!PLAYER!
	GOTO YOUTUBE
)
ECHO PROBLEM: No Stereo Player could be found. 
GOTO BAD

:YOUTUBE
rem CLS
IF NOT "%1"=="" (
	SET INPUT=%1
) ELSE (
	ECHO --------------------------------------------------------------
	echo COPY The YouTube URL without any trailing items after the ID
	echo or COPY just the 11 character ID
	ECHO --------------------------------------------------------------
	echo.
	ECHO --------------------------------------------------------------
	echo Example -- this is the old NVidia video
	echo https://www.youtube.com/watch?v=FpSR2xUc-CI
	echo type "test" (no quotes^) to use it for a test
	ECHO --------------------------------------------------------------
	echo.
	:ASK
	SET /P INPUT="TYPE OR PASTE THE YOUTUBE OR URL -->  " || ECHO "Invalid Entry" && GOTO ASK
	echo.
	if /I "!INPUT!"=="test" (
		SET INPUT=FpSR2xUc-CI
		SET CHOICE=best
	)
	if /I "!INPUT!"=="test2" (
		SET INPUT=FpSR2xUc-CI
		SET CHOICE=85
	)
)

SET PREFIX=https://www.youtube.com/v/
SET ID=%INPUT:~-11% 
ECHO The YouTube ID is %ID%
SET URL=%PREFIX%%ID%

rem getting available formats that are not only audio or video (DASH)

IF /I "!FORMAT!"=="AUTO" (
	SET CHOICE=best
	GOTO GET
)

pause
CLS
ECHO Video ID: %ID%
ECHO. --------------------------------------------------------------
ECHO ENTER ONE OF THESE AVAILABLE FORMAT CODES FROM THE FIRST COLUMN
ECHO NOTE:The "(best)" tagged format might not be highest resolution
ECHO. --------------------------------------------------------------
ECHO. If the video does not play retry with a different format code
ECHO.
youtube-dl -F %URL%  > ytformats.txt || ECHO Does not appear to be a valid youtube URL or ID && GOTO BAD
TYPE ytformats.txt | find /v "DASH" | find /v "]"

:Pick
SET /P CHOICE="Type the format code -->  " || ECHO Invalid Entry Try Again && GOTO Pick

rem retrieve the video URL for that format and forward it
ECHO Retrieving direct URL for the video
DEL playurl.txt

:GET
youtube-dl -f !CHOICE! -g %URL% > playurl.txt || ECHO COULD NOT GET YT URL && goto BAD
SET /P VID=<playurl.txt 

:Play
rem Set flags to automatically go to parallel HalfSBS for input and 3DVision for output

SET FlAGS=-il:SideBySideLF -ihw -fp -ol:NVIDIA
ECHO.
ECHO.
rem Using !PLAYER! to run !VID!
CLS
START /W /I /B "" "!PLAYER!" %FLAGS% -url:"%VID%" || ECHO COULD NOT START PLAYER OR VIDEO && goto BAD
ECHO.
SET VID=""
SET CHOICE=""
SET URL=""
SET INPUT=""
GOTO YOUTUBE

:BAD
ECHO.
ECHO Something went wrong. Check for fixable batch issues from the console.
ECHO.
pause

:EOF