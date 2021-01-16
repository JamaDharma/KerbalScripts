RUNONCEPATH("0:/lib/Debug").
local function DecayV{
	parameter oldV, myV.
	local cnt is 0.
	until cnt = myv:LENGTH{
		set oldV[cnt] to (oldV[cnt]*15+myV[cnt])/16.
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
local function UpdateGradient{
	parameter metric, oldMetric, cmp.
	local changer is cmp[1].
	local sStep is cmp[0]*downscale.
	
	local function CheckStep{
		parameter stepSize.
		if stepSize < epsilon {
			set cmp[0] to cmp[0]*1024.
			set cmp[2] to 0.
			return false.
		}
		return true.
	}
	
	if not CheckStep(sStep) return.
	
	changer(sStep).
	
	function TryUpdateGradient{
		local sampleStep is cmp[0]*downscale.
		
		if not CheckStep(sampleStep) {
			changer(sampleStep).
			return.
		}
		
		local newMetric is metric().
		local grd1 is (oldMetric-newMetric)/sampleStep.
		if ABS(grd1) < epsilon {
			set cmp[2] to 0.
			changer(sampleStep).
			return.
		}
		//NPrint("grd1",grd1).
		//NPrint("newMetric",newMetric).
		changer(-2*sampleStep).
		set newMetric to metric().
		local grd2 is -(oldMetric-newMetric)/sampleStep.
		

		//NPrint("grd2",grd2).
		//NPrint("newMetric",newMetric).
		//WaitKey().
		if ABS((grd1-grd2)/grd1) > 0.5 {
			set cmp[0] to sampleStep.
			changer(sampleStep+sampleStep*downscale).
			TryUpdateGradient().
		} else {
			set cmp[2] to (grd1+grd2)/2.
			changer(sampleStep).
		}
	}

	TryUpdateGradient().
}

local idVector is list(0,0,0,0,0,0,0,0,0,0,0,0,0).
local function UpdateGradients{
	parameter context.
	local metric is context[1].
	local cmps is context[2].
	local branch is context[3].
	
	branch(idVector).
	local baseMetric is metric().
	NPrint("baseMetric",baseMetric,10).
	for cmp in cmps {
		UpdateGradient(metric,baseMetric,cmp).
	}
}

local function MakeStep{
	parameter oldMetric, myV, context, upstep is false.
	local metric is context[1].
	local branch is context[3].
	local commit is context[4].
	local revert is context[5].
	
	if context[0] < 0.00001 {
		revert().
		return false.
	}
	
	branch(myV).
	local newMetric is metric().
	IF  newMetric < oldMetric { 
		commit().
	function prcom{
		print "---------commit----------".
		print myV.
		print "-------------------------".
		WaitKey().
	}
	//prcom().
		if upstep { set context[0] to context[0]*2. } 
		return true.
	}
	
	set context[0] to context[0]*0.5.
	MultV(0.5, myV).
	return MakeStep(oldMetric, myV, context, false).
}

local function GD{
	parameter context, oldV.
	
	local stepSize is context[0].
	local metric is context[1].
	local cmps is context[2].
	
	if stepSize < 0.0001 {
		print "Stepsize too small".
		return false.
	}
	
	local oldMetric is metric().
	
	UpdateGradients(context).
	local myV is list().
	for cmp in cmps{
		myV:ADD(cmp[2]).
	}
	DecayV(oldV,myV).
	
	if not SetVM(stepSize, myV) return false.

	local oldc is oldV:COPY.
	SetVM(stepSize, oldc).
	if MakeStep(oldMetric,oldc,context){
		set context[0] to stepSize.
		return true.	
	}
	
	return MakeStep(oldMetric,myV,context).
	
}

function GradientDescent{
	parameter context.
	local momentum is idVector:COPY.
	UNTIL not GD(context,momentum).
}
