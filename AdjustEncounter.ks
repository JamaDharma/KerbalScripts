RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/BinarySearch").
RUNONCEPATH("0:/lib/Search/ManeuverSearch").

function FinalApproach{
	local tgtOrbit is NEXTNODE:ORBIT:NEXTPATCH.
	PRINT "Target body: " + tgtOrbit:BODY.
	
	local search is MakeBurnSearcher(Metric@).
	
	function Metric{
		return TargetMetric(8000, 78.12).
	}
	
	search:GO(0.1).
}

function TargetMetric{
	parameter tPrp, tInc.
	local tgtOrbit is NEXTNODE:ORBIT:NEXTPATCH.
	local prpc is (tgtOrbit:PERIAPSIS-tPrp).
	local incc is (tgtOrbit:INCLINATION-tInc)*100.
	return prpc*prpc + incc*incc + NEXTNODE:DeltaV:MAG.
}

FinalApproach().