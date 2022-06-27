RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/DebugVector").
RUNONCEPATH("0:/lib/Surface/KerbinPoints").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").
RUNONCEPATH("0:/lib/Aircraft/Steering").
RUNONCEPATH("0:/lib/Math/Rotations").

SAS OFF.
BRAKES OFF.

parameter aoa is 10.
parameter sign is 1.

local function AxisDistanceVec {
    local axis is runwayStart:position-runwayEnd:position.
    RETURN VXCL(UP:VECTOR,VXCL(axis,runwayStart:position)).
}
local function AxisDistance2 {
    local nrm is VCRS(UP:VECTOR,runwayStart:position-runwayEnd:position).
    RETURN nrm*runwayStart:position.
}
local ad is VECDRAW(
        V(0,0,0),
        AxisDistanceVec@,
        BLUE,"",2,true).

local dsc is NewVecSteeringController(aoa,aoa,90,sign).

local axisPID is PIDLOOP(1,0,10,-aoa,aoa).
local tgtGEO is runwayStart.
local steeringLock is dsc(HEADING(tgtGEO:HEADING,0):VECTOR).
LOCK STEERING to steeringLock.
MarkSpot(runwayStart,GREEN).
UNTIL GlobeDistance(tgtGEO,GEOPOSITION)<300 {
    local aVec is  AxisDistanceVec().
    local ang is -axisPID:UPDATE(TIME:SECONDS,aVec:MAG).
    local vec is RotateToBy(HEADING(tgtGEO:HEADING,0):VECTOR,aVec,ang).
    set steeringLock to dsc(vec).
    NPrintMany("dst",aVec:MAG,"spd",aVec:NORMALIZED*VELOCITY:SURFACE,"ang",ang).
    WAIT 0.
}


local runwayMid is BODY:geopositionof((runwayEnd:position+runwayStart:position)/2).
MarkSpot(runwayMid,YELLOW).
UNTIL ALTITUDE < 3000{
    set steeringLock to dsc(runwayMid:POSITION).
}

set tgtGEO to runwayEnd.
MarkSpot(runwayEnd,RED).
UNTIL ALTITUDE < 1300 {
    set steeringLock to dsc(HEADING(tgtGEO:HEADING,0):VECTOR).
}

CHUTES ON.

RUN LandingC.