RUNONCEPATH("0:/lib/Debug").
RUNONCEPATH("0:/lib/Ship/DeltaV").
RUNONCEPATH("0:/lib/Landing/TerminalVelocitySolver").

//controls trottle for soft touchdown while landing at terminal velocity
//for best results call when groundspeed is already low
function NewTerminalVelocityLandingControl {
    parameter landingSpeed is 3.
    set landingSpeed to ABS(landingSpeed).//positive

    //constants
    local bBox is ship:bounds.
    local landingAlt is GEOPOSITION:TERRAINHEIGHT.
    local landingGravity is LocalGravity(landingAlt).
    local landingPressure is BODY:ATM:ALTITUDEPRESSURE(landingAlt).
    local stCalc is StageCalculator(landingPressure).
    local maxBurnTime is stCalc:BurnTime().
    local accel is stCalc:Acceleration.

    //current runmode/state
    local mode is UpdateMode@.

    //control
    local thrustLevel is 0.
    LOCK THROTTLE to thrustLevel.
    LOCK STEERING to SRFRETROGRADE.

    //updatable state varibles
    local tSolver is 0.
    local burnHeight is 0.
    local burnETA is 0.

    Update().//initialization

    function Update {
        set tSolver to NewChuteSolver(landingGravity,accel).
        local burnTime is tSolver:TimeOfV(landingSpeed).
        NPrint("Required burn lenght", burnTime).
        if maxBurnTime < burnTime {
            NPrint("Maximum burn lenght", maxBurnTime).
            local minVel is MAX(0,-tSolver:Velocity(maxBurnTime)).
            NPrint("Minimum landing speed", minVel).
            set burnHeight to tSolver:Distance(maxBurnTime).
        } else {
            NPrint("Final velocity", tSolver:Velocity(burnTime)).
            set burnHeight to tSolver:Distance(burnTime).
        }
        //3 frame latency?
        set burnHeight to -(burnHeight+VERTICALSPEED/25).

        NPrint("Burn starts at height", burnHeight).
        NPrintMany("alt diff",ALT:radar-bBox:bottomaltradar).

        set burnETA to (burnHeight-bBox:bottomaltradar)/VERTICALSPEED.
        NPrint("Burn starts in", burnETA).
    }

    function UpdateMode {
        Update().
        if burnETA < 1.5 
            set mode to ReadyMode@.
        RETURN false.
    }

    function ReadyMode {
        if bBox:bottomaltradar <= burnHeight {
            set thrustLevel to 1.
            set mode to BurnMode@.
        }
        RETURN false.
    }

    function BurnMode {
        PRINT VERTICALSPEED.
        if -VERTICALSPEED <= landingSpeed {
            set mode to TouchMode@.
            LOCK STEERING to UP.
        }
        RETURN false.
    }

    function TouchMode {
        PRINT VERTICALSPEED.
        if SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED" {
            set thrustLevel to 0.
            RETURN true.//finished
        }
        set thrustLevel to landingGravity*MASS/MAXTHRUST*(9-VERTICALSPEED/landingSpeed)/10.
        RETURN false.
    }
    
    RETURN { RETURN mode(). }.
}