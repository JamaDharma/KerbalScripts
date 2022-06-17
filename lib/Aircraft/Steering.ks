RUNONCEPATH("0:/lib/Debug").

CLEARVECDRAWS().
SET STEERINGMANAGER:ROLLCONTROLANGLERANGE TO 180.//roll as soon as possible

function NewDirSteeringController {
    parameter aoa is 10.
    parameter bearRoll is 30.
    parameter maxRoll is 45.
    set maxRollK to maxRoll/90.

    local debugDraws is true.

    local drawTarget to VECDRAW(
        V(0,0,0),V(0,0,0),
        RED,"",0.5,debugDraws).
    local adjTarget to VECDRAW(
        V(0,0,0),V(0,0,0),
        YELLOW,"",0.5,debugDraws).
    set drawSteer to VECDRAW(
        V(0,0,0),V(0,0,0),
        WHITE,"",0.5,debugDraws).
    set drawGrade to VECDRAW(
        V(0,0,0),
        { return (SRFPROGRADE:VECTOR)*15. },
        GREEN,"",0.5,debugDraws).

    function SmoothSteering {
        parameter dir.

        local vec is dir:VECTOR. 
        local upV is UP:VECTOR.
        local srfV is SRFPROGRADE:VECTOR.

        local bearingDelta is VANG(VXCL(upV,srfV),VXCL(upV,vec)).
        if bearingDelta < 0.25 
            RETURN dir.
        if bearingDelta > 140
            set vec to (srfV+vec):NORMALIZED.

        local goodV is ANGLEAXIS(MIN(VANG(vec,srfV),aoa), VCRS(srfV,vec))*srfV.
        local topV is (goodV-srfV):NORMALIZED.
        //what bearing delta warrants full roll
        local rollK is MIN(maxRollK, bearingDelta/bearRoll).
        
        if(debugDraws){
            set drawTarget:vec to dir:VECTOR*15.
            set adjTarget:vec to vec*15.
            set drawSteer:vec to goodV*15.
        }

        RETURN LOOKDIRUP(goodV, upV*(1-rollK)+topV*rollK).
    }

    RETURN SmoothSteering@.
}
