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
	return ln(SHIP:MASS/(SHIP:MASS-StageLfOx())).
}

function MassAfter{
	parameter dV.
	return StageCalculator():MassAfter(dv).
}

function StageDeltaV{
	parameter pressure is 0.
	return StageCalculator(pressure):StageDeltaV().
}

function BurnTime{
	parameter dV.
	return StageCalculator():BurnTime(dv).
}

function StageCalculator{
	parameter pressure is 0.
	local ispP is StageIsp(pressure).
	local exV is constant:g0*ispP.
	local accel is ship:AVAILABLETHRUSTAT(pressure)/MASS.
	
	function MassAfter{
		parameter dV.
		return MASS/(constant:E^(dV/exV)).
	}
	
	function BurnTime{
		parameter dV is StageDeltaV().
		return exV/accel * (1 - constant:E^(-dV/exV)).
	}
	
	function StageDeltaV{
		return exV*LfOxFactor().
	}
	
	return lexicon(
		"Acceleration",accel,
		"StageDeltaV",StageDeltaV@,
		"MassAfter",MassAfter@,
		"BurnTime", BurnTime@
	).
}