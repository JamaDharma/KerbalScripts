function SimpleAzimuthCalculator {
    parameter incl.
    parameter lat.
    if incl > 0	RETURN ARCSIN(COS(incl)/COS(lat)).
    if incl < 0 RETURN 180-ARCSIN(COS(incl)/COS(lat)).
    RETURN 0.
}

function NewLaunchAzimuthCalculator {
    parameter incl.//negative means descending node
    local sign is CHOOSE 1 IF incl > 0 ELSE -1.
    //horizontal component of my orbital speed 
    //by the time ascent burn is finished
    //lower value for precision, rise for efficiency
    parameter obtSpeed is 1800.
    
    function CalculateCurrentAzimuth {

        local nrthV is NORTH:VECTOR.//cosA direction
        local eastV is VCRS(UP:VECTOR,nrthV).//sinA direction
        
        local currV is VELOCITY:ORBIT.
        local curr2d is V(nrthV*currV,eastV*currV,0).

        local sinA is COS(incl)/COS(GEOPOSITION:lat).
        local cosA is sign*SQRT(1-sinA^2).
        local obt2d is V(cosA,sinA,0)*MAX(obtSpeed,curr2d:MAG+100).

        local burn2d is obt2d-curr2d.

        local azimuth is ARCTAN2(burn2d:y,burn2d:x).

        RETURN azimuth. 
    }

    RETURN CalculateCurrentAzimuth@.

}