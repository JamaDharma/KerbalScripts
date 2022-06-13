RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Orbit").
RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Math/LaunchAzimuth").
RUNONCEPATH("0:/lib/Math/StringToNum").
RUNONCEPATH("0:/lib/Ship/Staging").
RUNONCEPATH("0:/lib/Ship/AscentProfile").

//altitude at wich desired pitch is 45 degrees, km
parameter alt45 is 7.
set alt45 to alt45*1000.
//desired apoapsis, km
parameter apoap is 75.
set apoap to apoap*1000.
//desired inclination
parameter incl is 0.
//stageN to enable staging N times
parameter stg is "noStaging".

local azimuth is {RETURN 90.}.
if incl <> 0 set azimuth to NewLaunchAzimuthCalculator(incl).

PRINT "Apoapsis height is "+apoap+" and launch azimuth is "+azimuth().
PRINT stg.

function ProgradePitch{
	return VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}
set pitchLock to 0.

if(CORE:PART:HASMODULE("ModuleCommand")) CORE:PART:CONTROLFROM().

PRINT "Calculating ascent profile...".
PRINT "Goal is 45 at "+alt45.
local profile is CalculateAscentProfile(alt45).
PRINT "Profile calculated!".
local pitchControl is MakeProfileControl(profile). 
Terminal:input:CLEAR.
PRINT "Press any key to proceed".
WaitKey().

set thrustLevel to 1.
LOCK steering TO HEADING(azimuth(), 90 - pitchLock).

STAGE.

if stg:STARTSWITH("stage") {
	local stageNum is str_to_num(stg:REMOVE(0,5)).
	StagingTriggerController(stageNum).
}

UNTIL AIRSPEED > 5 {
	set pitchLock to pitchControl:OutputControl(AIRSPEED).
	WAIT 0.
}
local mlt is 1/20.
UNTIL pitchControl:StateControl() {
	local as is AIRSPEED.
	local oc is pitchControl:OutputControl(as).
	local ptch is ProgradePitch().
	
	set pitchLock to MAX(0.5,oc+mlt*as*(oc-ptch)).
	PRINT " Desired: "+round(oc, 3)+"  Current: "+round(ptch, 3)+" Lock: "+round(pitchLock, 3)+"    " at  (0,0).
	WAIT 0.
}

ON (ALTITUDE > alt45) {
	NPrint("Angle from up",pitchLock).
}
UNTIL ALT:APOAPSIS > apoap {
	set pitchLock to ProgradePitch().
	WAIT 0.
}

set thrustLevel to 0.
UNLOCK steering.


local bdv is BurnForPeriapsis(71000).

NPrint("Orbit stabilization burn",bdv).

WAIT UNTIL ALTITUDE > 70000.
LOCK steering to PROGRADE.

local bc is StageCalculator().
local bt is bc:BurnTime(bdv).
UNTIL ALT:PERIAPSIS > 70500 {
	//start at 2/3, max at 1/2
	if ETA:APOAPSIS > ETA:PERIAPSIS set thrustLevel to 1.
		else set thrustLevel to 4 - 6*ETA:APOAPSIS/bt.
	set bt to  bc:BurnTime(BurnForPeriapsis(72000))+5.
	WAIT 0.
}