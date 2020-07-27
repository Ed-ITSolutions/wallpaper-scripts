# Wallpaper Scripts

Powershell Script to generate wallpapers for your network.

Based on @DJ-1701 s original scripts from https://github.com/DJ-1701/GenerateWallpaper.

# Usage

1. Download and save a copy of this repository or just `wallpaper.ps1` to somewhere on your network. e.g. `NETLOGON`.
1. Create an ini file for your wallpaper. _See INI Files below_.
1. (Optional) Use GPP Files to deploy the script, ini files and wallpaper to the local machine e.g. `C:\Wallpaper\wallpaper.ps1`
1. Configure a GPO to run the script with ini at the right time. E.g. a statup script of `C:\Wallpaper\wallpaper.ps1 -ini C:\Wallpaper\boot.ini` and a logon script of `C:\Wallpaper\wallpaper.ps1 -ini C:\Wallpaper\logon.ini`
1. (Optional) If generating a lock screen use a GPO to force a specific lock screen.

## INI Files

To configure the ouputted wallpaper you supply an ini file. The INI File is split into a few sections, `files`, `header` and `footer`.

There are 2 sample files of [boot.ini](./boot.ini) and [logon.ini](./logon.ini) which demo how to create a per-computer lock screen and a per-user wallpaper.

### Files

File paths support 2 variables. `@@` which is replaced with the `PSScriptRoot`, be aware that this variable is not consistent when running as a startup/logon script, and `##` which is replaced with the temp directory.

|Property|Function|
|:-------|:-------|
|inputImage|The path to the base image for the wallpaper.|
|outputImage|The path to save the wallpaper to.|
|applyToUser|If `1` the wallpaper is applied to the active user, best used with an output int he temp directory. If `0` the image is just saved.|

### Header

The header is displayed at the top of the image. There are a few variables that can be replaced in the text:

 - `%user` - The current username.
 - `%computer` - The Computers Hostname.
 - `%time` - The time at generation, time of logon or boot

|Property|Function|
|:-------|:-------|
|text|The Text to display. `#` is replaced with a new line.|
|textSize|The font size in pt to use|
|textRed|The 0-255 colour value to use for the texts red channel|
|textGreen|The 0-255 colour value to use for the texts green channel|
|textBlue|The 0-255 colour value to use for the texts blue channel|
|textAlpha|The 0-255 value to use for the alpha transparency of the text. `0` is transparent and `255` is opaque.|
|boxRed|The 0-255 colour value to use for the boxes red channel|
|boxGreen|The 0-255 colour value to use for the boxes green channel|
|boxBlue|The 0-255 colour value to use for the boxes blue channel|
|boxAlpha|The 0-255 value to use for the alpha transparency of the box. `0` is transparent and `255` is opaque.|
|alignment|`left`, `center` or `right` for alignment on the screen.|

### Footer

Footer is uses a lot of headers values for box and text colour. Variables are the same as in the header.

|Property|Function|
|:-------|:-------|
|text|The Text to display. `#` is replaced with a new line.|
|alignment|`left`, `center` or `right` for alignment on the screen.|
