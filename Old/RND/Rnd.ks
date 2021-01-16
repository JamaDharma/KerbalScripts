RUNONCEPATH("0:/lib/Defaults").

parameter h, m, s.

set rTime to time + h*3600 + m*60 + s.
set rSep to Separation(rTime).

function MakeRendezvous{
	FindTime(1).
	HUDTEXT("Distance: " + rSep, 5, 2, 50, blue, true).
	HUDTEXT("Time: " + rTime, 5, 2, 50, blue, true).
	WAIT 0.
	set stp to 1.
	UNTIL rSep < 200 OR stp < 0.1 {
		BinareSearch(ChangeGrd@, stp).
		WAIT 0.
		BinareSearch(ChangeRad@, stp).
		WAIT 0.
		BinareSearch(ChangeNrm@, stp).
		WAIT 0.
		FindTime(1).
		set stp to stp/1.1.
	}
	HUDTEXT("Distance: " + rSep, 5, 2, 50, blue, true).
	HUDTEXT("Time: " + rTime, 5, 2, 50, blue, true).
	
	set approacV to (VELOCITYAT(ship, rTime):ORBIT - VELOCITYAT(target, rTime):ORBIT):mag.
	set approach TO NODE(rTime:SECONDS, 0, 0, -approacV).
	ADD approach.
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