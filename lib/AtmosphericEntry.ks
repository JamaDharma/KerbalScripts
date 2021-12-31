RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Atmosphere").
RUNONCEPATH("0:/lib/Ship/Engines").

function MakeAtmEntrySim{
	parameter dfc.
	parameter shipMass is MASS.
	 
	local shipMassK is 1/shipMass.
	
	local exitHeight is 500.
	local dt is 1.
	

	local function SimState{
		parameter exitH, timeStep.
		parameter st.
		
		set exitHeight to exitH.
		set dt to timeStep.
		
		return GravTStep(st["VX"],st["VZ"],list(st["T"],st["X"],st["Z"])).
	}

	local function GravTStep{
		parameter vx,vz.
		parameter cml.
		
		if (cml[2]+vz*dt)<exitHeight {
			local lastStep is (exitHeight-cml[2])/vz.
			return lexicon(
				"VX", vx,
				"VZ", vz,
				"T", cml[0]+lastStep,
				"X", cml[1]+vx*lastStep,
				"Z", cml[2]+vz*lastStep
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

	return lexicon("FromState", SimState@).
}