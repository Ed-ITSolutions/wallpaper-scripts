[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $ini = $PSScriptRoot + "\logon.ini"
)


$lib = $PSScriptRoot + "\lib.psm1"

Import-Module $lib

$config = Read-IniFile -file $ini

$inputImage = Resolve-FilePath -filePath $config.files.inputImage
$outputImage = Resolve-FilePath -filePath $config.files.outputImage

$header = Resolve-Text -text $config.header.text
$footer = Resolve-Text -text $config.footer.text

Write-Wallpaper $inputImage $outputImage $header $footer $config

Remove-Item -Path "$($env:APPDATA)\Microsoft\Windows\Themes\*" -Recurse -Force -ErrorAction SilentlyContinue

# Ensure image is set to Stretch to screen resolution and not tile.
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value "2" -Force
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value "0" -Force

[Wallpaper.UpdateImage]::Refresh($DestinationFile)