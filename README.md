#Open Youtube in 3DVision Stereo Video Player
https://github.com/brookep1/OpenYT3D

Latest Release v0.1: https://github.com/brookep1/OpenYT3D/archive/v0.1.zip

This helper batch script can be used to play (streaming) half-SBS formated videos from Youtube, VIMEO, and a few other sites on the standard NVidia 3DVision Player in one step. Paste the standard URL and the script will pop-open the Player and play the URL. Simple as that.

##Features:

- You give it the video URL or ID and streams directly from Youtube, *you don't have to wait to download it first* then play it. 
- The video does not have to be tagged in Youtube as a 3D video first. It will accept and play any Half SBS video that is posted.
- Also supports VIMEO and any other streaming media site that is supported by youtube-dl.exe. 
- No need for an HTML5 browser. No Flash. And no special plugins necessary. It does not use your browser at all. 
- Also no fancy .NET libraries or similar. Fancy GUI's are old school. Simple text screens are the future.

##Limitations / Known Issues:

- You can't play 1080P or higher resolutions that YouTube uses DASH for. The audio and video for DASH are seperate URLs for one. The highest resolution that isn't DASH will be 720p. (After playing a video you can see ytformats.txt for the available formats it had. By default it picks the one that YT marks with "best". That is the marker for highest quality non-DASH format.)
- The stereoplayer.exe spawns a child process that doesn't go away if you close the player window. Use windows task manager to remove lingering stereoplayer.exe processes when you are done watching videos.
- If there are stereoplayer.exe children still, when you run it again it will complain about the library. You can ignore that.

##Requires:

###One of the "stereoplayer.exe" variants. NVidia's or 3DTV.AT

**NVidia 3D Vision Video Player** -- rebranded version of stereoplayer.exe
As of this scripting V1.7.5 is the latest

Download: http://www.nvidia.com/object/3d-vision-video-player-1.7.5-driver.html

**3dtv.at Stereoscopic Player -- trial (5 minute max) or pay**
http://www.3dtv.at/Products/Player/Index_en.aspx

Download: http://www.3dtv.at/Downloads/Index_en.aspx

###rg3's Youtube Downloader -- (youtube-dl.exe)

https://github.com/rg3/youtube-dl

Download Windows .exe: https://yt-dl.org/latest/youtube-dl.exe

**The youtube-dl.exe tool can do more than just YouTube**. Refer to the [supported sites list](https://github.com/rg3/youtube-dl/blob/master/docs/supportedsites.md) in their docs.

###Usage:

1. *Download latest* stable zip file
2. *Unzip it so somewhere* - There is no installer
2. *Download youtube-dl.exe* - See above
2. *Place youtube-dl.exe in the same directory as Openyt3d.bat*
3. *Check params.ini* - You might need to specify the location of your player if it's not in the default install 
4. *Run the batch file* - openyt3d.bat. A simple DOS window will pop open.
5. *Read the Notes*
6. *Paste in the YouTube URL* or other youtube-dl.exe supported URL. In DOS it is Right-Click, Paste. Hit enter.
7. *Watch Movie*
8. *Command window stays open* - you can put in another URL to play

You can create an alias for the batch file and put it on your desktop or somewhere.

**Examples:**

- YouTube Example (by NVidia): FpSR2xUc-CI or the full url https://www.youtube.com/watch?v=FpSR2xUc-CI
- VIMEO Example for "other" (by Ganja Clause):  https://vimeo.com/116929521
- Daily Motion Example (by Hot Animation): http://dai.ly/x2h7385

*examples used without asking permission first* 

###Params Options Include:
- Ability to skip the Notes (off by default)
- Ability to show the available YouTube video formats and select one. (defaults to Automatic)
- Maybe other stuff ... check the file for details

###Likely Problems:
1. Can it find your player? If not set the full path in the params.ini. Include the trailing slash
2. Do you have youtube-dl.exe in the same directory as this batch file?
3. Are you pasting in an actual YouTube URL that includes the video ID? Not the URL of a site with an embedded YT video.
4. Does your player work? Verify your player works with any standard video.
5. Does it stop after 5 minutes? You have the trial version of 3DTV.AT stereoplayer.exe installed and don't have the NVidia player installed. Either license the 3DTV.AT player or install the free NVidia player. There is no difference between the two in regards to what this script needs and does.
6. Does it show up in anaglyph? You have your NVidia setting on "discovery" for the 3D stereo setup
7. Something else? Well it's a batch program. A trivial one at that. Take a look inside for yourself and see if it's an easy fix for you.

###Other Notes:

**To get just the playable media URL you can "dry" run**

1. When it asks for the URL type "dry"
2. In the directory there will be a playurl.txt with that media URL

**Or to use youtube-dl.exe directly**

1. Open a command prompt going to the same directory as youtube-dl.exe. 
    *Tip: Shift-right-click gives the option to open an command prompt in the directory where you clicked in file explorer*
2. Type: **youtube-dl.exe -f best -g some.youtube.URL > url.txt**
3. Open url.txt in notepad. That's the media URL. 

**Got Oculus or other VR?**

Look for VRPLAYER. It suports YouTube URLS directly via VLC integration.

#COPYRIGHT#

The author(s) has released this software and documentation into the Public Domain. You may use it, modify it, redistribute it, etc for any project and any purpose without restriction. Some credit would be a nice courtesy but not specifically required.

See the copyrights for the pre-requisite components for any restrictions on their usage and distribution.

The user is responsible for adhering to any rules and limitations imposed by the media providers (Youtube, VIMEO, etc) and media creators/owners. 
