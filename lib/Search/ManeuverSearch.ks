RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/GradientDescent").

function MakeMSearcher {
	parameter metric, timeScale, mainTime.

	local branchTime is mainTime.
	local mainNode is NEXTNODE.
	local branchNode is mainNode.

	function Branch{
		parameter myV.

		set branchTime to mainTime + myV[0]*timeScale.
		set branchNode to NODE(
			time:SECONDS+mainNode:ETA+myV[1]*timeScale,
			mainNode:RADIALOUT+myV[3],
			mainNode:NORMAL+myV[4],
			mainNode:PROGRADE+myV[2]).
		REMOVE NEXTNODE.
		ADD branchNode.
		wait 0.
	}
	function Commit{
		set mainTime to branchTime.
		set mainNode to branchNode.
	}
	function Revert{
		set branchTime to mainTime.
		set branchNode to mainNode.
		REMOVE NEXTNODE.
		ADD mainNode.
		wait 0.
	}
	
	local minTimeStep is timeScale/10.
	local minBurnStep is 0.1.
	local componentList is LIST(
		LIST(
			minTimeStep,
			{
				parameter dT.
				set branchTime to branchTime+dT*timeScale.
			},
			0
		),
		LIST(
			minTimeStep,
			{
				parameter dX.
				set NEXTNODE:ETA to NEXTNODE:ETA+dX*timeScale.
			},
			0
		),
 		LIST(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
			},
			0
		),
		LIST(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:RADIALOUT to NEXTNODE:RADIALOUT+dX.
			},
			0
		),
		LIST(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX.
			},
			0
		)
	).
	
	function RunSearch{
		parameter stepsize.
		local context is list(
			stepsize,
			metric,
			componentList,
			Branch@, Commit@, Revert@).
		
		GradientDescent(context).
	}
	
	local this is lexicon(
		"TrgTime", { return branchTime.},
		"GO", RunSearch@
	).
	
	return this.
}

function MakeProgradeSearcher {
	parameter metric, timeScale, mainTime.

	local branchTime is mainTime.
	local mainNode is NEXTNODE.
	local branchNode is mainNode.

	function Branch{
		parameter myV.

		set branchTime to mainTime + myV[0]*timeScale.
		set branchNode to NODE(
			time:SECONDS+mainNode:ETA,
			mainNode:RADIALOUT,
			mainNode:NORMAL,
			mainNode:PROGRADE+myV[1]).
		REMOVE NEXTNODE.
		ADD branchNode.
		wait 0.
	}
	function Commit{
		set mainTime to branchTime.
		set mainNode to branchNode.
	}
	function Revert{
		set branchTime to mainTime.
		set branchNode to mainNode.
		REMOVE NEXTNODE.
		ADD mainNode.
		wait 0.
	}
	
	local minTimeStep is timeScale/10.
	local minBurnStep is 0.1.
	local componentList is LIST(	LIST(
			minTimeStep,
			{
				parameter dT.
				set branchTime to branchTime+dT*timeScale.
			},
			0
		), LIST(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
			},
			0
		)
	).
	
	function RunSearch{
		parameter stepsize.
		local context is list(
			stepsize,
			metric,
			componentList,
			Branch@, Commit@, Revert@).
		
		GradientDescent(context).
	}
	
	local this is lexicon(
		"TrgTime", { return branchTime.},
		"GO", RunSearch@
	).
	
	return this.
}
