RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/TragectoryImpactSearch").

local function Gravity {
	return body:mu/body:radius^2.
}

local function VAccel{
	local vAngle is VANG(UP:VECTOR, SRFRETROGRADE:VECTOR).
	local vCmp is COS(vAngle).
	return vCmp*MAXTHRUST/MASS - Gravity().
}

function SetUpTrigger{
	parameter spd.
	WHEN AIRSPEED < spd THEN {
		LOCK STEERING TO UP.
	}
}

local bounds_box is ship:bounds.
local bkv is -ship:FACING:VECTOR.
local altCorrection is bounds_box:FURTHESTCORNER(bkv):MAG-(SHIP:ROOTPART:POSITION*bkv).

function RealAltitude {
	RETURN ALT:RADAR-altCorrection.
}
function RealAltitudeRay {
	RETURN bounds_box:BOTTOMALTRADAR.
}

		
function ImpactAltAdj{

	local brakingTime is AIRSPEED*MASS/MAXTHRUST.
	local brakingDst is GROUNDSPEED*brakingTime/2.

	local stepV is VXCL(UP:VECTOR, SRFPROGRADE:VECTOR):NORMALIZED*10.
	local currH is BODY:GEOPOSITIONOF(ship:POSITION):TERRAINHEIGHT.
	local maxH is currH.
	UNTIL (stepV:MAG > brakingDst) {
		local pathH is BODY:GEOPOSITIONOF(ship:POSITION+stepV):TERRAINHEIGHT.
		set maxH to MAX(maxH,pathH).
		set stepV to stepV*1.5.
	}
	
	function PrintInfo{
		print "max alt "+maxH.
		print "dist "+brakingDst.
		print "time "+brakingTime.
	}
	//PrintInfo().
	return MAX(0,maxH-currH). 
}

local startBraking to FALSE.
function SuicideBurnControl {
	parameter landingSpeed,rAlt,thrustSetter.
	local accel is VAccel().
	local brakingDst is (VERTICALSPEED^2 - landingSpeed^2)/2/accel.
	local brakingTime is ABS(VERTICALSPEED + landingSpeed)/accel.

	function PrintInfo{
		print "alt "+rAlt.
		print "vAccel "+accel.
		print "dist "+brakingDst.
	}
	//PrintInfo().
	
	IF rAlt > brakingDst*2 {
		set startBraking to FALSE.
	}
	
	IF rAlt*5 < (brakingDst-VERTICALSPEED*0.1)*6 {
		set startBraking to TRUE.
	}

	IF startBraking AND AIRSPEED > landingSpeed {
		thrustSetter(MIN(1,brakingDst/rAlt)).
	} ELSE {
		thrustSetter(0).
	}
}

function TouchDownControl {
	parameter landingSpeed,thrustSetter.
	thrustSetter(Gravity()*MASS/MAXTHRUST*(9-VERTICALSPEED/landingSpeed)/10).
}


function SuicideBurn  {
	parameter landingSpeed,thrustSetter.
	parameter altGetter is RealAltitude@.
	
	UNTIL (AIRSPEED < landingSpeed and altGetter() < 1) {
		SuicideBurnControl(landingSpeed, altGetter(), thrustSetter).
		WAIT 0.
	}
	
	HUDTEXT("Touchdown mode", 5, 2, 50, green, true).
	UNTIL (SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED") {
		TouchDownControl(landingSpeed, thrustSetter).
		WAIT 0.
	}
	
	thrustSetter(0).
}

function DoubleBurn  {
	parameter speed0,height0.
	parameter landingSpeed,thrustSetter.
	parameter altGetter is RealAltitude@.
	
	UNTIL (AIRSPEED < speed0 and altGetter()-height0 < 1) {
		SuicideBurnControl(speed0, (altGetter()-height0), thrustSetter).
		PRINT "First burn "+(altGetter()-height0).
		WAIT 0.
	}
	
	UNTIL (AIRSPEED < landingSpeed and altGetter() < 1) {
		PRINT "Second burn".
		SuicideBurnControl(landingSpeed, altGetter(), thrustSetter).
		WAIT 0.
	}
	
	HUDTEXT("Touchdown mode", 5, 2, 50, green, true).
	UNTIL (SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED") {
		TouchDownControl(landingSpeed, thrustSetter).
		WAIT 0.
	}
	
	thrustSetter(0).
}

function ImpactBurn  {
	parameter landingSpeed,thrustSetter.
	parameter altGetter is RealAltitude@.
	
	local impAdj is 0.
	local lastUse is 0.
	UNTIL (AIRSPEED < landingSpeed or altGetter() < 1) {
		if time:SECONDS > lastUse +0.3 {
			set impAdj to ImpactAltAdj().
			//NPrint("impAdj",impAdj).
			set lastUse to time:SECONDS.
		}
		SuicideBurnControl(landingSpeed, altGetter()+impAdj, thrustSetter).
		WAIT 0.
	}
	
	PRINT "Touch down mode".
	UNTIL (SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED") {
		TouchDownControl(landingSpeed, thrustSetter).
		WAIT 0.
	}
	
	thrustSetter(0).
}

function OImpactBurn  {
	parameter landingSpeed,thrustSetter.
	parameter altGetter is RealAltitude@.
	
	local impT is TragectoryImpactTime().
	local burnT is TragectoryBurnTime(impT).
	clearscreen.
	PRINT ROUND((impT-time):SECONDS).
	PRINT ROUND(burnT).
	UNTIL (impT < time+burnT/2+5) {
		WAIT 1.
		clearscreen.
		PRINT ROUND((impT-time):SECONDS).
		PRINT ROUND(burnT).
	}
	
	thrustSetter(1).
	WAIT UNTIL VANG(UP:VECTOR, SRFRETROGRADE:VECTOR)<60.
	
	local impAdj is 0.
	local lastUse is 0.
	UNTIL (AIRSPEED < landingSpeed or altGetter() < 1) {
		if time > lastUse +0.3 {
			set impAdj to ImpactAltAdj().
			set lastUse to time.
		}
		SuicideBurnControl(landingSpeed, altGetter()-impAdj, thrustSetter).
		WAIT 0.
	}
	
	UNTIL (SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED") {
		TouchDownControl(landingSpeed, thrustSetter).
		WAIT 0.
	}
	
	thrustSetter(0).
}