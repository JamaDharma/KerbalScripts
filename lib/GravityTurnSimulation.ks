RUNONCEPATH("0:/lib/Ship/Engines").
local massFlow is EnginesConsumption().
local dt is 1.
local br is body:radius.
local bg is body:mu/body:radius^2.

local function GravTStep{
	parameter vx,vz.
	parameter cml is list(0,0,0).
	
	local accel is MAXTHRUST/(MASS-cml[0]*massFlow).
	//[0, 1, 2]
	//[t, x, z]
	set cml[0] to cml[0]+dt.
	set cml[1] to cml[1]+vx*dt.
	set cml[2] to cml[2]+vz*dt.
	

	if vx < 0 return cml.
	local spd is SQRT(vx*vx+vz*vz).
	
	local sk is accel/spd.
	local dvx is vx*sk.
	local dvz is bg - vx*vx/br - vz*sk.
	
	
	
	return GravTStep(vx-dvx*dt, vz+dvz*dt, cml).
}

local function GravTSim{
	parameter startSpeed, startAngle.
	return GravTStep(startSpeed*COS(startAngle),startSpeed*SIN(startAngle)).
}

function FallFrom{
	parameter t, timeStep is 1.
	
	set dt to timeStep.
	local p is POSITIONAT(ship, t).
	local spdV is VELOCITYAT(ship,t):SURFACE.
	local upV is (p - ship:BODY:POSITION):NORMALIZED.
	
	local ang is VANG(spdV,upV)-90.
	
	return GravTSim(spdV:MAG,ang).
}

