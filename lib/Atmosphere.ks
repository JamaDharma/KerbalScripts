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
	list(50000,0.000)	 
).
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
	
	return {
		parameter t.
		parameter cAlt.
		parameter spd.
		return AtmDensity(dragT,cAlt)*dragK*spd*spd.
	}.
}
