# Ghost Killer
Atari ST tool to clean the Ghost virus

Code: Cyril Lambin  
Release date: 05/07/1993

I wrote this tool in 1993 to get rid of the infamous Ghost virus that infected nearly all my Atari ST floppy disks.

It very simple to install: put it in an AUTO folder (floppy disk or HDD).  
It will then hook itself on the GEMDOS vector that scans a newly inserted disk and clean the bootsector if the Ghost virus is present (and only in this case).
The screen flashes to red if Ghost is found, and if it's cleaned, a digit sound of Ghost being killed is played.

It replaces the Ghost virus by the "Degas boot loader" bootsector that I also wrote.  
This boot sector loads a BOOT.PI? (PI1/PI3) picture, if present on the root of the floppy disk, at boot time.  
It also checks the 2.5MB infamous "incompatible" RAM configuration on STE. If it detects that 2.5MB are installed by that the TOS incorrectly detected it, it fixes TOS variables and reboots immediately.

## Build

The original source files should build directly under Devpac.  
However I converted them to UTF8 to upload them on Github, so I think it's better if you use a crossdev tool like vasm.
Also you may need to change the path to the external binary files (PCM sound and GHOST binary fingerprint).  
There is no other dependency, just assemble GHSTKILL.S or GHSTKIL2.S :)
