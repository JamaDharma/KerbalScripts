RUNONCEPATH("0:/lib/Ascend").

set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

{//Clever thrust setter and smart gimball
	local mmtList is ship:PARTSTAGGEDPATTERN("^M").
	local rhnList is ship:PARTSTAGGED("R").
	local whdList is ship:PARTSTAGGED("W").
	local tM is ship:PARTSTAGGED("MT").
	local mM is ship:PARTSTAGGED("M").
	local bM is ship:PARTSTAGGED("MB").
	
	function GetThrust{
		parameter engineList.
		return engineList[0]:MAXTHRUST*engineList:LENGTH.
	}
	
	function SetLimit{
		parameter engineList, tl.
		
		for eng in engineList {
			set eng:THRUSTLIMIT to tl*100.
		}
	}
	
	function SmartGiimball {
		parameter gimballStrength, throttleStrength.
		
		set gimballStrength to MAX(0, gimballStrength).
		set throttleStrength to MAX(0, throttleStrength).

		local trtAdj is MAX(0,MIN(1-gimballStrength, throttleStrength-gimballStrength/2)).
		
		SetLimit(tM,trtAdj+gimballStrength).
		SetLimit(bM,trtAdj).
	}
	
	global function SetThrottleClever {
		parameter gimballStrength, throttleStrength.
		
		local targetThrust is MAXTHRUST*throttleStrength.
		local mmtThrust is GetThrust(mmtList).
		local rhnThrust is GetThrust(rhnList).
		local whdThrust is GetThrust(whdList).
		local otherThrust is MAXTHRUST - mmtThrust - rhnThrust - whdThrust.
		if mmtThrust > 0{
			local mLimit is (targetThrust-whdThrust-rhnThrust-otherThrust)/mmtThrust.
			
			if gimballStrength > 0.001 {
				SetLimit(mM,mLimit).
				SmartGiimball(gimballStrength, mLimit).
			} else {
				SetLimit(mmtList,mLimit).
			}
		}
		if rhnThrust > 0{
			SetLimit(rhnList,(targetThrust-whdThrust-otherThrust)/rhnThrust).
		}		
		if whdThrust > 0{
			//SetLimit(whdList,(targetThrust-otherThrust)/whdThrust).
		}
	}
}

function DownPitch{
	local currP is VANG(UP:VECTOR, SHIP:FACING:VECTOR).
	if currP < pitchLock { 
		return (pitchLock-currP)/2.
	} else {
		return 0.
	}
}

WHEN SHIP:ALTITUDE > 9000 THEN {
	STAGE.
}

function FancyControl {
	WHEN ALT:APOAPSIS < 80000 THEN {
		
		local apoT is (80 - ETA:APOAPSIS)*0.1.
		SetThrottleClever(DownPitch(), apoT).
		return ALT:APOAPSIS < 80000.
	}
}
WHEN SHIP:AIRSPEED > 100 THEN {
	FancyControl().
} 

function SonicLimit{
	if AIRSPEED > 300 { return 1. }
	return 10 - 9*AIRSPEED/300.
}
function AoALimiter{
	parameter tp.
	
	local limit is SonicLimit().
	local cp is VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	
	if tp > cp { 
		return MIN(tp, cp+limit).
	}
	return MAX(tp, cp-limit).
}
function PitchSetter{
	parameter newPitch.
	set pitchLock to AoALimiter(newPitch).
}

set thrustLevel to 1.
WAIT 0.5.
STAGE.

AscendByProfile( 90000, PitchSetter@, 
list( 0,   558,810,1441,2397,3341,4322,5388,6541,7849,9327,11121), 
list( 1,	 2,4,5,10,15,20,25,30,35,40,45)).

UNTIL (SHIP:APOAPSIS > 90000) {
	set pitchLock to VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	WAIT 0.
}
set thrustLevel to 0.
WAIT 0.1.
SetThrottleClever(0,1).

SAS ON.
WAIT 0.5.
SET SASMODE to "PROGRADE".
WAIT 0.5.