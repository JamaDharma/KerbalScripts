RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Search/GradientDescent").
RUNONCEPATH("0:/lib/Search/OneStepMomentum").
RUNONCEPATH("0:/lib/Search/OneStepOptimization").

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
	
	local minTimeStep is 0.1/timeScale.
	local minBurnStep is 0.01.
	local componentList is LIST(
		MakeSearchComponent(
			1, minTimeStep,
			{	
				parameter dT.
				set branchTime to branchTime+dT*timeScale.
			}
		),MakeSearchComponent(
			1, minTimeStep,
			{
				parameter dX.
				set NEXTNODE:ETA to NEXTNODE:ETA+dX*timeScale.
			}
		),MakeSearchComponent(
			1, minBurnStep,
			{
				parameter dX.
				set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
			}
		),MakeSearchComponent(
			1, minBurnStep,
			{
				parameter dX.
				set NEXTNODE:RADIALOUT to NEXTNODE:RADIALOUT+dX.
			}
		),MakeSearchComponent(
			1, minBurnStep,
			{
				parameter dX.
				set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX.
			}
		)
	).
	
	function RunSearch{
		parameter stepsize.
		local context is list(
			stepsize,
			metric,
			componentList,
			Branch@, Commit@, Revert@).
		
		OneStepMomentum(context).
	}
	
	local this is lexicon(
		"TrgTime", { return branchTime.},
		"GO", RunSearch@
	).
	
	return this.
}

function MakeBurnSearcher {
	parameter metric.

	local mainNode is NEXTNODE.
	local branchNode is mainNode.

	function Branch{
		parameter myV.

		set branchNode to NODE(
			time:SECONDS+mainNode:ETA,
			mainNode:RADIALOUT+myV[1],
			mainNode:NORMAL+myV[2],
			mainNode:PROGRADE+myV[0]).
		REMOVE NEXTNODE.
		ADD branchNode.
		wait 0.
	}
	function Commit{
		set mainNode to branchNode.
	}
	function Revert{
		set branchNode to mainNode.
		REMOVE NEXTNODE.
		ADD mainNode.
		wait 0.
	}
	
	local minBurnStep is 0.01.
	local componentList is LIST(
		MakeGDComponent(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
			}
		),  MakeGDComponent(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:RADIALOUT to NEXTNODE:RADIALOUT+dX.
			}
		),MakeGDComponent(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:NORMAL to NEXTNODE:NORMAL+dX.
			}
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
	local componentList is LIST(	
		MakeGDComponent(
			minTimeStep,
			{
				parameter dT.
				set branchTime to branchTime+dT*timeScale.
			}
		), MakeGDComponent(
			minBurnStep,
			{
				parameter dX.
				set NEXTNODE:PROGRADE to NEXTNODE:PROGRADE+dX.
			}
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
