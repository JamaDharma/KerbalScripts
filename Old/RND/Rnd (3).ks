RUNONCEPATH("0:/lib/Defaults").

parameter h, m, s.

set rTime to time + h*3600 + m*60 + s.
set rSep to Separation(rTime).
 

function MakeRendezvous{
	PRINT "Distance 0: " + rSep.
	PRINT "Time 0: " + rTime.
	PRINT "------------------------".
	FindTime().
	PRINT "DistanceS: " + rSep.
	PRINT "TimeS: " + rTime.
	PRINT "------------------------".
	WAIT 0.
	set oldSep to 0.
	UNTIL rSep < 200 OR rSep = oldSep {
		set oldSep to rSep.
		BinareSearch(ChangeGrd@).
		WAIT 0.
		BinareSearch(ChangeRad@).
		WAIT 0.
		BinareSearch(ChangeNrm@).
		WAIT 0.
		//FindTime().
	}

	PRINT "DistanceE: " + rSep.
	PRINT "TimeE: " + rTime.
	PRINT "------------------------".	
	PRINT "------------------------".	

	HUDTEXT("Distance: " + rSep + "Time: " + ToTime(rTime), 5, 2, 50, blue, true).
	//set approacV to (VELOCITYAT(ship, rTime):ORBIT - VELOCITYAT(target, rTime):ORBIT):mag.
	//set approach TO NODE(rTime:SECONDS, 0, 0, -approacV).
	//ADD approach.
}

function ToTime{
	parameter t.
	return (t-time):HOUR+"h,"+(t-time):MINUTE+"m,"+(t-time):SECOND+"s".
}


function Separation{
	parameter t.
	return (positionat(ship, t) - positionat(target, t)):mag.
}



local timeStep is 1.

function TrySetTime {
	parameter dt.
	set rTN to rTime + dt.
	set rSN to Separation(rTN).
	IF  rSN < rSep { 
		set rTime to rTN.
		set rSep to rSN.
		set timeStep to dt.
		FindTime(dt*2).
		return true.
	} 
	return false.
}

function FindTime{
	parameter dt is timeStep.
	IF ABS(dt) < 0.1 { return. }
	
	if TrySetTime(dt) { return. }
	
	if TrySetTime(-dt) { return. }

	FindTime(dt/2).
}


local grdLst is LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
	}
)
function ChangeGrd{
	parameter dX.
	set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
}
function ChangeRad{
	parameter dX.
	set NEXTNODE:RADIALOUT to NEXTNODE:RADIALOUT+dX.
}
function ChangeNrm{
	parameter dX.
	set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX.
}



local nodeStep is 1.

function TrySetNode {
	parameter changer.
	parameter dN.
	set rSN to Separation(rTime).
	IF  rSN < rSep { 
		set rSep to rSN.
		set dN to dN*2.
		BinareSearch(changer, dN*2).
		return true.
	}
	return false.
}

function BinareSearch{
	parameter changer.
	parameter dN is nodeStep.
	IF rSep < 100 { return. }
	IF ABS(dN) < 0.001 { return. }
	
	changer:call(dN).//step
	if TrySetNode(changer) { return. }
 	
	changer:call(-dN*2).//*2 to compensate prev attempt
	set dN to -dN.
	if TrySetNode(changer) { return. }
	set dN to -dN.
	
	changer:call(dN).//failed to improve, no steps
	set dN to dN/2.
	BinareSearch(changer).
}


MakeRendezvous().