<h1 align="center">This is just a complete fork of...</h1>

<h2 align="center">python-kasa</h2>

<p align="center">
  <a href="https://github.com/python-kasa/python-kasa/blob/master/README.md">And you can read their GitHub's Readme right here!</a>
</p>

<p align="center">
  The only thing I'm contributing to this are some things i wanted to do for my own use. I wanted a way to control my Kasa RGB bulbs and while you can do that with this Python library I wanted to interface with it in a different way. So, I wrote a quick and dirty PowerShell script that made it easier for me to call the Python library in VSCode on my Mac. 
</p>

```PowerShell
# put variables together to form the command to change the color of the selected bulb
$bulbcolorchangecmd = $commandstart + $bulbip + $typebulb + $hsvcmd

# write host $bulbcolorchangecmd to see what the command looks like
Write-Host $bulbcolorchangecmd

# run $bulbcolorchangecmd in the macos zsh shell
Invoke-Expression -Command $bulbcolorchangecmd
```
<p align="center">
  Simple stuff like this let me bypass what shell VSCode would open. Just going straight to ZSH which has Python-Kasa running happily in it instead of having to wonder if it is the Brew version, or one of the other...
</p>

<p align="center">
  <img width="606" alt="Screenshot 2024-02-28 at 10 22 57 PM" src="https://github.com/navjack/python-kasa/assets/7362750/d037f254-c867-4949-a8a9-9755c842e95a">
</p>

<p align="center">
  many many other python installs doesn't matter now.
</p>

<p align="center">
  I hope to get all of the functionality i want essentially prototyped in PowerShell by invoking the Python library and then taking all that into its own self-contained thing in Go or Rust or something that can easily spit out binaries that can run on my PC and my Mac.
</p>

<p align="center">
  <a href="https://github.com/navjack/python-kasa/tree/master/powershellscripts">The things I'm working on live in here</a>
</p>
