RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/Search/ManeuverSearch").

function PrintInfo{
	parameter mainTime.
	PRINT "Distance: " + Separation(mainTime).
	PRINT "Time: " + ToTime(mainTime).
	PRINT "Burn: " + DVTotal(mainTime).
	PRINT "Metric: " + TargetMetric(mainTime).
	PRINT "------------------------".
}
function MinimalSeparationTime{
	parameter h, m, s.
	local minSepTime is time + h*3600 + m*60 + s.
	
	BSearch(list(
		0.1,
		{parameter dT. set minSepTime to minSepTime + dT.},
		1,
		{ return Separation(minSepTime).})).
	
	return minSepTime.
}

function CheckRendezvousMetric{
	parameter h, m, s.
	local msTime is MinimalSeparationTime(h,m,s).
	SetTargetDistance(1000).
	
	PrintInfo(msTime).
}

function FinalApproach{
	parameter h, m, s.
	local msTime is MinimalSeparationTime(h,m,s).
	SetTargetDistance(10).
	
	PrintInfo(msTime).
	
	local search is MakeMSearcher(Metric@,1,msTime).
	
	function Metric{
		return TargetMetric(search:TrgTime()).
	}
	
	search:GO(0.1).
	
	PrintInfo(search:TrgTime()).	
}

function MakeRendezvous{
	parameter h, m, s.
	local msTime is MinimalSeparationTime(h,m,s).
	SetTargetDistance(1000).
	
	PrintInfo(msTime).
	
	local search is MakeMSearcher(Metric@,1,msTime).
	
	function Metric{
		return TargetMetric(search:TrgTime()).
	}
	
	search:GO(1).
	
	PrintInfo(search:TrgTime()).	
}

function MakeEncounter{
	parameter h, m, s.
	local msTime is MinimalSeparationTime(h,m,s).
	SetTargetDistance(1000*1000).

	PrintInfo(msTime).

	local search is MakeMSearcher(Metric@,1000,msTime).
	
	function Metric{
		return TargetMetric(search:TrgTime()).
	}
	
	search:GO(10).
	
	PrintInfo(search:TrgTime()).
}

function MakeMeetUpNode{
	local meetUpBurn is RelativeVelocity(mainTime).
	local meetUpNode is NODE(mainTime:SECONDS,0,0,1).
	ADD meetUpNode.
	WAIT 0.
	local prog is -meetUpNode:BURNVECTOR*meetUpBurn.
	set meetUpNode:PROGRADE to 0.
	set meetUpNode:RADIALOUT to 1.
	local rad is -meetUpNode:BURNVECTOR*meetUpBurn.
	set meetUpNode:NORMAL to 1.
	set meetUpNode:RADIALOUT to 0.
	local nrm is -meetUpNode:BURNVECTOR*meetUpBurn.
	set meetUpNode:PROGRADE to prog.
	set meetUpNode:RADIALOUT to rad.
	set meetUpNode:NORMAL to nrm.
}

function ToTime{
	parameter t.
	local tt is t-time.
	return FLOOR(tt:SECONDS/3600/6)+"d:"+tt:HOUR+"h:"+(t-time):MINUTE+"m:"+(t-time):SECOND+"s".
}

function SeparationV{
	parameter t.
	return (POSITIONAT(ship, t) - POSITIONAT(target, t)).
}
function Separation{
	parameter t.
	return SeparationV(t):MAG.
}
function SqSep{
	parameter t.
	return SeparationV(t):SQRMAGNITUDE.
}

function RelativeVelocity{
	parameter t.
	return (velocityat(ship, t):ORBIT - velocityat(target, t):ORBIT).
}
function RelativeSpeed{
	parameter t.
	return RelativeVelocity(t):mag.
}


function DVTotal{
	parameter t.
	return RelativeSpeed(t)+NEXTNODE:DELTAV:MAG.
}


local metricParam is 1.
local minDist is 0.
function SetTargetDistance{
	parameter dst.
	set minDist to dst.
	set metricParam to 1/dst.
}
function TargetMetric{
	parameter t.
	local sepSq is MAX(0,Separation(t) - minDist)^2.
	return sepSq*metricParam + DVTotal(t).
}