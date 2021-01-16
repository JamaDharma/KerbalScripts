RUNONCEPATH("0:/lib/Debug").



local runwayStart is BODY:GEOPOSITIONLATLNG(-0.0485526802803094,-74.7282838895171).
local runwayEnd is BODY:GEOPOSITIONLATLNG(-0.0502303377342092,-74.4915286545602).

function PrintInfo{
	CLEARSCREEN.
	NPrint("AngToStart", AngToStart()).
	NPrint("DistToStart", DistToStart()).
	NPrint("rollLock", rollLock).
	NPrint("pitchLock", pitchLock).
}

function ProgradePitch{
	return 90-VANG(UP:VECTOR,SRFPROGRADE:VECTOR).
}

function PointPitch{
	parameter pnt.
	return 90-VANG(UP:VECTOR,pnt - ship:POSITION).
}

function DistToStart{
	return (runwayStart:POSITION - ship:POSITION):MAG.
}

function AngToStartOld{
	local rsp is runwayStart:POSITION.
	local rep is runwayEnd:POSITION.
	local rV is rep-rsp.
	local toStart is rsp-ship:POSITION.
	local upV is UP:VECTOR.
	local flatTS is VXCL(upV,toStart):NORMALIZED.
	local flatRW is VXCL(upV,rV):NORMALIZED.
	local angle is VANG(flatTS,flatRW).
	if BODY:NORTH:VECTOR*(flatTS-flatRW) > 0 return angle.
	else return -angle.
}

function AngToStart{
	local rsp is runwayStart:POSITION.
	local rep is runwayEnd:POSITION.
	local rV is rep-rsp.
	local toStart is rsp-ship:POSITION.
	local upV is UP:VECTOR.
	local flatTS is VXCL(upV,toStart):NORMALIZED.
	local flatRW is VXCL(upV,rV):NORMALIZED.
	local angle is VCRS(flatTS,flatRW)*upV.
	return angle*CONSTANT:RadToDeg.
}

function VSpeedControl{
	parameter tgt.
	set pitchLock to (tgt - VERTICALSPEED)/9 - 3.
}

local compasLock is 90.
local pitchLock is 0.
local rollLock is 0.

SAS OFF.
//set STEERINGMANAGER:ROLLPID:KD to 50.
LOCK STEERING TO HEADING(compasLock,pitchLock,rollLock).
SET PID TO PIDLOOP(20, 0, 650, -40, 40).

function SetLocks{
	parameter pl.
	PrintInfo().
	set compasLock to runwayStart:HEADING.
	set pitchLock to pl.
	set rollLock to PID:UPDATE(TIME:SECONDS, -AngToStart()).
}

until DistToStart() < 55000 {
	SetLocks(MIN(0,MAX(-20,ProgradePitch()))).
	WAIT 0.
}

until DistToStart() < 10000 {
	SetLocks(PointPitch(runwayStart:POSITION)).
	WAIT 0.
}

set rollLock to 0.
until DistToStart() < 3000 {
	PrintInfo().
	set compasLock to runwayStart:HEADING.
	set pitchLock to PointPitch(runwayStart:POSITION*2-runwayEnd:POSITION).
	WAIT 0.
}

until DistToStart() < 500 {
	PrintInfo().
	set compasLock to runwayStart:HEADING.
	//set pitchLock to PointPitch(runwayStart:POSITION).
	VSpeedControl(-ALT:RADAR/3).
	if AIRSPEED - 100 > (DistToStart() - 500)/25 BRAKES ON.
	else BRAKES OFF.
	WAIT 0.
}

set compasLock to runwayEnd:HEADING.
BRAKES ON.
GEAR ON.
until ALT:RADAR < 10 {
	PrintInfo().
	VSpeedControl(-ALT:RADAR/10).
	WAIT 0.
}

set pitchLock to 0.
WAIT UNTIL ALT:RADAR < 5.
Nprint("Touchdown", VERTICALSPEED).
WAIT UNTIL AiRSPEED < 10. 
