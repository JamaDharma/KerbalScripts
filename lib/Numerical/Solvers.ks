RUNONCEPATH("0:/lib/Debug").

function NewMidpoint1Solver {
	parameter dt.
	parameter accel.
	
	local function Solver {
		
		parameter st.
		
		local hdt is dt/2.
		local ma is accel(
			st["T"]+hdt,
			st["P"]+st["V"]*hdt,
			st["V"]+st["A"]*hdt
		).
			
		local nst is lexicon(
			"T",st["T"]+dt,
			"P",st["P"]+(st["V"]+ma*hdt)*dt,
			"V",st["V"]+ma*dt
		).

		set nst["A"] to 	ma.
		
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
		local ma is accel(
			st["T"]+hdt,
			st["P"]+st["V"]*hdt,
			st["V"]+st["A"]*hdt
		).
			
		local nst is lexicon(
			"T",st["T"]+dt,
			"P",st["P"]+(st["V"]+ma*hdt)*dt,
			"V",st["V"]+ma*dt
		).

		set nst["A"] to 	accel(nst["T"],nst["P"],nst["V"]).
		
		return nst.
	}

	return Solver@.
}

function NewRunge3Solver {
	parameter dt.
	parameter accel.
	
	local function Solver {
		parameter st.
		
		local hdt is dt/2.
		local t0 is st["T"].
		local v0 is st["V"].
		local p0 is st["P"].
		
		local v1 is v0+st["A"]*hdt.
		local a1 is accel(t0+hdt,p0+v0*hdt,v1).
		local v2 is v0+a1*hdt.
		local a2 is accel(t0+hdt,p0+v1*hdt,v2).
		local v3 is v0+a2*dt.
		local a3 is accel(t0+dt,p0+v2*dt,v3).		
			
		local nst is lexicon(
			"T",t0+dt,
			"P",p0+(v0+2*v1+2*v2+v3)*dt/6,
			"V",v0+(st["A"]+2*a1+2*a2+a3)*dt/6,
			"A",a3
		).

		return nst.
	}

	return Solver@.
}

function NewRunge4Solver {
	parameter dt.
	parameter accel.
	
	local function Solver {
		parameter st.
		
		local hdt is dt/2.
		local t0 is st["T"].
		local v0 is st["V"].
		local p0 is st["P"].
		
		local v1 is v0+st["A"]*hdt.
		local a1 is accel(t0+hdt,p0+v0*hdt,v1).
		local v2 is v0+a1*hdt.
		local a2 is accel(t0+hdt,p0+v1*hdt,v2).
		local v3 is v0+a2*dt.
		local a3 is accel(t0+dt,p0+v2*dt,v3).		
			
		local nst is lexicon(
			"T",t0+dt,
			"P",p0+(v0+2*v1+2*v2+v3)*dt/6,
			"V",v0+(st["A"]+2*a1+2*a2+a3)*dt/6
		).

		set nst["A"] to 	accel(nst["T"],nst["P"],nst["V"]).
		
		return nst.
	}

	return Solver@.
}
