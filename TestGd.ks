RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/GradientDescent").

local mainTime is 0.
local branchTime is mainTime.
local mainSpd is 0.
local branchSpd is mainSpd.

function mtric{
	return (branchTime-10)^2+(branchSpd*branchTime-20)^2.
}

function Branch{
	parameter myV.

	set branchTime to mainTime + myV[0].
	set branchSpd to mainSpd + myV[1].
	//log "t: "+branchTime+" s: "+mainSpd to "gdtst.txt".
}
function Commit{
	set mainTime to branchTime.
	set mainSpd to branchSpd.
	//log "result vector t: "+mainTime+" s: "+mainSpd to "gdtst.txt".
	NPrint("mainTime",mainTime).	
	NPrint("mainSpd",mainSpd).	
}
function Revert{
	set branchTime to mainTime.
	set branchSpd to mainTime.
}

local context is list(
	1/4,
	mtric@,
	list(MakeGDComponent(
			0.1,
			{
				parameter dT.
				NPrint("dT",dT).
				set branchTime to branchTime+dT.
			}
		),MakeGDComponent(
			0.1,
			{
				parameter dS.
				NPrint("dS",dS).				
				set branchSpd to branchSpd+dS.
			}
		)),
	Branch@, Commit@, Revert@).

GradientDescent(context).