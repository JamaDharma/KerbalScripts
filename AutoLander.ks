RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/DebugVector").
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

local function GetCircleRotationVector {//reversed
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
local dsc is NewDirSteeringController(aoa,5,60).
LOCK STEERING TO dsc(steerLock).
local decayTime is 5.
UNTIL OnCircleTime()<1 {
    set steerLock to LOOKDIRUP(GetTangentVector(),UP:VECTOR).
    PRINT " Tangent " AT(0,0).
    WAIT 0.
}

//flying in circle till gate
local corrSign is -1.
if UP:VECTOR*GetCircleRotationVector() <  0 
    set corrSign to 1.
local pidK is 1/100.
local circlePID is PIDLOOP(pidK, 0.1*pidK, pidK, -aoa, aoa).
set circlePID:SETPOINT to ecRadius.
local function GetOnCircleVector {
    local dist is GlobeDistance(GEOPOSITION,ecCenter).
    local correction is circlePID:UPDATE(TIME:SECONDS,dist).
    local angledVec is ANGLEAXIS(aoa/2-correction-90,corrSign*UP:VECTOR)*ecCenter:POSITION.
    RETURN VXCL(UP:VECTOR,angledVec).
}
UNTIL GlobeDistance(GEOPOSITION,entryGate)<AIRSPEED*5 {
    set steerLock to LOOKDIRUP(GetOnCircleVector(),UP:VECTOR).
    OnCircleTime().
    PRINT " Circle    " AT(0,0).
    WAIT 0.
}

local entryPID is PIDLOOP(pidK, 0, pidK, -aoa, aoa).
UNTIL GlobeDistance(GEOPOSITION,stripStart)<1000 {
    local stripSteer is HEADING(stripStart:HEADING,0):VECTOR.

    local dist is stripStart:POSITION*GetEntryNormal().
    local correction is -entryPID:UPDATE(TIME:SECONDS,dist).
    PRINT "Distance: "+ROUND(dist)+"                   " AT(0,1).
    local angledVec is ANGLEAXIS(correction,UP:VECTOR)*stripSteer.

    set steerLock to LOOKDIRUP(angledVec,UP:VECTOR).
    PRINT " Approach    " AT(0,0).
    WAIT 0.
}