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
	
	local function Accel{
		parameter t,x,z,vx,vz.
		
		local br is (body:radius+z).
		local bg is body:mu/(br*br).
		local orbX is (vx+175).//175 is kerbin rotation
		local spd is SQRT(vx^2+vz^2).
		local ac is -dfc(t,z,spd)*shipMassK.
		local sk is ac/spd.

		return lexicon(
			"AX", vx*sk,
			"AZ", vz*sk - (bg - orbX*orbX/br)
		).
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

		local nst is Accel(st["T"],st["X"],st["Z"],st["VX"],st["VZ"]).
		set nst["T"] to st["T"]+dt.
	
		set nst["VX"] to st["VX"]+nst["AX"]*dt.
		set nst["VZ"] to st["VZ"]+nst["AZ"]*dt.
		
		set nst["X"] to st["X"]+(st["VX"]+nst["VX"])*dt/2.
		set nst["Z"] to st["Z"]+(st["VZ"]+nst["VZ"])*dt/2.

		return GravTStep(nst).
	}

	return lexicon("FromState", SimState@).
}