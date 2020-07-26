[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $ini = $PSScriptRoot + "\boot.ini"
)


$lib = $PSScriptRoot + "\lib.psm1"

Import-Module $lib

$config = Read-IniFile -file $ini

$inputImage = Resolve-FilePath -filePath $config.files.inputImage
$outputImage = Resolve-FilePath -filePath $config.files.outputImage

$header = Resolve-Text -text $config.header.text
$footer = Resolve-Text -text $config.footer.text

Write-Wallpaper $inputImage $outputImage $header $footer $config