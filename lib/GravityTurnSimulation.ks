RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ship/Engines").
local function MakeSimpleGravityTurnStep{
	parameter dt.
	parameter condition.
	parameter massFlow.
	parameter shipThrust is MAXTHRUST.
	
	local shipMass is MASS.
	
	local br is body:radius.
	local bg is body:mu/body:radius^2.
	
	local function GravTStep{
		parameter vx,vz.
		parameter cml.
		
		local accel is shipThrust/(shipMass-cml[0]*massFlow).
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
		local dvz is vz*sk - (bg - vx*vx/br).	
		
		
		return GravTStep(vx+dvx*dt, vz+dvz*dt, cml).
	}
}

function MakeGravTSim{
	parameter massFlow.
	parameter shipThrust is MAXTHRUST.

	local br is body:radius.
	local bg is body:mu/body:radius^2.
	
	local condition is { return vz > 0.}.
	local dt is 1.
	
	local function SimVelAng{
		parameter exitCondition, timeStep.
		parameter startSpeed, startAngle.
		parameter cml is list(0,0,0).
		
		set condition to exitCondition.
		set dt to timeStep.
		
		return GravTStep(
			startSpeed*COS(startAngle),
			startSpeed*SIN(startAngle),
			cml).
	}
	local function SimState{
		parameter exitCondition, timeStep.
		parameter st.
		
		set condition to exitCondition.
		set dt to timeStep.
		
		return GravTStep(st["VX"],st["VZ"],list(st["T"],st["X"],st["Z"])).
	}

	local function GravTStep{
		parameter vx,vz.
		parameter cml.
		
		UNTIL condition(vx,vz,cml) {
			local accel is shipThrust/(MASS-cml[0]*massFlow).
			//[0, 1, 2]
			//[t, x, z]
			set cml[0] to cml[0]+dt.
			set cml[1] to cml[1]+vx*dt.
			set cml[2] to cml[2]+vz*dt.

			local spd is SQRT(vx*vx+vz*vz).
			
			local sk is accel/spd.
			local dvx is vx*sk.
			local dvz is vz*sk - (bg - vx*vx/br).	
			
			set vx to vx+dvx*dt.
			set vz to vz+dvz*dt.
		}

		return lexicon(
				"VX", vx,
				"VZ", vz,
				"T", cml[0],
				"X", cml[1],
				"Z", cml[2]
			).
	}

	return lexicon(
		"VelAng", SimVelAng@,
		"State", SimState@).
}

function FallFrom{
	parameter t, timeStep is 1.
	
	local p is POSITIONAT(ship, t).
	local spdV is VELOCITYAT(ship,t):SURFACE.
	local upV is (p - ship:BODY:POSITION):NORMALIZED.
	local ang is 90 - VANG(spdV,upV).

	local gts is MakeGravTSim(EnginesConsumption(),-MAXTHRUST).
	return gts:VelAng({parameter vx,vz,cml. return vz >= 0.},
		timeStep, spdV:MAG, ang).
}

