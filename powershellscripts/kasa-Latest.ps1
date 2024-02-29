# this is the start of the command to change settings on the kasa smart bulbs by communicating with the host IP address of the device
$commandstart = 'kasa --host '

# this is the always used part of the command that sets the device type to bulb
$typebulb = '--type bulb '

$transitioncmd = ' --transition '

$transitiontime = '0 '

# this is the variable that sets the brightness of the bulb to 100% by default
$brightness = '100 '

# set variable for the host IP address of the "RGB Bedroom" bulb type device and call it $bedroomip
$bedroomip = '192.168.2.7 '

# set variable for the host IP address of the "rgb living room" bulb type device and call it $livingroomip
$livingroomip = '192.168.2.8 '

# set variable for the host IP address of the "lampshade" bulb type device and call it $lampshadeip
$lampshadeip = '192.168.2.6 '

# ask the user which bulb they would like to change the color of. 1 for "RGB Bedroom", 2 for "rgb living room", 3 for "lampshade"
$bulb = Read-Host 'Which bulb would you like to change the color of? 1 for RGB Bedroom, 2 for rgb living room, 3 for lampshade'

# if the user enters 1 then set the variable called $bulbip to the $bedroomip variable. if the user enters 2 then set the variable called $bulbip to the $livingroomip variable. if the user enters 3 then set the variable called $bulbip to the $lampshadeip variable.
if ($bulb -eq 1)
{
    $bulbip = $bedroomip
}
elseif ($bulb -eq 2)
{
    $bulbip = $livingroomip
}
elseif ($bulb -eq 3)
{
    $bulbip = $lampshadeip
}

# ask the user for space separated RGB values they would like to set the bulb to
$rgb = Read-Host 'Enter RGB values separated by spaces'

# ask the user if they would like to set the brightness of the bulb. 1 for yes, 2 for no. if the user enters 1 then ask them for the brightness value they would like to set the bulb to. if the user enters 2 then set the brightness variable to 100.
$brightnessquestion = Read-Host 'Would you like to set the brightness of the bulb? 1 for yes, 2 for no.'
if ($brightnessquestion -eq 1)
{
    $brightness = Read-Host 'Enter a brightness value between 0 and 100'
    # if there isn't a space at the end of the brightness value then add one
    if ($brightness.Substring($brightness.Length - 1) -ne ' ')
    {
        $brightness = $brightness + ' '
    }
}
elseif ($brightnessquestion -eq 2)
{
    $brightness = '100 '
}

# split the space seperated RGB values into individual variables
$red, $green, $blue = $rgb.Split(' ')
# write host the RGB values to see what they look like
Write-Host "RGB values: $($red) $($green) $($blue)"

# divide $red, $green, and $blue by 255 and 
$red = [float]($red / 255)
$green = [float]($green / 255)
$blue = [float]($blue / 255)
# write host the RGB values to see what they look like
Write-Host "RGB values: $($red) $($green) $($blue)"

# Find the minimum and maximum RGB values using the Measure-Object cmdlet
$cmin = ($red, $green, $blue | Measure-Object -Minimum).Minimum
$cmax = ($red, $green, $blue | Measure-Object -Maximum).Maximum

# If $cmin is NaN or empty then make it 0, and if $cmax is NaN or empty then make it 1
if (-not $cmin -or $cmin -ne $cmin)
{
    $cmin = 0
}
if (-not $cmax -or $cmax -ne $cmax)
{
    $cmax = 1
}

# Write the values of $cmin and $cmax to the console
Write-Host "cmin: $($cmin)"
Write-Host "cmax: $($cmax)"

# calculate the delta between $cmax and $cmin
$delta = $cmax - $cmin
# write host $delta to see what it looks like
Write-Host "delta: $($delta)"

# calculate the hue
if ($delta -eq 0)
{
    $hue = 0
}
elseif ($cmax -eq $red)
{
    $hue = 60 * ((($green - $blue) / $delta) % 6)
}
elseif ($cmax -eq $green)
{
    $hue = 60 * ((($blue - $red) / $delta) + 2)
}
elseif ($cmax -eq $blue)
{
    $hue = 60 * ((($red - $green) / $delta) + 4)
}
# if $hue is NaN or empty then make it 0
if ($null -eq $hue -or $hue -ne $hue)
{
    $hue = 0
}
# write host $hue to see what it looks like
Write-Host "hue: $($hue)"

# calculate the saturation
if ($cmax -eq 0)
{
    $saturation = 0
}
else
{
    $saturation = $delta / $cmax
}
# if the RGB values are all 1 then make the saturation 0
if ($red -eq 1 -and $green -eq 1 -and $blue -eq 1)
{
    $saturation = 0
}
# if all the RGB values are the same then make the saturation 0
if ($red -eq $green -and $red -eq $blue)
{
    $saturation = 0
}
# write host $saturation to see what it looks like
Write-Host "saturation: $($saturation)"

# calculate the value and if it is NaN then make it 0 and also limit its max value to 1 if it is greater than 1
if ($cmax -eq 0)
{
    $value = 0
}
else
{
    $value = $cmax
    if ($value -gt 1)
    {
        $value = 1
    }
}
# write host $value to see what it looks like
Write-Host "value: $($value)"

# use rounding on the hue value to make sure it is an integer
$hue = [math]::Round($hue)
# write host $hue to see what it looks like
Write-Host "hue: $($hue)"

# convert hue to a positive value if it is negative and limit the max value to 360 if it is greater than 360
if ($hue -lt 0)
{
    $hue = $hue + 360
}
if ($hue -gt 360)
{
    $hue = 360
}
# write host $hue to see what it looks like
Write-Host "hue: $($hue)"

# convert saturation value to percentage
$saturation = [math]::Round($saturation * 100)
# write host $saturation to see what it looks like
Write-Host "saturation: $($saturation)"

# convert value to percentage
$value = [math]::Round($value * 100)
# write host $value to see what it looks like
Write-Host "value: $($value)"
# if $brightnessquestion is 1 then set $value to $brightness
if ($brightnessquestion -eq 1)
{
    $value = $brightness
}
# if $brightnessquestion is 2 then set $value to 100
elseif ($brightnessquestion -eq 2)
{
    $value = 100
}

# output the HSV values
Write-Host "HSV values: $($hue) $($saturation) $($value)"

# set the variable called $hsvcmd for the command to change the color of the light which starts with "hsv " followed by the hue, saturation, and value variables
$hsvcmd = "hsv $($hue) $($saturation) $($value)"

# put variables together to form the command to change the color of the selected bulb
$bulbcolorchangecmd = $commandstart + $bulbip + $typebulb + $hsvcmd

# write host $bulbcolorchangecmd to see what the command looks like
Write-Host $bulbcolorchangecmd

# run $bulbcolorchangecmd in the macos zsh shell
Invoke-Expression -Command $bulbcolorchangecmd

# ask the user if they would like to manually change the color of any of the three bulbs. 1 for yes, 2 for no. if the user enters 1 then ask them which bulb they would like to change the color of. if the user enters 2 then move on to the next question.

$manualcolorchange = Read-Host 'Would you like to manually change the color of any of the three bulbs? 1 for yes, 2 for no.'

if ($manualcolorchange -eq 1)
{
    $bulb = Read-Host 'Which bulb would you like to change the color of? 1 for RGB Bedroom, 2 for rgb living room, 3 for lampshade'
    if ($bulb -eq 1)
    {
        $bulbip = $bedroomip
    }
    elseif ($bulb -eq 2)
    {
        $bulbip = $livingroomip
    }
    elseif ($bulb -eq 3)
    {
        $bulbip = $lampshadeip
    }
    $rgb = Read-Host 'Enter RGB values separated by spaces'
    $brightnessquestion = Read-Host 'Would you like to set the brightness of the bulb? 1 for yes, 2 for no.'
    if ($brightnessquestion -eq 1)
    {
        $brightness = Read-Host 'Enter a brightness value between 0 and 100'
        if ($brightness.Substring($brightness.Length - 1) -ne ' ')
        {
            $brightness = $brightness + ' '
        }
    }
    elseif ($brightnessquestion -eq 2)
    {
        $brightness = '100 '
    }
    $red, $green, $blue = $rgb.Split(' ')
    Write-Host "RGB values: $($red) $($green) $($blue)"
    $red = [float]($red / 255)
    $green = [float]($green / 255)
    $blue = [float]($blue / 255)
    Write-Host "RGB values: $($red) $($green) $($blue)"
    $cmin = ($red, $green, $blue | Measure-Object -Minimum).Minimum
    $cmax = ($red, $green, $blue | Measure-Object -Maximum).Maximum
    if (-not $cmin -or $cmin -ne $cmin)
    {
        $cmin = 0
    }
    if (-not $cmax -or $cmax -ne $cmax)
    {
        $cmax = 1
    }
    Write-Host "cmin: $($cmin)"
    Write-Host "cmax: $($cmax)"
    $delta = $cmax - $cmin
    Write-Host "delta: $($delta)"
    if ($delta -eq 0)
    {
        $hue = 0
    }
    elseif ($cmax -eq $red)
    {
        $hue = 60 * ((($green - $blue) / $delta) % 6)
    }
    elseif ($cmax -eq $green)
    {
        $hue = 60 * ((($blue - $red) / $delta) + 2)
    }
    elseif ($cmax -eq $blue)
    {
        $hue = 60 * ((($red - $green) / $delta) + 4)
    }
    if ($null -eq $hue -or $hue -ne $hue)
    {
        $hue = 0
    }
    Write-Host "hue: $($hue)"
    if ($cmax -eq 0)
    {
        $saturation = 0
    }
    else
    {
        $saturation = $delta / $cmax
    }
    if ($red -eq 1 -and $green -eq 1 -and $blue -eq 1)
    {
        $saturation = 0
    }
    if ($red -eq $green -and $red -eq $blue)
    {
        $saturation = 0
    }
    Write-Host "saturation: $($saturation)"
    if ($cmax -eq 0)
    {
        $value = 0
    }
    else
    {
        $value = $cmax
        if ($value -gt 1)
        {
            $value = 1
        }
    }
    Write-Host "value: $($value)"
    $hue = [math]::Round($hue)
    Write-Host "hue: $($hue)"
    if ($hue -lt 0)
    {
        $hue = $hue + 360
    }
    if ($hue -gt 360)
    {
        $hue = 360
    }
    Write-Host "hue: $($hue)"
    $saturation = [math]::Round($saturation * 100)
    Write-Host "saturation: $($saturation)"
    $value = [math]::Round($value * 100)
    Write-Host "value: $($value)"
    if ($brightnessquestion -eq 1)
    {
        $value = $brightness
    }
    elseif ($brightnessquestion -eq 2)
    {
        $value = 100
    }
    Write-Host "HSV values: $($hue) $($saturation) $($value)"
    $hsvcmd = "hsv $($hue) $($saturation) $($value)"
    $bulbcolorchangecmd = $commandstart + $bulbip + $typebulb + $hsvcmd
    Write-Host $bulbcolorchangecmd
    Invoke-Expression -Command $bulbcolorchangecmd
}

# ask the user if they would like to change the color of another bulb. 1 for yes, 2 for no.
$changeanotherbulb = Read-Host 'Would you like to change the color of another bulb? 1 for yes, 2 for no.'

# if the user enters 1 then ask them which bulb they would like to change the color of. if the user enters 2 then move on to the next question.
if ($changeanotherbulb -eq 1)
{
    $bulb = Read-Host 'Which bulb would you like to change the color of? 1 for RGB Bedroom, 2 for rgb living room, 3 for lampshade'
    if ($bulb -eq 1)
    {
        $bulbip = $bedroomip
    }
    elseif ($bulb -eq 2)
    {
        $bulbip = $livingroomip
    }
    elseif ($bulb -eq 3)
    {
        $bulbip = $lampshadeip
    }
    $rgb = Read-Host 'Enter RGB values separated by spaces'
    $brightnessquestion = Read-Host 'Would you like to set the brightness of the bulb? 1 for yes, 2 for no.'
    if ($brightnessquestion -eq 1)
    {
        $brightness = Read-Host 'Enter a brightness value between 0 and 100'
        if ($brightness.Substring($brightness.Length - 1) -ne ' ')
        {
            $brightness = $brightness + ' '
        }
    }
    elseif ($brightnessquestion -eq 2)
    {
        $brightness = '100 '
    }
    $red, $green, $blue = $rgb.Split(' ')
    Write-Host "RGB values: $($red) $($green) $($blue)"
    $red = [float]($red / 255)
    $green = [float]($green / 255)
    $blue = [float]($blue / 255)
    Write-Host "RGB values: $($red) $($green) $($blue)"
    $cmin = ($red, $green, $blue | Measure-Object -Minimum).Minimum
    $cmax = ($red, $green, $blue | Measure-Object -Maximum).Maximum
    if (-not $cmin -or $cmin -ne $cmin)
    {
        $cmin = 0
    }
    if (-not $cmax -or $cmax -ne $cmax)
    {
        $cmax = 1
    }
    Write-Host "cmin: $($cmin)"
    Write-Host "cmax: $($cmax)"
    $delta = $cmax - $cmin
    Write-Host "delta: $($delta)"
    if ($delta -eq
        0)
    {
        $hue = 0
    }
    elseif ($cmax -eq $red)
    {
        $hue = 60 * ((($green - $blue) / $delta) % 6)
    }
    elseif ($cmax -eq $green)
    {
        $hue = 60 * ((($blue - $red) / $delta) + 2)
    }
    elseif ($cmax -eq $blue)
    {
        $hue = 60 * ((($red - $green) / $delta) + 4)
    }
    if ($null -eq $hue -or $hue -ne $hue)
    {
        $hue = 0
    }
    Write-Host "hue: $($hue)"
    if ($cmax -eq 0)
    {
        $saturation = 0
    }
    else
    {
        $saturation = $delta / $cmax
    }
    if ($red -eq 1 -and $green -eq 1 -and $blue -eq 1)
    {
        $saturation = 0
    }
    if ($red -eq $green -and $red -eq $blue)
    {
        $saturation = 0
    }
    Write-Host "saturation: $($saturation)"
    if ($cmax -eq 0)
    {
        $value = 0
    }
    else
    {
        $value = $cmax
        if ($value -gt 1)
        {
            $value = 1
        }
    }
    Write-Host "value: $($value)"
    $hue = [math]::Round($hue)
    Write-Host "hue: $($hue)"
    if ($hue -lt 0)
    {
        $hue = $hue + 360
    }
    if ($hue -gt 360)
    {
        $hue = 360
    }
    Write-Host "hue: $($hue)"
    $saturation = [math]::Round($saturation * 100)
    Write-Host "saturation: $($saturation)"
    $value = [math]::Round($value * 100)
    Write-Host "value: $($value)"
    if ($brightnessquestion -eq 1)
    {
        $value = $brightness
    }
    elseif ($brightnessquestion -eq 2)
    {
        $value = 100
    }
    Write-Host "HSV values: $($hue) $($saturation) $($value)"
    $hsvcmd = "hsv $($hue) $($saturation) $($value)"
    $bulbcolorchangecmd = $commandstart + $bulbip + $typebulb + $hsvcmd
    Write-Host $bulbcolorchangecmd
    Invoke-Expression -Command $bulbcolorchangecmd
}

# ask the user if they want party mode. 1 for all bulbs, 2 for single bulb, 3 for no party mode.
$partymode = Read-Host 'Would you like party mode? 1 for all bulbs, 2 for single bulb, 3 for no party mode.'

if ($partymode -eq 1)
{
    $hueIncrement = 2
    $saturation = 100
    $value = 100
    while ($true)
    {
        $hue = ($hue + $hueIncrement) % 360
        $hsvcmd = "hsv $($hue) $($saturation) $($value)"
        
        # Change color for all bulbs
        $bulbcolorchangecmd = $commandstart + $livingroomip + $typebulb + $hsvcmd + $transitioncmd + $transitiontime
        Invoke-Expression -Command $bulbcolorchangecmd
        
        $bulbcolorchangecmd = $commandstart + $lampshadeip + $typebulb + $hsvcmd + $transitioncmd + $transitiontime
        Invoke-Expression -Command $bulbcolorchangecmd
        
        $bulbcolorchangecmd = $commandstart + $bedroomip + $typebulb + $hsvcmd + $transitioncmd + $transitiontime
        Invoke-Expression -Command $bulbcolorchangecmd
        
        Start-Sleep -Milliseconds 100
    }
}
elseif ($partymode -eq 2)
{
    $bulb = Read-Host 'Which bulb would you like to activate party mode? 1 for living room, 2 for lampshade, 3 for bedroom.'
    $hueIncrement = 2
    $saturation = 100
    $value = 25
    
    if ($bulb -eq 1)
    {
        $bulbip = $livingroomip
    }
    elseif ($bulb -eq 2)
    {
        $bulbip = $lampshadeip
    }
    elseif ($bulb -eq 3)
    {
        $bulbip = $bedroomip
    }
    
    while ($true)
    {
        $hue = ($hue + $hueIncrement) % 360
        $hsvcmd = "hsv $($hue) $($saturation) $($value)"
        
        # Change color for the selected bulb
        $bulbcolorchangecmd = $commandstart + $bulbip + $typebulb + $hsvcmd + $transitioncmd + $transitiontime
        Invoke-Expression -Command $bulbcolorchangecmd
        
        Start-Sleep -Milliseconds 16
    }
}
elseif ($partymode -eq 3)
{
    Write-Host "Ok, I won't do party mode."
}
