function StagingTriggerController {
    parameter count.

    PRINT "Staging "+count+" times".
    
    function MakeTrigger {
        if count <= 0 RETURN.

        set count to count-1.
        WHEN STAGE:READY THEN {
            local res is STAGE:Resourceslex.
            WHEN res["LiquidFuel"]:amount<=0.5 and res["SolidFuel"]:amount<=0.5 THEN {
                STAGE.
                MakeTrigger().
            }
        }
    }

    MakeTrigger().
}