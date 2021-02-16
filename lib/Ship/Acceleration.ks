RUNONCEPATH("0:/lib/Ship/Engines").


function MakeAccelerometer{
	local engLst is ListActiveEngines().

	local lastSpd is AIRSPEED.
	local lastUpd is time.

	local vAcc is 0.
		
	local function UpdateV {
		local eVAccel is CurrentAccel(engLst).
		local cSpd is AIRSPEED.
		local cUpd is time.
		
		local dt is 	(cUpd - lastUpd):SECONDS.
		local dv is cSpd - lastSpd - eVAccel*dt.
		local cAcc is dv/dt.
		
		set lastSpd to cSpd.
		set lastUpd to cUpd.
		set vAcc to (3*vAcc+1*cAcc)/4.

		return vAcc.
	}
	
	return lexicon(
		"UpdateV", UpdateV@,
		"AccV", { return vAcc.}
	).
}

function MakeAccelerometerV{
	local engLst is ListActiveEngines().

	local lastSpd is VERTICALSPEED.
	local lastUpd is time.

	local vAcc is 0.
		
	local function UpdateV {
		local eVAccel is CurrentAccel(engLst)*ship:FACING:VECTOR*UP:VECTOR.
		local cSpd is VERTICALSPEED.
		local cUpd is time.
		
		local dt is 	(cUpd - lastUpd):SECONDS.
		local dv is cSpd - lastSpd - eVAccel*dt.
		local cAcc is dv/dt.
		
		set lastSpd to cSpd.
		set lastUpd to cUpd.
		set vAcc to (vAcc+3*cAcc)/4.

		return vAcc.
	}
	
	return lexicon(
		"UpdateV", UpdateV@,
		"AccV", { return vAcc.}
	).
}
