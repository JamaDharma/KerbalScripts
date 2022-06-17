RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Surface/Surface").
RUNONCEPATH("0:/lib/Surface/KerbinPoints").
RUNONCEPATH("0:/lib/Aircraft/Steering").

parameter aoa is 10.

local stripStart is runwayStart.
local stripEnd is runwayEnd.
if runwayStart:DISTANCE > runwayEnd:DISTANCE {
    set stripStart to runwayEnd.
    set stripEnd to runwayStart.
}

local entryGate is GetEntryGatePosition().
local function GetEntryGatePosition {
    local backwardRunwayVector is (stripStart:POSITION-stripEnd:POSITION):NORMALIZED.
    local threeMinFrom is stripStart:POSITION + backwardRunwayVector*AIRSPEED*200.
    RETURN BODY:GEOPOSITIONOF(threeMinFrom).
}

local ecRadius is AIRSPEED*40.
local ecCenter is GetEntryCircleCenterPosition().
set ecRadius to GlobeDistance(entryGate,ecCenter).
local function GetEntryCircleCenterPosition {
    local ecOffcetVector is VCRS(GetUpVec(entryGate),stripStart:POSITION-entryGate:POSITION):NORMALIZED.
    if ecOffcetVector*entryGate:POSITION > 0 set ecOffcetVector to -ecOffcetVector.
    local ecCenterPos is entryGate:POSITION + ecOffcetVector*ecRadius.
    RETURN BODY:GEOPOSITIONOF(ecCenterPos).
}

local function GetCircleRotationVector {
    local entryVec is stripStart:POSITION-entryGate:POSITION.
    local radialVec is ecCenter:POSITION-entryGate:POSITION.
    RETURN VCRS(radialVec,entryVec).
}

local function GetTangentVector {
    local angle is ARCSIN(ecRadius/ecCenter:DISTANCE).
    local directVec is ANGLEAXIS(angle,GetCircleRotationVector())*ecCenter:POSITION.
    RETURN VXCL(UP:VECTOR,directVec).
}

local function GetEntryNormal {
    RETURN VCRS(UP:VECTOR,stripStart:POSITION-entryGate:POSITION):NORMALIZED.
}

local draws is LIST().
local function MarkSpot {
    parameter spot.
    parameter color.
    draws:ADD(VECDRAW(
        {RETURN spot:POSITION.},
        {RETURN GetUpVec(spot)*10000.},
        color,"",2,true)
    ).
}

SAS OFF.
local steer is SRFPROGRADE.
LOCK STEERING TO steer.

CLEARVECDRAWS().

MarkSpot(stripStart,GREEN).
MarkSpot(entryGate,YELLOW).
MarkSpot(ecCenter,RED).

local function OnCircleTime {
    local cDist is GlobeDistance(GEOPOSITION,ecCenter).
    local inSpeed is ecCenter:POSITION:NORMALIZED*VELOCITY:SURFACE.
    PRINT "Distance: "+ROUND(cDist)+" Radius: "+ROUND(ecRadius)+"  " AT(0,1).
    PRINT "Diff: "+ROUND(cDist-ecRadius)+" ETA: "+ROUND((cDist-ecRadius)/inSpeed)+"  " AT(0,2).
    RETURN (cDist-ecRadius)/MAX(0.001,inSpeed).//1000 if negative
}

local function OnEntryTime {
    local entryNormal is GetEntryNormal().
    local cDist is entryNormal*stripStart:POSITION.
    local inSpeed is entryNormal*VELOCITY:SURFACE.
    PRINT "Distance: "+ROUND(cDist)+" ETA: "+ROUND(cDist/inSpeed)+"  " AT(0,1).
    RETURN cDist/inSpeed.//1000 if negative
}

CLEARSCREEN.

//flying to enter circle on tangent
local steerLock is HEADING(stripStart:HEADING,0).
local dsc is NewDirSteeringController(aoa,5).
LOCK STEERING TO dsc(steerLock).
local decayTime is 5.
UNTIL OnCircleTime()<decayTime {
    set steerLock to LOOKDIRUP(GetTangentVector(),UP:VECTOR).
    PRINT " Tangent " AT(0,0).
    WAIT 0.
}

//flying in circle till gate
local function GetOnCircleVector {
    local correction is (OnCircleTime()/decayTime-1)*aoa.
    local horFacing is VXCL(UP:VECTOR,FACING:VECTOR):NORMALIZED.
    local corrAxis is VCRS(horFacing,ecCenter:POSITION).
    local angledVec is ANGLEAXIS(MAX(-aoa,MIN(aoa,correction))-90+aoa,corrAxis)*ecCenter:POSITION.
    RETURN VXCL(UP:VECTOR,angledVec).
}
UNTIL false {
    set steerLock to LOOKDIRUP(GetOnCircleVector(),UP:VECTOR).
    PRINT " Circle    " AT(0,0).
    WAIT 0.
}


local exscessAoA is aoa*2.
set dsc to NewDirSteeringController(exscessAoA).
UNTIL GlobeDistance(GEOPOSITION,stripStart)<100 {
    set steerLock to LOOKDIRUP(GetOnCircleVector(),UP:VECTOR).
    local dst is GlobeDistance(GEOPOSITION,stripStart).
    PRINT "Distance: "+dst+" ETA: "+dst/AIRSPEED AT(4,0).
    WAIT 0.
}