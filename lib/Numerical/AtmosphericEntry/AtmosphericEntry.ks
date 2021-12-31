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
		
		return GravTStep(st).
	}

	local function GravTStep{
		parameter st.//st["VX"],st["VZ"],st["T"],st["X"],st["Z"]
		
		if (st["Z"]+st["VZ"]*dt)<exitHeight {
			local lastStep is (exitHeight-st["Z"])/st["VZ"].
			return lexicon(
				"VX", st["VX"],
				"VZ", st["VZ"],
				"T", st["T"]+lastStep,
				"X", st["X"]+st["VX"]*lastStep,
				"Z", st["Z"]+st["VZ"]*lastStep
			).
		}
		
		//[0, 1, 2]
		//[t, x, z]
		local nst is lexicon().
		set nst["T"] to st["T"]+dt.
		set nst["X"] to st["X"]+st["VX"]*dt.
		set nst["Z"] to st["Z"]+st["VZ"]*dt.
		
		local br is (body:radius+st["Z"]).
		local bg is body:mu/(br*br).
		local orbX is (st["VX"]+175).//175 is kerbin rotation
		local spd is SQRT(st["VX"]^2+st["VZ"]^2).
		local accel is -dfc(st["T"],st["Z"],spd)*shipMassK.
		local sk is accel/spd.

		local dvx is st["VX"]*sk.
		local dvz is st["VZ"]*sk - (bg - orbX*orbX/br).
		
		set nst["T"] to st["T"]+dt.
	
		set nst["VX"] to st["VX"]+dvx*dt.
		set nst["VZ"] to st["VZ"]+dvz*dt.
		
		set nst["X"] to st["X"]+(st["VX"]+nst["VX"])*dt/2.
		set nst["Z"] to st["Z"]+(st["VZ"]+nst["VZ"])*dt/2.

		return GravTStep(nst).
	}

	return lexicon("FromState", SimState@).
}