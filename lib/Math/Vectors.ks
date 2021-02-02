function WeightedUpdate{
	parameter oldW, newW, oldV, newV.
	FROM {local i is 0.} UNTIL i = newV:LENGTH STEP {set i to i+1.} DO {
		set oldV[i] to (oldV[i]*oldW+newV[i]*newW)/(oldW+newW).
	}
}
function MultplyVector{
	parameter myV, factor.
	FROM {local i is 0.} UNTIL i = myv:LENGTH STEP {set i to i+1.} DO {
		set myV[i] to myV[i]*factor.
	}
}
function SetVectorMagnitude{
	parameter  myV, newMag.
	local sqMag is 0.
	for cmp in myV{
		set sqMag to sqMag + cmp*cmp.
	}
	if sqMag = 0 return false.
	MultplyVector(myV, newMag/SQRT(sqMag)).
	return true.
}