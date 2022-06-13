RUNONCEPATH("0:/lib/Debug").
//RUNONCEPATH("0:/lib/Rover/WaypointNavigation").
local file is "/boot/bootlisten.ks".
local s is PROCESSOR("Slave1").
s:DEACTIVATE().
set s:BOOTFILENAME to file.
s:ACTIVATE().
set s to PROCESSOR("Slave2").
s:DEACTIVATE().
set s:BOOTFILENAME to file.
s:ACTIVATE().