local draws is LIST().
function MarkSpot {
    parameter spot.
    parameter color.
    draws:ADD(VECDRAW(
        {RETURN spot:POSITION.},
        {RETURN (spot:ALTITUDEPOSITION(0) - BODY:POSITION):NORMALIZED*10000.},
        color,"",2,true)
    ).
}

function ClearMarks{
    for d in draws{
        set d:SHOW to FALSE. 
    }
    set draws to LIST().
}