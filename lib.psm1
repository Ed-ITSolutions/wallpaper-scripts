# Copied from https://www.reddit.com/r/PowerShell/comments/3s8a2n/parse_an_ini_or_similar_file_and_store_the/
function Read-IniFile{
  [CmdletBinding()]
  param(
      [Parameter(Position=0)]
      [String] $file
  )

  [string]   $comment = ";"
  [string]   $header  = "^\s*(?!$($comment))\s*\[\s*(.*[^\s*])\s*]\s*$"
  [string]   $item    = "^\s*(?!$($comment))\s*([^=]*)\s*=\s*(.*)\s*$"
  [hashtable]$ini     = @{}
  Switch -Regex -File $file {
      "$($header)" { $section = ($matches[1] -replace ' ','_'); $ini[$section.Trim()] = @{} }
      "$($item)"   { $name, $value = $matches[1..2]; If (($name -ne $null) -and ($section -ne $null)) { $ini[$section][$name.Trim()] = $value.Trim() } }
  }
  Return $ini
}

function Resolve-FilePath{
  [CmdletBinding()]
  param(
      [Parameter(Position=0)]
      [String] $filePath
  )

  $root = $filePath -replace '@@', $PSScriptRoot
  $temp = $root -replace '##', $env:temp

  Return $temp -replace '"',''
}

function Get-ScreenResolution{
  $asString = (Get-WmiObject -Class Win32_VideoController).VideoModeDescription

  $splits = $asString -split " x "

  $resolution = New-Object -TypeName psobject
  $resolution | Add-Member -MemberType NoteProperty -Name Width -Value ($splits[0] -as [int])
  $resolution | Add-Member -MemberType NoteProperty -Name Height -Value ($splits[1] -as [int])
  
  Return $resolution
}

function Resolve-Text{
  [CmdletBinding()]
  param(
      [Parameter(Position=0)]
      [String] $text
  )

  $lines = $text -replace "#", "`r`n"
  $user = $lines -replace "%user", $env:USERNAME
  $computer = $user -replace "%computer", $env:COMPUTERNAME
  $time = $computer -replace "%time", ((Get-Date).DateTime)

  Return $time
}

function Write-Wallpaper{
  [CmdletBinding()]
  param(
      [Parameter(Position=0)]
      [String] $inputImage,
      [Parameter(Position=1)]
      [String] $outputImage,
      [Parameter(Position=2)]
      [String] $header,
      [Parameter(Position=3)]
      [String] $footer,
      [Parameter(Position=4)] $config
  )

  $screenResolution = Get-ScreenResolution


Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  using Microsoft.Win32;

  namespace Wallpaper
  {
      public class UpdateImage
      {
          [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      
          private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);

          public static void Refresh(string path) 
          {
              SystemParametersInfo( 20, 0, path, 0x01 | 0x02 ); 
          }
      }
  }
"@

  Add-Type -AssemblyName System.Drawing

  $sourceImage = [System.Drawing.Image]::FromFile($inputImage)

  $bitmap = New-Object System.Drawing.Bitmap($screenResolution.Width, $screenResolution.Height)
  $image = [System.Drawing.Graphics]::FromImage($bitmap)
  $image.Clear([System.Drawing.Color]::FromArgb(255,255,255,255))

  $rectangle = [System.Drawing.RectangleF]::FromLTRB(0, 0, $screenResolution.Width, $screenResolution.Height)

  $image.DrawImage($sourceImage, 0, 0, $screenResolution.Width, $screenResolution.Height)

  Write-Text $image $header $config $false $config.header.alignment $rectangle
  Write-Text $image $footer $config $true $config.footer.alignment $rectangle

  # Save edited bitmap to file.
  $bitmap.Save($outputImage, [System.Drawing.Imaging.ImageFormat]::Jpeg)

  # Clean up and remove objects.
  $sourceImage.Dispose()
  $bitmap.Dispose()
  $image.Dispose()
}

function Write-Text{
  [CmdletBinding()]
  param(
      [Parameter(Position=0)] $image,
      [Parameter(Position=1)]
      [String] $text,
      [Parameter(Position=2)] $config,
      [Parameter(Position=3)] $footer,
      [Parameter(Position=4)] $alignment,
      [Parameter(Position=5)] $rectangle
  )

  $screenResolution = Get-ScreenResolution

  $textSizePixels=$config.header.textSize/0.75
  $font = New-Object System.Drawing.Font("Arial", $textSizePixels, [Drawing.FontStyle]'Bold', "Pixel")

  $textARGB = [System.Drawing.Color]::FromArgb($config.header.textAlpha, $config.header.textRed, $config.header.textGreen, $config.header.textBlue)
  $boxARGB = [System.Drawing.Color]::FromArgb($config.header.boxAlpha, $config.header.boxRed, $config.header.boxGreen, $config.header.boxBlue)

  $formatFont = [System.Drawing.StringFormat]::GenericDefault
  
  # Default to left
  $formatFont.Alignment = [System.Drawing.StringAlignment]::Far

  if($alignment -eq 'center'){
    $formatFont.Alignment = [System.Drawing.StringAlignment]::Center
  }
  
  if($alignment -eq 'left'){
    $formatFont.Alignment = [System.Drawing.StringAlignment]::Near
  }

  $formatFont.LineAlignment = [System.Drawing.StringAlignment]::Near

  if($footer -eq $true){
    $formatFont.LineAlignment = [System.Drawing.StringAlignment]::Far
  }

  $textPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  $textPath.AddString($text, $font.FontFamily, $font.Style, $font.Size, $rectangle, $formatFont)

  $startX = $screenResolution.Width
  $startY = $screenResolution.Height
  $endX = 0
  $endY = 0
  ForEach ($pathPointRow in $textPath.PathPoints)
  {
      If ($pathPointRow.X -le $startX){$startX = $pathPointRow.X}
      If ($pathPointRow.Y -le $startY){$startY = $pathPointRow.Y}
      If ($pathPointRow.X -gt $endX){$endX = $pathPointRow.X}
      If ($pathPointRow.Y -gt $endY){$endY = $pathPointRow.Y}
  }
  $endX = $endX - $startX + 5
  $endY = $endY - $startY + 10
  $startY = $startY - 5
  $startX = $startX

  $boxBrushColour = New-Object Drawing.SolidBrush $boxARGB
  $textBrushColour = New-Object Drawing.SolidBrush $textARGB

  $image.FillRectangle($boxBrushColour, $startX, $startY, $endX, $endY)
  $image.DrawString($text, $font, $textBrushColour, $rectangle, $formatFont)
}