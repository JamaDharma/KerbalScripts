local epsilon is 0.0001^2.
function MakeFromToRot{
	parameter v1, v2.
	local axis is VCRS(v1,v2).
	if axis:SQRMAGNITUDE < epsilon 
		return R(0,0,0).
	local ang is VANG(v1,v2).
	return ANGLEAXIS(ang, axis).
}