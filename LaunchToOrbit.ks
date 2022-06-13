RUNONCEPATH("0:/lib/Debug").
//warps and launches to specific orbit

parameter incl is TARGET:OBT:INCLINATION.
parameter ascLng is TARGET:OBT:LONGITUDEOFASCENDINGNODE.
local dscLng is ascLng-180.


NPrintMany("ascLng",ascLng,"dscLng",dscLng,"incl",incl).


//for equatorial launch
local currLng is VANG(UP:VECTOR,SOLARPRIMEVECTOR).
if BODY:ANGULARVEL*VCRS(UP:VECTOR,SOLARPRIMEVECTOR) > 0 
	set currLng to 360-currLng.
if MAX(ascLng,dscLng) < currLng 
	set currLng to currLng-360.

local inclSign is 1.
local lngDelta is 0.
if ascLng < currLng or (dscLng < ascLng and dscLng > currLng) {
	set inclSign to -1.
	set lngDelta to dscLng-currLng.
} else {
	set lngDelta to ascLng-currLng.
}

local lngETA is lngDelta/360*BODY:ROTATIONPERIOD.

NPrintMany("currLng",currLng,"lngDelta",lngDelta,"lngETA",lngETA/60).

WARPTO(time:SECONDS+lngETA).

run GravityTurn(7,75,inclSign*incl,"stage1").







