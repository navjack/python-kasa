I've been working on these scripts to control my lights (KL13US) in my apartment.
I plan to eventually make this universal.

If you can make sense of the comments that I’ve left in the PowerShell scripts and you already
have Python-Kasa installed, then you should be able to modify them to suit your needs.
The RGB to HSV is pretty decent. some colors might not be right but that really depends on the
light itself physically and how the brightness plays with the color perception.

I'm slowly working on making the script more robust, so you don't have to run it multiple times
to change other lights colors.
In the future I’d like to totally decouple the Python-Kasa dependency and also
the PowerShell dependency and make this its own standalone program (old fashioned binary exe for whatever OS you want)
or an easy to run local singular html file with embedded JavaScript or something.
