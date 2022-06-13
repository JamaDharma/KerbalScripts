RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/BinarySearch").

local val is 0.

function RunTest{
	local val is 0.
	local result is list().
	
	function Metric{
		PRINT "Trying value:" + val.
		result:ADD(val).
		return ABS(val - 0.88).
	}
	
	BSearch(	Metric@,
		MakeBSComponent( 1, 1/16, {parameter dA. set val to val + dA.})).
	
	return val.
}

print RunTest().