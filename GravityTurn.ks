RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Orbit").
RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Ship/AscentProfile").
parameter alt45 is 7000.
function ProgradePitch{
	return VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}

set pitchLock to 0.
CORE:PART:CONTROLFROM().
 
PRINT "Calculating ascent profile...".
local profile is CalculateAscentProfile(alt45).
PRINT "Profile calculated!".
local pitchControl is MakeProfileControl(profile). 
PRINT "Press any key to proceed".
WaitKey().

set thrustLevel to 1.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

STAGE.

UNTIL pitchControl:StateControl() {
	set pitchLock to pitchControl:OutputControl(AIRSPEED).
	WAIT 0.
}
ON (ALTITUDE > alt45) {
	NPrint("Angle from up",pitchLock).
}
ON (STAGE:LIQUIDFUEL < 1) {
	set thrustLevel to 0.
	PRINT "Engines off.".
}
UNTIL ALT:APOAPSIS > 75000 {
	set pitchLock to ProgradePitch().
	WAIT 0.
}

set thrustLevel to 0.
UNLOCK STEERING.
SAS ON.
WAIT 0.5.
set SASMODE to "PROGRADE".

local bc is StageCalculator().
local bdv is BurnForPeriapsis(71000).
local bt is bc:BurnTime(bdv).
NPrint("Orbit stabilization burn",bdv).
UNTIL ALT:PERIAPSIS > 70500 {
	//start at 2/3, max at 1/2
	set thrustLevel to 4 - 6*ETA:APOAPSIS/bt.
	set bt to  bc:BurnTime(BurnForPeriapsis(72000))+5.
	WAIT 0.
}