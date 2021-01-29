function ListActiveEngines {
	local result is list().
	LIST ENGINES IN engLst.
	FOR eng IN engLst {
		IF eng:IGNITION{
			result:ADD(eng).
		}
	}.
	RETURN result.
}
function ListStageEngines {
	parameter stageNum is stage:NUMBER.
	
	local result is list().
	LIST ENGINES IN engLst.
	FOR eng IN engLst {
		IF eng:STAGE = stageNum {
			result:ADD(eng).
		}
	}.
	RETURN result.
}
function GimbaledEngines {
	parameter engLst.
	local result is list().
	FOR eng IN engLst {
		IF eng:HASGIMBAL{
			result:ADD(eng).
		}
	}.
	RETURN result.
}

function CurrentAccel {
	parameter engLst.
	local allTrhust is 0.
	FOR eng IN engLst {
		set allTrhust to allTrhust + eng:THRUST.
	}.
	RETURN allTrhust/MASS.
}
function EnginesThrust {
	parameter engLst is ListActiveEngines().
	local result is 0.
	FOR eng IN engLst {
		set result to result + eng:POSSIBLETHRUST.
	}.
	RETURN result.
}
function EnginesConsumption {
	parameter engLst is ListActiveEngines().
	local result is 0.
	FOR eng IN engLst {
		set result to result + eng:MAXMASSFLOW.
	}.
	RETURN result.
}
