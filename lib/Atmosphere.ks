RUNONCEPATH("0:/lib/Debug").

global SpeedKT is list(
	list(0000, 0.850),
	list(0222, 0.860),
	list(0254, 0.992),
	list(0290, 1.218),
	list(0299, 1.321),
	list(0331, 2.404),
	list(0344, 2.802),
	list(0360, 2.979),
	list(0376, 2.876),
	list(0435, 1.867),
	list(0448, 1.733),
	list(0476, 1.633),
	list(0581, 1.358),
	list(0698, 1.214),
	list(0809, 1.124),
	list(1078, 0.920),
	list(1338, 0.922),
	list(9999, 0.900)
).

global KerbinAT is list(
	list(0,1.225),
	list(2500,0.898),
	list(5000,0.642),
	list(7500,0.446),
	list(10000,0.288),
	list(15000,0.108),
	list(20000,0.040),
	list(25000,0.015),
	list(30000,0.006),
	list(40000,0.001),
	list(50000,0.0002),	 
	list(54000,0.0001),	 
	list(59000,0.00004),	 
	list(65000,0.00001),	 
	list(70000,0.000),	 
	list(99999,0.000)	 
).
//assumes sorted list
function MakeStatefulInterpolator{
	parameter table.
	
	local maxI is table:LENGTH-2.
	
	//state
	local curI is 0.
	local startKey is 0.
	local endKey is 0.
	local curSlope is 0.
	
	local function UpdateState{
		local se is table[curI].
		local ee is table[curI+1].
		set startKey to se[0].
		set endKey to ee[0].
		set curSlope to (ee[1]-se[1])/(ee[0]-se[0]).
	}
	
	local function GetValue{
		parameter keyP.
		
		if keyP < startKey {
			UNTIL curI = 0 or table[curI][0] <= keyP {
				set curI to curI-1.
			}
			UpdateState().
		}
		
		if keyP > endKey {
			UNTIL curI = maxI or table[curI+1][0] >= keyP {
				set curI to curI+1.
			}
			UpdateState().
		}

		return table[curI][1]+(keyP-startKey)*curSlope.
	}
	
	UpdateState().
	return GetValue@.
}

function AtmDensity{
	parameter dt.
	parameter cAlt.
	local lE is dt[0]. 
	for dte in dt {
		if dte[0] >= cAlt {
			return lE[1]+(dte[1]-lE[1])*(cAlt-lE[0])/(dte[0]-lE[0]).
		}
		set lE to dte.
	}
}

function MakeDragForceCalculator{
	parameter dragT.
	parameter dragK.
	local getSpdK is MakeStatefulInterpolator(SpeedKT).
	local getDensity is MakeStatefulInterpolator(dragT).
	return {
		parameter t.
		parameter cAlt.
		parameter spd.

		return getSpdK(spd)*getDensity(cAlt)*dragK*spd*spd.
	}.
}

function MakeDragFactorCalculator{
	parameter dragT.
	local getSpdK is MakeStatefulInterpolator(SpeedKT).
	local getDensity is MakeStatefulInterpolator(dragT).
	return {
		parameter cAlt.
		parameter spd.

		return getSpdK(spd)*getDensity(cAlt)*spd*spd.
	}.
}
