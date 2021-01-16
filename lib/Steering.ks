function SetSteering{
	parameter value.
	set STEERINGMANAGER:MAXSTOPPINGTIME to 5*value.
	set STEERINGMANAGER:PITCHPID:KD to value.
	set STEERINGMANAGER:YAWPID:KD to value.
}

function Hippo{
	SetSteering(1).
}
function Whale{
	SetSteering(10).
}