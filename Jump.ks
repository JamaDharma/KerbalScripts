switch to 0.
RUNONCEPATH("0:/lib/Defaults").

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.
GEAR ON.
BRAKES ON.

function Compas {
	parameter trgtV is SRFPROGRADE:VECTOR.
	local upV is UP:VECTOR.
	local northV is NORTH:VECTOR.
	
	local compasV is trgtV - VDOT(trgtV, upV)*upV.
	return VANG(northV, compasV).
}

function TunedHeading {
	If GROUNDSPEED < 5 {
		return TARGET:HEADING.
	}
	return 2*TARGET:HEADING - Compas().
}

function OrbSpeed {
    set velOrb to ship:Velocity:orbit.
    set velVert to ship:verticalSpeed * ship:up:vector.
    return (velOrb - velVert):mag.
}

function AngleSeparation {
	set shpS to SHIP:ALTITUDE + BODY:RADIUS.
	set tgtS to TARGET:ALTITUDE + BODY:RADIUS.
	set dst to TARGET:DISTANCE.
	return ARCCOS((shpS*shpS + tgtS*tgtS - dst*dst)/2/shpS/tgtS).
}

function TargetDistance {
	return 2*constant:PI*BODY:RADIUS*AngleSeparation()/360.
}

function Travel {
	local altDiff is SHIP:ALTITUDE - TARGET:ALTITUDE.
	local grvAdj is grv - OrbSpeed^2/BODY:RADIUS.
	local fall is VERTICALSPEED^2 + 2*grvAdj*altDiff.
	IF fall <= 0 { return 0. } 
	return GROUNDSPEED*(VERTICALSPEED + SQRT(fall))/grvAdj.
}

set rdsq to BODY:RADIUS^2.
set grv to BODY:MU/rdsq.
set angle to (180 - AngleSeparation())/4.

print angle.
print TargetDistance().



LOCK  STEERING TO HEADING(TARGET:HEADING, angle).
WAIT 5.

set thrustLevel to 1.
UNTIL Travel() > TargetDistance() {
	WAIT 0.
}

set thrustLevel to 0.