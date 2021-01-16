
function Gravity {
	// negavive magnitude to up vector is down.
	return -(body:mu/(body:radius+ship:altitude)^2)*up:vector.
}

function Weight {
	return ship:mass*Gravity().
}

function Thrst {
	return MAXTHRUST * THROTTLE * ship:facing:vector.
}

function Drag {
	local M is ship:mass.
	local a is ship:sensors:acc.
	local resultant is M * ( a - Gravity() ) - Thrst().
	return resultant.
}.

function Loss {
	parameter force.
	local forceProjection is force * COS(VANG(force, SRFRETROGRADE:VECTOR)).
	return forceProjection:MAG.
}

function DragLoss {
	return Loss(Drag()).
}

function GravLoss {
	return Loss(Gravity()*SHIP:MASS).
}

function SteerLoss {
	return Thrst():MAG - Loss(Thrst()).
}