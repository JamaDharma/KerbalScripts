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
		set st["AX"] to 0.
		set st["AZ"] to 0.
		
		return GravTStep(lexicon(
			"T", st["T"],
			"P", V(st["X"],0,st["Z"]),
			"V", V(st["VX"],0,st["VZ"]),
			"A", V(0,0,0)
		)).
	}
	
	local function Accel{
		parameter t,pos,vel.
		
		local br is (body:radius+pos:Z).
		local bg is body:mu/(br*br).
		local orbX is (vel:X+175).//175 is kerbin rotation
		local spd is vel:MAG.
		local ac is -dfc(t,pos:Z,spd)*shipMassK.
		local sk is ac/spd.

		return V(vel:X*sk, 0, vel:Z*sk - (bg - orbX*orbX/br)).
	}

	local function GravTStep{
		parameter st.//st["VX"],st["VZ"],st["T"],st["X"],st["Z"]
		
		if (st["P"]:z+st["V"]:z*dt)<exitHeight {
			local lastStep is (exitHeight-st["P"]:z)/st["V"]:z.
			return lexicon(
				"VX", st["V"]:X,
				"VZ", st["V"]:Z,
				"T", st["T"]+lastStep,
				"X", st["P"]:X+st["V"]:X*lastStep,
				"Z", st["P"]:Z+st["V"]:Z*lastStep
			).
		}

		local hdt is dt/2.
		local nst is lexicon( "A", Accel(
			st["T"]+hdt,
			st["P"]+st["V"]*hdt,
			st["V"]+st["A"]*hdt)).

		set nst["T"] to st["T"]+dt.

		set nst["V"] to st["V"]+nst["A"]*dt.
		
		set nst["P"] to st["P"]+(st["V"]+nst["V"])*hdt.

		return GravTStep(nst).
	}

	return lexicon("FromState", SimState@).
}