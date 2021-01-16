RUNONCEPATH("0:/lib/Ascend").

local spd is 300.
//FreeControlLock().

set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).

function twr{
	return MAXTHRUST/MASS/10.
}

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
		return (pitchLock-currP)/5.
	} else {
		return 0.
	}
}

when stage:resourcesLex["SolidFuel"]:amount <= 5 then {
	//STAGE.
}

WHEN SHIP:ALTITUDE > 9000 THEN {
	STAGE.
}

function SpdLim{
	return 3000.
	if ALTITUDE < 8000 {return spd.}
	if ALTITUDE > 20000 {return 3000.}
	return spd + 700*(ALTITUDE-8000)/12000.
}
function FancyControl {
	WHEN ALT:APOAPSIS < 80000 THEN {
		
		local apoT is (60 - ETA:APOAPSIS)*0.1.
		SetThrottleClever(DownPitch(), apoT).
		if ALTITUDE < 20000 {
			local spdT is 1/twr() - (SHIP:AIRSPEED - SpdLim())*0.01.
			SetThrottleClever(DownPitch(), MIN(spdT,apoT)).
		} else {
			SetThrottleClever(DownPitch(), apoT).
		}
		return ALT:APOAPSIS < 80000.
	}
}
WHEN SHIP:AIRSPEED > 100 THEN {
	FancyControl().
} 

function NPrint {
	parameter s,n.
	PRINT s + ": " + ROUND(n,2).
}
WHEN terminal:input:haschar THEN {
	local ch is terminal:input:getchar().
	if ch = "w" {
		set spd to spd+10.
		NPrint("Speed limit",spd).
	} else if ch = "s" {
		set spd to spd-10.
		NPrint("Speed limit",spd).
	} 
	return true.
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

STAGE.

AscendByProfile( 90000, PitchSetter@, 
list( 0,   558,810,1441,2397,3341,4322,5388,6541,7849,9327,11121), 
list( 1,	 2,4,5,10,15,20,25,30,35,40,45)).

UNTIL (SHIP:ALTITUDE > 30000) {
	set pitchLock to VANG(UP:VECTOR, SRFPROGRADE:VECTOR)-2.
	WAIT 0.1.
}
UNTIL (SHIP:APOAPSIS > 90000) {
	set pitchLock to VANG(UP:VECTOR, SRFPROGRADE:VECTOR).
	WAIT 0.1.
}
set thrustLevel to 0.
WAIT 0.1.
SetThrottleClever(0,1).

SAS ON.
WAIT 0.5.
SET SASMODE to "PROGRADE".
WAIT 0.5.