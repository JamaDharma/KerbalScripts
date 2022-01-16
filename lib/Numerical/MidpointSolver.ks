RUNONCEPATH("0:/lib/Debug").

function NewMidpoint1Solver {
	parameter dt.
	parameter accel.
	
	local function Solver {
		
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

	return Solver@.
}

function NewMidpoint2Solver {
	parameter dt.
	parameter accel.
	
	local function Solver {
		
		parameter st.
		
		local hdt is dt/2.
		local ma is Accel(
			st["T"]+hdt,
			st["P"]+st["V"]*hdt,
			st["V"]+st["A"]*hdt
		).
			
		local nst is lexicon(
			"T",st["T"]+dt,
			"P",st["P"]+(st["V"]+ma*hdt)*dt,
			"V",st["V"]+ma*dt
		).

		set nst["A"] to 	Accel(nst["T"],nst["P"],nst["V"]).
		
		return nst.
	}

	return Solver@.
}