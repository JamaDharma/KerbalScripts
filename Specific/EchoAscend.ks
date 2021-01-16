WAIT 2.
switch to 0.

RUNONCEPATH("Engines").
RUNONCEPATH("Ascend").
RUNONCEPATH("Orbit").

set STEERINGMANAGER:MAXSTOPPINGTIME to 50.
set STEERINGMANAGER:PITCHPID:KD to 0.1.
set STEERINGMANAGER:YAWPID:KD to 0.1.
set STEERINGMANAGER:PITCHTS to 15.
set STEERINGMANAGER:YAWTS to 15.

set thrustLevel to 1.
set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).
//150 15 40 - 84
//150 20 40 - 43
//150 15 35 - 97
//130 15 35 - 98
//100 15 35 - 67
//140 15 35 - 99

function ProgradeOrPitch{
	parameter maxPitch is 70.
	local vAngle is VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	return MIN(maxPitch, vAngle).
}

function AscendByProfile{
	parameter trgtApoapsis is 80000.
	local altList is list( 0,	108,179,487,1368,2435,4558,7014,9969):ITERATOR.
	local angList is list(0,		1,2,5,10,15,25,35,45):ITERATOR.
	altList:NEXT.
	angList:NEXT.
	SteerTo(trgtApoapsis, altList, angList).
}

function SteerTo{
	parameter trgtApoapsis.
	parameter startAltPointer.
	parameter startAnglePointer.
	
	local startAlt is startAltPointer:VALUE.
	local startAngle is startAnglePointer:VALUE.
	
	if ((not startAltPointer:NEXT) or (not startAnglePointer:NEXT)) { return. }
	
	local targetAlt is startAltPointer:VALUE.
	local targetAngle is startAnglePointer:VALUE.
	
	PRINT "Target altitude " + targetAlt.
	PRINT "Target angle " + targetAngle.
	until (SHIP:ALTITUDE > targetAlt or ALT:APOAPSIS > trgtApoapsis)
	{
		set pitchLock to startAngle + (SHIP:ALTITUDE - startAlt)/(targetAlt - startAlt)*(targetAngle - startAngle).
		WAIT 0.1.
	}
	PRINT targetAlt + " passed".
	SteerTo(trgtApoapsis, startAltPointer, startAnglePointer).
}

local apo is 80000.
WAIT 1.
STAGE.
WAIT 0.1.

local mammothes is GimbaledEngines(ListActiveEngines()).

function SetThrustLevel{
	parameter lvl.
	SET thrustLevel TO lvl.
	local lmt is 100.//(10*thrustLevel+0.1).
	FOR eng IN mammothes {
		SET eng:GIMBAL:LIMIT TO lmt.
	}.
}


ON (VELOCITY:SURFACE:MAG > 140 ) {
	SetThrustLevel(0.1).
}

//Ascend
AscendByProfile(apo).

LOCK STEERING TO HEADING(90, 90 - ProgradeOrPitch(75)).

ON (STAGE:SOLIDFUEL = 0 ) {
	SetThrustLevel(1).
	STAGE.
	WAIT 0.5.
	ON (STAGE:LIQUIDFUEL = 0 ) {
		STAGE.
	}
}

WAIT UNTIL APOAPSIS > 35000.

RiseFromAtmosphere(75000).

STAGE.

StabilizeOrbit().