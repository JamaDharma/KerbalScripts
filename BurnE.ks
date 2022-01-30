RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/BurnExecutor").
parameter bodyName is "Mun", tgtPeriapsis is 25000.
SAS OFF.
local tgtBody is BODY(bodyName).
local tc is MakeThrustControl(tgtPeriapsis,-1).
function ThrustControl{
	if ship:ORBIT:HASNEXTPATCH and ship:ORBIT:NEXTPATCH:BODY = tgtBody {
		local currPer is ship:ORBIT:NEXTPATCH:PERIAPSIS.
		if currPer < tgtPeriapsis return -1.	
		return tc(currPer)+0.001.
	}
	return 1.
}
BurnExecutor(ProgradeBurnControl(NEXTNODE,ThrustControl@)).
SAS ON.