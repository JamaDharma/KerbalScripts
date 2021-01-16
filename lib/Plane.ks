global runwayStart is BODY:GEOPOSITIONLATLNG(-0.0485526802803094,-74.7282838895171).
global runwayEnd is BODY:GEOPOSITIONLATLNG(-0.0502303377342092,-74.4915286545602).
global pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

function AoALimiter{
	parameter tp.
	
	local limit is SonicLimit().
	local cp is VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	
	if tp > cp { 
		return MIN(tp, cp+limit).
	}
	return MAX(tp, cp-limit).
}

function RetractGearTrigger{
	WHEN ALT:RADAR > 10 THEN {
		GEAR OFF.
	}
}