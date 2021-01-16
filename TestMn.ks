local mynode is NEXTNODE.

function MakeRendezvous1{//11 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(etaLst,grdLst,radLst,nrmLst).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.

		grdLst[1](dx).
		
		positionat(ship, time + mynode:ETA + 500).
	}
}

function MakeRendezvous2{//13 and slower
	local counter is 0.
	local dx is 1.
	local ll is list(etaLst,grdLst,radLst,nrmLst).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		REMOVE(mynode).

		grdLst[1](dx).
		
		ADD(mynode).
		positionat(ship, time + mynode:ETA + 500).
	}
}

function MakeRendezvous3{//37 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(etaLst,grdLst,radLst,nrmLst).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		
		FOR sl in ll{
			sl[1](dx).
		}

		positionat(ship, time + mynode:ETA + 500).
	}
}

function MakeRendezvous4{//39 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(etaLst,grdLst,radLst,nrmLst).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		
		REMOVE(mynode).
		FOR sl in ll{
			sl[1](dx).
		}
		ADD(mynode).
		
		positionat(ship, time + mynode:ETA + 500).
	}
}

function MakeRendezvous5{//30 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(grdLst,radLst,nrmLst).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		
		FOR sl in ll{
			sl[1](dx).
		}

		positionat(ship, time + mynode:ETA + 500).
	}
}

function MakeRendezvous6{//11 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(etaLst,grdLst,radLst,nrmLst).
	REMOVE(mynode).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		local newnode is NODE(time:SECONDS+mynode:ETA,dx,dx,dx).
		ADD(newnode).
		positionat(ship, time + mynode:ETA + 500).
		REMOVE(newnode).
	}
	ADD(mynode).
}

function doNothing{
	parameter sdfsdf.
	return sdfsdf.
}
function MakeRendezvous7{//41 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(doNothing@).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		local sc is 0.
		until sc > 4 {
			set sc to sc+1.
			ll[0](sc*dx).
		}
		positionat(ship, time + mynode:ETA + 500).
	}
}

function MakeRendezvous8{//34 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(doNothing@).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		local sc is 0.
		until sc > 4 {
			set sc to sc+1.
			set mynode:PROGRADE to mynode:PROGRADE+dX*sc.
		}
		positionat(ship, time + mynode:ETA + 500).
	}
}

function MakeRendezvous9{//14 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(etaLst,grdLst,radLst,nrmLst).
	REMOVE(mynode).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		local newnode is NODE(time:SECONDS+mynode:ETA,mynode:PROGRADE+dx,mynode:RADIALOUT+dx,mynode:NORMAL+dx).
		ADD(newnode).
		positionat(ship, time + mynode:ETA + 500).
		REMOVE(newnode).
	}
	ADD(mynode).
}

function MakeRendezvous{//34 seconds
	local counter is 0.
	local dx is 1.
	local ll is list(doNothing@).
	UNTIL counter > 2500 {
		set counter to counter+1.
		set dx to -dx.
		local sc is 0.
		REMOVE(mynode).
		until sc > 4 {
			set sc to sc+1.
			set mynode:PROGRADE to mynode:PROGRADE+dX*sc.
		}
		ADD(mynode).
		positionat(ship, time + mynode:ETA + 500).
	}
}

function ToTime{
	parameter t.
	return (t-time):HOUR+"h,"+(t-time):MINUTE+"m,"+(t-time):SECOND+"s".
}


function Separation{
	parameter t.
	return (positionat(ship, t) - positionat(target, t)):mag.
}



local minBurnStep is 0.01. 
set etaLst to LIST(
	1,
	{
		parameter dX.
		set mynode:ETA to mynode:ETA+dX.
	},
	minBurnStep
).
set grdLst to LIST(
	1,
	{
		parameter dX.
		set mynode:PROGRADE to mynode:PROGRADE+dX.
	},
	minBurnStep
).
set radLst to LIST(
	1,
	{
		parameter dX.
		set mynode:RADIALOUT to mynode:RADIALOUT+dX.
	},
	minBurnStep
).
set nrmLst to LIST(
	1,
	{
		parameter dX.
		set mynode:NORMAL to mynode:NORMAL+dX.
	},
	minBurnStep
).

MakeRendezvous().