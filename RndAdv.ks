RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/GradientDescent").

parameter h, m, s.

local rTime to time + h*3600 + m*60 + s.
local rSep to Separation(rTime).
local metricParam to 100.
 
function PrintInfo{
	PRINT "Distance: " + rSep.
	PRINT "Time: " + ToTime(rTime).
	PRINT "Burn: " + DVTotal().
	PRINT "Metric: " + TargetMetric().
	PRINT "------------------------".
}

function MakeRendezvous{
	PRINT "Distance 0: " + rSep.
	PRINT "Time 0: " + ToTime(rTime).
	PRINT "------------------------".
	BinareSearch(timeLst).
	set rSep to Separation(rTime).
	PRINT "DistanceS: " + rSep.
	PRINT "TimeS: " + ToTime(rTime).
	PRINT "------------------------".
	WAIT 0.
	local oldM is TargetMetric().
	UNTIL rSep < 200 {
		BinareSearch(timeLst).
		BinareSearch(etaLst).
		BinareSearch(grdLst).
		BinareSearch(radLst).
		BinareSearch(nrmLst).
		
		local newM is TargetMetric().
		//if oldM-newM < 100 {	set metricParam to metricParam/2.	}
		
		set rSep to Separation(rTime).
		PrintInfo().
		WAIT 0.
	}

	HUDTEXT("Distance: " + rSep + "Time: " + ToTime(rTime), 5, 2, 50, blue, true).
	//set approacV to (VELOCITYAT(ship, rTime):ORBIT - VELOCITYAT(target, rTime):ORBIT):mag.
	//set approach TO NODE(rTime:SECONDS, 0, 0, -approacV).
	//ADD approach.
}

function ToTime{
	parameter t.
	local tt is t-time.
	return FLOOR(tt:SECONDS/3600/6)+"d:"+tt:HOUR+"h:"+(t-time):MINUTE+"m:"+(t-time):SECOND+"s".
}


function Separation{
	parameter t.
	return (positionat(ship, t) - positionat(target, t)):mag.
}

function RelativeSpeed{
	parameter t.
	return (velocityat(ship, t):ORBIT - velocityat(target, t):ORBIT):mag.
}

function DVTotal{
	return RelativeSpeed(rTime)+NEXTNODE:DELTAV:MAG.
}

function TargetMetric{
	return Separation(rTime) + DVTotal()*metricParam.
}

local minTimeStep is 0.01.
set timeLst to LIST(
	1,
	{
		parameter dT.
		set rTime to rTime+dT.
	},
	minTimeStep,
	TargetMetric@
).

local minBurnStep is 0.01. 
set etaLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:ETA to NEXTNODE:ETA+dX.
	},
	minBurnStep,
	TargetMetric@
).
set grdLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
	},
	minBurnStep,
	TargetMetric@
).
set radLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:RADIALOUT to NEXTNODE:RADIALOUT+dX.
	},
	minBurnStep,
	TargetMetric@
).
set nrmLst to LIST(
	1,
	{
		parameter dX.
		set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX.
	},
	minBurnStep,
	TargetMetric@
).

MakeRendezvous().