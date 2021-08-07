RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/Ship/Engines").

function MakeAtmEntrySim{
	parameter dfc.
	
	local shipMassK is 1/MASS.
	
	local condition is { return vz < 0.}.
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

		if condition(vx,vz,cml){
			return lexicon(
				"VX", vx,
				"VZ", vz,
				"T", cml[0],
				"X", cml[1],
				"Z", cml[2]
			).
		}
		
		//[0, 1, 2]
		//[t, x, z]
		set cml[0] to cml[0]+dt.
		set cml[1] to cml[1]+vx*dt.
		set cml[2] to cml[2]+vz*dt.
		
		local br is (body:radius+cml[2]).
		local bg is body:mu/(br*br).
		local orbX is (vx+175).//175 is kerbin rotation
		local spd is SQRT(vx*vx+vz*vz).
		local accel is -dfc(cml[0],cml[2],spd)*shipMassK.
		local sk is accel/spd.

		local dvx is vx*sk.
		local dvz is vz*sk - (bg - orbX*orbX/br).	
		
		//NPrintL(lexicon("vX",vx,"vZ",vz)).
		//NPrintL(lexicon("Z",cml[1],"Z",cml[2])).
		//NPrint("accel",accel).
		//WaitKey().
		return GravTStep(vx+dvx*dt, vz+dvz*dt, cml).
	}

	return lexicon(
		"VelAng", SimVelAng@,
		"FromState", SimState@).
}