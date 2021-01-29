RUNONCEPATH("0:/lib/Ship/Engines").

function MakeGravTSim{
	parameter condition.
	parameter engList is ListActiveEngines().
	parameter shipThrust is MAXTHRUST.

	local massFlow is EnginesConsumption(engList).
	local br is body:radius.
	local bg is body:mu/body:radius^2.
		
	local function GravTSim{
		parameter dt, startSpeed, startAngle.
		return GravTStep(dt, startSpeed*COS(startAngle),startSpeed*SIN(startAngle)).
	}

	local function GravTStep{
		parameter dt.
		parameter vx,vz.
		parameter cml is list(0,0,0).
		
		local accel is shipThrust/(MASS-cml[0]*massFlow).
		//[0, 1, 2]
		//[t, x, z]
		set cml[0] to cml[0]+dt.
		set cml[1] to cml[1]+vx*dt.
		set cml[2] to cml[2]+vz*dt.
		
		if condition(vx,vz,cml){
			return lexicon(
				"VX", vx,
				"VZ", vz,
				"T", cml[0],
				"X", cml[1],
				"Z", cml[2]
			).
		}
		
		local spd is SQRT(vx*vx+vz*vz).
		
		local sk is accel/spd.
		local dvx is vx*sk.
		local dvz is bg - vx*vx/br - vz*sk.	
		
		
		return GravTStep(dt, vx-dvx*dt, vz+dvz*dt, cml).
	}

	return GravTSim@.
}

function FallFrom{
	parameter t, timeStep is 1.
	
	local p is POSITIONAT(ship, t).
	local spdV is VELOCITYAT(ship,t):SURFACE.
	local upV is (p - ship:BODY:POSITION):NORMALIZED.
	local ang is VANG(spdV,upV)-90.

	local gts is MakeGravTSim({parameter vx,vz,cml. return vx < 0.}).
	return gts(timeStep,spdV:MAG,ang).
}

