RUNONCEPATH("0:/lib/Defaults").

parameter h, m, s.

set rTime to time + h*3600 + m*60 + s.
set rSep to Separation(rTime).

function MakeRendezvous{
	PRINT "Distance 0: " + rSep.
	PRINT "Time 0: " + rTime.
	PRINT "------------------------".
	FindTime(1).
	PRINT "DistanceS: " + rSep.
	PRINT "TimeS: " + rTime.
	PRINT "------------------------".
	WAIT 0.
	set oldSep to 0.
	UNTIL rSep < 200 OR rSep = oldSep {
		set oldSep to rSep.
		BinareSearch(ChangeGrd@, 1).
		WAIT 0.
		BinareSearch(ChangeRad@, 1).
		WAIT 0.
		BinareSearch(ChangeNrm@, 1).
		WAIT 0.
		FindTime(1).
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

function FindTime{
	parameter dt.
	IF dt < 0.1 { return. }
	
	set rTN to rTime + dt.
	set rSN to Separation(rTN).
	IF  rSN < rSep { 
		set rTime to rTN.
		set rSep to rSN.
		FindTime(dt*2).
		return.
	} 	
	
	set rTN to rTime - dt.
	set rSN to Separation(rTN).
	IF  rSN < rSep { 
		set rTime to rTN.
		set rSep to rSN.
		FindTime(dt*2).
		return.
	}
	
	FindTime(dt/2).
}

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

function BinareSearch{
	parameter changer, dX.
	IF rSep < 100 { return. }
	IF dX < 0.001 { return. }
	
	changer:call(dX).
	set rSN to Separation(rTime).
	IF  rSN < rSep { 
		set rSep to rSN.
		BinareSearch(changer, dX*2).
		return.
	}
 	
	changer:call(-dX*2).
	set rSN to Separation(rTime).
	IF  rSN < rSep { 
		set rSep to rSN.
		BinareSearch(changer, dX*2).
		return.
	} 
	
	changer:call(dX).
	BinareSearch(changer, dX/2).
}


MakeRendezvous().