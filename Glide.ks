RUNONCEPATH("0:/lib/Surface/KerbinPoints").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").

CLEARVECDRAWS().
SAS OFF.
BRAKES OFF.

parameter aoa is 10.
local pitchOffset is 90+aoa.

local runwayMid is BODY:geopositionof((runwayEnd:position+runwayStart:position)/2).
local tgtPos is VXCL((runwayEnd:position-runwayStart:position),runwayStart:position).
local tgtGEO is BODY:geopositionof(tgtPos).
set tgtGEO to runwayStart.

function GlideDir {
    RETURN HEADING(tgtGEO:HEADING,MIN(90,pitchOffset-VANG(UP:VECTOR,SRFPROGRADE:VECTOR))).
}

set tgtGEO to runwayStart.
LOCK STEERING to GlideDir().
UNTIL false {
    local dst is GlobeDistance(tgtGEO,GEOPOSITION).
    //PRINT dst.
    if dst < 300 BREAK.
}

LOCK STEERING to runwayMid:POSITION.
WAIT UNTIL ALTITUDE < 3000.

LOCK STEERING to GlideDir().
set tgtGEO to runwayEnd.
WAIT UNTIL ALTITUDE < 1300.

CHUTES ON.

RUN LandingC.