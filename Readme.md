# Wallpaper Scripts

Powershell Scripts to generate wallpapers for your network.

Based on @DJ-1701 s original scripts from https://github.com/DJ-1701/GenerateWallpaper.

# Usage

Download a copy of this repository and put it somewhere on your network that everyone can read, for example `NETLOGON`.

Ideally these scripts, the config and wallpaper should be copied to the local machine using GPP Files.

Edit `boot.ini` and `logon.ini` to configure the image paths and the text.

Use Group Policy to add a Startup Powershell Script of `boot.ps1` and a logon script of `logon.ps1`