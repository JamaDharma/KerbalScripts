HUDTEXT("Booster boot script waiting!", 5, 2, 50, blue, true).
WAIT UNTIL SHIP:SHIPNAME = "Booster".
set thrustLevel to 0.
WAIT 3.

RUNONCEPATH("0:/lib/Defaults").
RUNONCEPATH("0:/lib/DeltaV").

function StageDeltaV{
	return shipIsp*LfOxFactor().
}

function BurnPossible{
	return StageDeltaV() > 650 and SHIP:ALTITUDE > 10000.
}

function BurnControl{
	RCS ON.

	LOCK STEERING TO SRFRETROGRADE.

	UNTIL (not BurnPossible()) {
		if VANG(SRFRETROGRADE:VECTOR, SHIP:FACING:VECTOR) < 5 {
			set thrustLevel to 1.	
		} else {
			set thrustLevel to 0.
		}	
		WAIT 0.1.
	}
	
	RCS OFF.

	UNLOCK STEERING.
}

set shipIsp to StageIsp(1).
PRINT "ISP: "+shipIsp.
PRINT "DV: "+StageDeltaV().
PRINT "Mass: "+SHIP:MASS.
PRINT "FuelMass: "+StageLfOx().

SAS OFF.
 
if BurnPossible() {
	BurnControl().
}

RUN LandingA.
