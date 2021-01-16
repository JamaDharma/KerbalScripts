RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Unwieldy.").



global runwayStart is BODY:GEOPOSITIONLATLNG(-0.0485526802803094,-74.7282838895171).
global runwayEnd is BODY:GEOPOSITIONLATLNG(-0.0502303377342092,-74.4915286545602).
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

function PointPitch{
	parameter pnt.
	return 90-VANG(UP:VECTOR,pnt - ship:POSITION).
}
function DistToPad{
	return (pad:POSITION - ship:POSITION):MAG.
}

function PadPlus{
	parameter plus is 0.5.
	local padV is pad:POSITION - ship:POSITION.
	local plusV is VXCL(UP:VECTOR, padV).
	
	return padV + plusV*plus.
}


local stl is PadPlus().
	
set drawRollSteer to VECDRAW(
	V(0,0,0),
	{ return stl. },
	RED,"",3,true).
		
SAS OFF.


LOCK STEERING TO HEADING(pad:HEADING, 180).

until DistToPad() < 25000 {
	set stl to PadPlus().
	WAIT 0.
}

LOCK STEERING TO -stl.

until ALT:RADAR < 5000 {
	set stl to PadPlus().
	WAIT 0.
}

until ALT:RADAR < 1000 {
	set stl to PadPlus(0.2).
	WAIT 0.
}

CHUTES ON.

WAIT UNTIL ALT:RADAR < 200.

run LandingA.

