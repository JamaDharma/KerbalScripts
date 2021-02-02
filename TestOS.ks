RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/OneStepMomentum").
RUNONCEPATH("0:/lib/Search/OneStepOptimization").

function RunTest{
	parameter optF.
	
	local mainTime is 20.
	local branchTime is mainTime.
	local mainSpd is 100.
	local branchSpd is mainSpd.
	
	local updCount is 0.
	local evalCount is 0.
	
	function Metric{
		set evalCount to evalCount+1.
		return (branchTime-10)^2+(branchSpd*branchTime-20)^2.
	}
	
	local context is list(
		1,
		Metric@,
		list(MakeSearchComponent(
				1,
				0.001,
				{
					parameter dT.
					set updCount to updCount+1.
					//NPrint("dT",dT).
					//NPrint("branchTime",branchTime).
					//NPrint("mtric",mtric()).
					set branchTime to branchTime+dT.
				}
			),MakeSearchComponent(
				1,
				0.001,
				{
					parameter dS.
					set updCount to updCount+1.
					//NPrint("dS",dS).				
					//NPrint("branchSpd",branchSpd).				
					set branchSpd to branchSpd+dS.
				}
			))).
			
	local startTime is time.
	optF(context).
	local duration is time - startTime.
	
	NPrint("branchTime",branchTime).
	NPrint("branchSpd",branchSpd).
	NPrint("Metric",Metric(),5).
	NPrint("updCount",updCount).
	NPrint("evalCount",evalCount).
	NPrint("duration",duration:SECONDS).
}
//2088 2949 19.86 OneStepOptimization
//2088 2949 20.44 OneStepMomentum overhead
//2088 2399 20.62 - passing metric
//1635 2082 20.94 - momentum
//1094 1088 14.24 - momentum upstep
RunTest(OneStepMomentum@).
