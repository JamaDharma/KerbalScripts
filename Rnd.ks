RUNONCEPATH("0:/lib/Defaults").

parameter h, m, s.

set rTime to time + h*3600 + m*60 + s.
set rSep to Separation(rTime).
 

function MakeRendezvous{
	PRINT "Distance 0: " + rSep.
	PRINT "Time 0: " + rTime.
	PRINT "------------------------".
	BinareSearch(timeLst).
	PRINT "DistanceS: " + rSep.
	PRINT "TimeS: " + rTime.
	PRINT "------------------------".
	WAIT 0.
	set oldSep to 0.
	UNTIL rSep < 200 OR rSep = oldSep {
		set oldSep to rSep.
		BinareSearch(timeLst).
		WAIT 0.
		BinareSearch(etaLst).
		WAIT 0.
		BinareSearch(grdLst).
		WAIT 0.
		BinareSearch(radLst).
		WAIT 0.
		BinareSearch(nrmLst).
		WAIT 0.
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



local minTimeStep is 0.01.
set timeLst to LIST(
	1,
	{
		parameter dT.
		set rTime to rTime+dT.
	},
	minTimeStep
).



local minBurnStep is 0.01. 
set etaLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:ETA to NEXTNODE:ETA+dX.
	},
	minBurnStep
).
set grdLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
	},
	minBurnStep
).
set radLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:RADIALOUT to NEXTNODE:RADIALOUT+dX.
	},
	minBurnStep
).
set nrmLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX.
	},
	minBurnStep
).

function TrySetNode {
	parameter lst.
	parameter dN.
	parameter upstep.
	set rSN to Separation(rTime).
	IF  rSN < rSep { 
		set rSep to rSN.
		set lst[0] to dN.
		if upstep { set newstep to dN*2.	} 
			else { set newstep to dN/2. }
		BinareSearch(lst, newstep, upstep).
		return true.
	}
	return false.
}

function BinareSearch{
	parameter lst.
	parameter dN is lst[0].
	parameter upstep is true.
	
	local changer is lst[1].
	IF rSep < 100 { return. }
	IF ABS(dN) < lst[2] { return. }
	
	changer:call(dN).//step
	if TrySetNode(lst, dn, upstep) { return. }
 	
	changer:call(-dN*2).//*2 to compensate prev attempt
	if TrySetNode(lst, -dn, upstep) { return. }
	
	changer:call(dN).//failed to improve, no steps
	BinareSearch(lst, dN/2, false).
}


MakeRendezvous().