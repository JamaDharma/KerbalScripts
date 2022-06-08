function LocalGravity {
    parameter hght is ALTITUDE.
    return BODY:MU/(BODY:RADIUS+hght)^2.
}
