RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Orbit").
RUNONCEPATH("0:/lib/Ascend").
RUNONCEPATH("0:/lib/Ship/AscentProfile").
RUNONCEPATH("0:/lib/Search/GoldenSearch").

parameter alt45 is 7000.
function ProgradePitch{
	return VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}
function LongitudeDelta {
	RETURN SHIP:LONGITUDE - TARGET:LONGITUDE.
}
set pitchLock to 0.
//CORE:PART:CONTROLFROM().
 
PRINT "Calculating ascent profile...".
local profile is CalculateAscentProfile(alt45).
PRINT "Profile calculated!".
local pitchControl is MakeProfileControl(profile). 
terminal:input:CLEAR.
PRINT "Press any key to proceed".
WaitKey().

PRINT "Waiting target position...".
WAIT UNTIL LongitudeDelta() > 0.
WAIT UNTIL LongitudeDelta() < 29.
kuniverse:timewarp:CANCELWARP().
WAIT UNTIL SHIP:UNPACKED.
WAIT 1.
WAIT UNTIL LongitudeDelta() < 26.


set thrustLevel to 1.
LOCK STEERING TO HEADING(90, 90 - pitchLock).


STAGE.
WAIT 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

PRINT LongitudeDelta().

UNTIL AIRSPEED > 10 {
	set pitchLock to pitchControl:OutputControl(AIRSPEED).
	WAIT 0.
}
UNTIL pitchControl:StateControl() {
	set pitchLock to pitchControl:OutputControl(AIRSPEED)*2-ProgradePitch().
	WAIT 0.
}

ON (ALTITUDE > alt45) {
	NPrint("Angle from up",pitchLock).
}
UNTIL ALT:APOAPSIS > 80000 {
	set pitchLock to ProgradePitch().
	WAIT 0.
}

set thrustLevel to 0.
LOCK STEERING to SRFPROGRADE.

local bc is StageCalculator().
local bdv is BurnForPeriapsis(71000).
local bt is bc:BurnTime(bdv).
NPrint("Orbit stabilization burn",bdv).
NPrint("Duration",bt).

local function Separation{
	parameter tT.
	RETURN (POSITIONAT(TARGET, tT)-POSITIONAT(SHIP, tT)):MAG.
}

local function MinimalSeparationTime{
	parameter minSepTime.

	GSearch(
		{ return Separation(minSepTime).},
		MakeSearchComponent( 1, 0.1, {parameter dT. set minSepTime to minSepTime + dT.})
	).

	return minSepTime.
}

set thrustLevel to MASS*CONSTANT:g0/AVAILABLETHRUST.
local mst is MinimalSeparationTime(TIME).
local sp is Separation(mst).
local oldSp is sp+1.
UNTIL sp > oldSp {
	set mst to MinimalSeparationTime(mst).
	set oldSp to sp.
	set sp to Separation(mst).
	WAIT 0.
}
set thrustLevel to 0.

WAIT UNTIL ALTITUDE > 69000.

UNLOCK STEERING.
RUN MEETUP.