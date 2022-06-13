RUNONCEPATH("0:/lib/Surface/KerbinPoints").
RUNONCEPATH("0:/lib/Surface/SurfaceAt").

CLEARVECDRAWS().
SAS OFF.
BRAKES OFF.

parameter aoa is 10.
local pitchOffset is 90+aoa.

local tgtPos is VXCL((runwayEnd:position-runwayStart:position),runwayStart:position).
local tgtGEO is BODY:geopositionof(tgtPos).
set tgtGEO to runwayStart.

function GlideDir {
    RETURN HEADING(tgtGEO:HEADING,MIN(90,pitchOffset-VANG(UP:VECTOR,SRFPROGRADE:VECTOR))).
}

LOCK STEERING to -GlideDir():VECTOR.

WAIT UNTIL GlobeDistance(tgtGEO,GEOPOSITION) < 300.

set tgtGEO to runwayEnd.
WAIT UNTIL false.