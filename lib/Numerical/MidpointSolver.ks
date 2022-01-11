RUNONCEPATH("0:/lib/Debug").

function NewMidpoint1Solver {
	parameter dt.
	parameter accel.
	
	local function Midpoint1Solver {
		
		parameter st.
		
		local hdt is dt/2.
		local nst is lexicon( "A", Accel(
			st["T"]+hdt,
			st["P"]+st["V"]*hdt,
			st["V"]+st["A"]*hdt)).

		set nst["T"] to st["T"]+dt.

		set nst["V"] to st["V"]+nst["A"]*dt.

		set nst["P"] to st["P"]+(st["V"]+nst["V"])*hdt.
		
		return nst.
	}

	return Midpoint1Solver@.
}


function MakeMidpoint1Solver{

	local function SimStateStep{
		parameter accel, sSt, timeStep.
		
		local ca is accel(sSt["T"],sSt["X"],sSt["Z"],sSt["VX"],sSt["VZ"]). 
		set sSt["AX"] to ca["AX"].
		set sSt["AZ"] to ca["AZ"].
		
		return GravTStep(accel, sSt, timeStep).
	}
	
	local function GravTStep{
		parameter accel, st, dt.

		local hdt is dt/2.
		local nst is accel(
			st["T"]+hdt,
			st["X"]+st["VX"]*hdt,
			st["Z"]+st["VZ"]*hdt,
			st["VX"]+st["AX"]*hdt,
			st["VZ"]+st["AZ"]*hdt).

		set nst["T"] to st["T"]+dt.
	
		set nst["VX"] to st["VX"]+nst["AX"]*dt.
		set nst["VZ"] to st["VZ"]+nst["AZ"]*dt.
		
		set nst["X"] to st["X"]+(st["VX"]+nst["VX"])*hdt.
		set nst["Z"] to st["Z"]+(st["VZ"]+nst["VZ"])*hdt.
		
		return nst.
	}

	return lexicon("AdvanceStateT", SimStateStep@).
}