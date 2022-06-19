RUNONCEPATH("0:/lib/Overfly").

parameter tOver is -1.//ETA in minutes 
//FlyOverPolar().
if tOver > 0 {
    FlyOverM(tOver*60).
} else {
    FlyOverM().
}

