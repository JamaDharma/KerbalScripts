RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/OneStepOptimization").

local mainTime is 0.
local branchTime is mainTime.
local mainSpd is 0.
local branchSpd is mainSpd.

local updCount is 0.
local evalCount is 0.
function mtric{
	set evalCount to evalCount+1.
	return (branchTime-10)^2+(branchSpd*branchTime-20)^2.
}

local context is list(
	1/4,
	mtric@,
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
//737-720 upstep
OneStepSearch(context).
PRINT branchTime.
PRINT branchSpd.
PRINT mtric().
PRINT "upd "+updCount.
PRINT "evl "+evalCount.