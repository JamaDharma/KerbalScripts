function StageIsp{
	parameter pressure is 0.
	
	list engines in engineList.	
	
	local wIsp is 0.	
	for eng in engineList
	if eng:ignition = true {
		set wIsp to wIsp + eng:ISPAT(pressure)*eng:AVAILABLETHRUSTAT(pressure).
	}
	
	return wIsp/SHIP:AVAILABLETHRUSTAT(pressure).
}

function StageLfOx{
	return (STAGE:LIQUIDFUEL+STAGE:OXIDIZER)/200.
}

function LfOxFactor{
	return constant:g0*ln(SHIP:MASS/(SHIP:MASS-StageLfOx())).
}

function StageDeltaV{
	parameter pressure is 0.
	return StageIsp(0)*LfOxFactor().
}