switch to 0.
RUNONCEPATH("Ascend").
RUNONCEPATH("Orbit").
RUNONCEPATH("Losses").

set thrustLevel to 1.
set pitchLock to 0.
LOCK STEERING TO HEADING(90, 90 - pitchLock).
//([3100,3200,3400,3600,3800,4200,4600,4900],[1,2,5,10,14,25,34,43]) 4265
//([3300,3500,3900,4500,5100,6100,7000,7900],[1,2,5,10,15,25,35,44]) 4385
//([3300,3600,4200,5100,5800,7200,8600,9900],[1,2,5,10,15,24,35,44]) 4406
//([3400,3700,4600,5700,6600,8500,10200,11900],[1,2,5,10,15,25,35,44]) 4412
//([3600,4000,5100,6500,7900,10300,12700,14900],[1,2,5,10,15,25,35,44]) 4397


//([3414,3664,4299,5215,6067,7690,9319,10988],[1,2,5,10,15,25,35,45]) 4417
//([3400,3700,4400,5500,6400,8200,10100,12000],[1,2,5,10,15,25,35,45]) 4418
//([3430,3740,4521,5652,6716,8769,10840,12986],[1,2,5,10,15,25,35,45]) 4417

// 55 90 4413
// 62.5 90 4419
// 65 90 4423
// 67.5 90 4418
// 70 90 4415
function AscendByProfile{
	parameter trgtApoapsis is 80000.
	local altList is list( 0,		3450,3730,4433,5460,6411,8243,10093,11987		,20000,40000):ITERATOR.
	local angList is list(0,		1,2,5,10,15,25,35,45		,65,90):ITERATOR.
	altList:NEXT.
	angList:NEXT.
	SteerTo(trgtApoapsis, altList, angList).
}

function SteerTo{
	parameter trgtApoapsis.
	parameter startAltPointer.
	parameter startAnglePointer.
	
	local startAlt is startAltPointer:VALUE.
	local startAngle is startAnglePointer:VALUE.
	
	if ((not startAltPointer:NEXT) or (not startAnglePointer:NEXT)) { return. }
	
	local targetAlt is startAltPointer:VALUE.
	local targetAngle is startAnglePointer:VALUE.
	
	PRINT "Target altitude " + targetAlt.
	PRINT "Target angle " + targetAngle.
	until (SHIP:ALTITUDE > targetAlt or ALT:APOAPSIS > trgtApoapsis)
	{
		set pitchLock to startAngle + (SHIP:ALTITUDE - startAlt)/(targetAlt - startAlt)*(targetAngle - startAngle).
		WAIT 0.
	}
	PRINT targetAlt + " passed".
	SteerTo(trgtApoapsis, startAltPointer, startAnglePointer).
}


ON round(TIME:SECONDS){
	PRINT "G: " + round(GravLoss()) + " D: " + round(DragLoss()) + " S: " + round(SteerLoss()).
	return false.
}

WHEN(SHIP:ALTITUDE > 12000) THEN{
	HUDTEXT("Fuel: " + ROUND(STAGE:LIQUIDFUEL) + " Speed: " + ROUND(SHIP:AIRSPEED), 10, 2, 50, green, true).
}

//Ascend
AscendByProfile(60000).
	
RiseFromAtmosphere(60000).

CircularizeOrbit().