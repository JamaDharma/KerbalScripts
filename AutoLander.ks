RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Surface/KerbinPoints").

parameter aoa is 10.

function SmoothSteering {
    parameter dir.

    local vec is dir:VECTOR. 
    local upV is UP:VECTOR.
    local srfV is SRFPROGRADE:VECTOR.

    local bearingDelta is VANG(VXCL(upV,srfV),VXCL(upV,vec)).
    //NPrint("bearDelta",bearingDelta).
    if bearingDelta < 0.25 
        RETURN dir.

    local goodV is ANGLEAXIS(MIN(VANG(vec,srfV),aoa), VCRS(srfV,vec))*srfV.
    local topV is (goodV-srfV):NORMALIZED.
    //what bearing delta warrants full roll
    local upK is MAX(0, 1-bearingDelta/20).
    //NPrint("upK",upK).

    RETURN LOOKDIRUP(goodV, upV*upK+topV*(1-upK)).
}

SAS OFF.
local steer is SRFPROGRADE.
LOCK STEERING TO steer.

CLEARVECDRAWS().
set drawTarget to VECDRAW(
    V(0,0,0),
    { return (HEADING(runwayStart:HEADING,0):VECTOR)*15. },
    RED,"",0.5,true).
set drawSteer to VECDRAW(
    V(0,0,0),
    { return (steer:VECTOR)*15. },
    GREEN,"",0.5,true).
set drawGrade to VECDRAW(
    V(0,0,0),
    { return (SRFPROGRADE:VECTOR)*15. },
    WHITE,"",0.5,true).


UNTIL false {
    set steer to SmoothSteering(HEADING(runwayStart:HEADING,0)). 
}