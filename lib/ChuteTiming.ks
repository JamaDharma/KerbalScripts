RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Storage").
RUNONCEPATH("0:/lib/SurfaceAt").
RUNONCEPATH("0:/lib/ChuteDeployment").
RUNONCEPATH("0:/lib/AtmosphericEntry").

local calcMargin is 2.//looking to deploy from future state
local marginStep is calcMargin/4+0.01.
local pad is BODY:GEOPOSITIONLATLNG(-0.0972077889151947,-74.5576774701971).

local dk is ShipTypeStorage():GetValue("DragK").
local cdk is xlChuteK.//ShipTypeStorage():GetValue("ChuteDragK").
local dfc is MakeDragForceCalculator(KerbinAT,dk).
local sfc is MakeChuteForceCalculator(KerbinAT,dk,dk+cdk).
local simFree is MakeAtmEntrySim(dfc).
local simChute is MakeAtmEntrySim(sfc).

local function StoppingDistance {
	parameter dragT.
	parameter dragK.
	parameter cState.
	
	local spd is SQRT(cState["VX"]^2+cState["VZ"]^2).
	//vx^2/dvx
	return  cState["VX"]*MASS/(AtmDensity(dragT,cState["Z"])*dragK*spd).
}
function ChuteBrackingEstimate{
	local beforeChute is simFree:FromState(
		{parameter vx,vz,cml. return cml[0] >= calcMargin.},
		marginStep,
		lexicon(
			"VX", GROUNDSPEED,
			"VZ", VERTICALSPEED,
			"T", 0,
			"X", 0,
			"Z", ALTITUDE)
		).

	set beforeChute["T"] to 0.
	set beforeChute["X"] to 0.
	local resultState is simChute:FromState(
		{parameter vx,vz,cml. return cml[2] <= 100 OR vx <= 10.},
		0.25,
		beforeChute
		).
	local stopDist is StoppingDistance(KerbinAT,dk+cdk,resultState).
	if resultState["Z"]<100 { PRINT "Z: " + resultState["Z"]. }
	PRINT "T: " + resultState["T"].
	PRINT "stopDist: " + stopDist.
	return resultState["X"]+stopDist.
}