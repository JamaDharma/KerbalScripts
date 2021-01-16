RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/GradientDescent").

parameter h, m, s.
local metricParam to 100.
local timeScale is 3600.
local debugMode is false.

local mainTime is time + h*3600 + m*60 + s.
local branchTime is mainTime.
local mainNode is NEXTNODE.
local branchNode is mainNode.


function Branch{
	parameter myV.

	set branchTime to mainTime + myV[0]*timeScale.
	set branchNode to NODE(
		time:SECONDS+mainNode:ETA+myV[1]*timeScale,
		mainNode:RADIALOUT+myV[3],
		mainNode:NORMAL+myV[4],
		mainNode:PROGRADE+myV[2]).
	REMOVE NEXTNODE.
	ADD branchNode.
	wait 0.
	if debugMode {
		print myV.
		WaitKey().
	}
}

function Commit{
	set mainTime to branchTime.
	set mainNode to branchNode.
}

function Revert{
	set branchTime to mainTime.
	set branchNode to mainNode.
	REMOVE NEXTNODE.
	ADD mainNode.
	wait 0.
}
 
function PrintInfo{
	PRINT "Distance: " + Separation(mainTime).
	PRINT "Time: " + ToTime(mainTime).
	PRINT "Burn: " + DVTotal().
	PRINT "Metric: " + TargetMetric().
	PRINT "------------------------".
}

function MakeRendezvous{
	local context is list(
		100,
		TargetMetric@,
		list(timeLst,etaLst,grdLst,radLst,nrmLst),
		Branch@, Commit@, Revert@).


	PrintInfo().	
	
	GD(context).

	PrintInfo().	
	
	HUDTEXT("Distance: " + Separation(mainTime) + "Time: " + ToTime(mainTime), 5, 2, 50, blue, true).
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
	return RelativeSpeed(branchTime)+NEXTNODE:DELTAV:MAG.
}

function TargetMetric{
	return Separation(branchTime) + DVTotal()*metricParam.
}

local minTimeStep is 1.
set timeLst to LIST(
	minTimeStep,
	{
		parameter dT.
		set branchTime to branchTime+dT*timeScale.
	},
	0
).
set etaLst to LIST(
	minTimeStep,
	{
		parameter dX.
		set NEXTNODE:ETA to NEXTNODE:ETA+dX*timeScale.
	},
	0
).

local minBurnStep is 0.01. 
set grdLst to LIST(
	minBurnStep,
	{
		parameter dX.
		set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
	},
	0
).
set radLst to LIST(
	minBurnStep,
	{
		parameter dX.
		set NEXTNODE:RADIALOUT to NEXTNODE:RADIALOUT+dX.
	},
	0
).
set nrmLst to LIST(
	minBurnStep,
	{
		parameter dX.
		set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX.
	},
	0
).

MakeRendezvous().