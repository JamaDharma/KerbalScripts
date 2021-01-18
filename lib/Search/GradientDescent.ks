RUNONCEPATH("0:/lib/Debug").
local function DecayV{
	parameter oldV, myV.
	local cnt is 0.
	until cnt = myv:LENGTH{
		set oldV[cnt] to (oldV[cnt]*7+myV[cnt])/8.
		set cnt to cnt + 1.
	}
}
local function MultV{
	parameter factor, myV.
	local cnt is 0.
	until cnt = myv:LENGTH{
		set myV[cnt] to myV[cnt]*factor.
		set cnt to cnt + 1.
	}
}

local function SetVM{
	parameter newMag, myV.
	local sqMag is 0.
	for cmp in myV{
		set sqMag to sqMag + cmp^2.
	}
	if sqMag = 0 return false.
	MultV(newMag/SQRT(sqMag), myV).
	return true.
}

local epsilon is 1/1000000.
local downscale is 1/8.
local function CalculateGradient{
	parameter metric, oldMetric, cmp.
	local changer is cmp:Changer.

	function TryCalculateGradient{
		parameter sampleStep.
		
		if sampleStep < epsilon {
			changer(-sampleStep).
			return 0.
		}
		
		local newMetric is metric().
		local grd1 is (oldMetric-newMetric)/sampleStep.
		if ABS(grd1) < epsilon {
			changer(-sampleStep).
			return 0.
		}

		changer(-2*sampleStep).
		set newMetric to metric().
		local grd2 is -(oldMetric-newMetric)/sampleStep.
		
		if ABS(grd1-grd2)/MAX(ABS(grd1),ABS(grd2)) > 0.5 {
			changer(sampleStep+sampleStep*downscale).
			return TryCalculateGradient(sampleStep*downscale).
		} else {
			changer(sampleStep).
			return (grd1+grd2)/2.
		}
	}

	local sStep is cmp:MinimumStep*downscale.
	changer(sStep).
	return TryCalculateGradient(sStep).
}

local idVector is list(0,0,0,0,0,0,0,0,0,0,0,0,0).
local function CalculateGradients{
	parameter context.
	local metric is context[1].
	local cmps is context[2].
	local branch is context[3].
	
	branch(idVector).
	local baseMetric is metric().
	local result is list().
	for cmp in cmps {
		result:ADD(CalculateGradient(metric,baseMetric,cmp)).
	}
	return result.
}

local function MakeStep{
	parameter oldMetric, myVStep, myV, context, upstep is false.
	local metric is context[1].
	local branch is context[3].
	local commit is context[4].
	local revert is context[5].
	
	if myVStep < 0.00001 {
		revert().
		return false.
	}
	
	branch(myV).
	local newMetric is metric().
	IF  newMetric < oldMetric { 
		if upstep { 
			MultV(2, myV).
			MakeStep(oldMetric, myVStep*2, myV, context, true).
			return true.
		} 
		set context[0] to myVStep.
		commit().
		return true.
	}
	
	MultV(0.5, myV).
	return MakeStep(oldMetric, myVStep/2, myV, context, false).
}

local function GD{
	parameter context, oldV.
	
	local stepSize is context[0].
	local metric is context[1].
	local cmps is context[2].
	
	local oldMetric is metric().
	
	local myV is CalculateGradients(context).
	DecayV(oldV,myV).
	
	NPrint("metric",oldMetric).
	print myV.
	
	if not SetVM(stepSize, myV) return false.
	
	local oldC is oldV:COPY.
	SetVM(stepSize, oldC).
	if MakeStep(oldMetric,stepSize,oldC,context,true){
		print "momentum".
		return true.	
	}
	
	return MakeStep(oldMetric,stepSize,myV,context).
	
}

local vectorComponent to lexicon(
	"MinimumStep",0.1,
	"Changer",	{
		parameter dX.
		PRINT "change value of parameter by dX".
	},
	"DefaultStep", 1
).
function MakeGDComponent{
	parameter minStep, changer.
	return lexicon(
		"MinimumStep", minStep,
		"Changer", changer
	).
}
function GradientDescent{
	parameter context.
	local momentum is idVector:COPY.
	UNTIL not GD(context,momentum).
}
