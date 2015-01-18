' Is this an HD tv

function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayType() = "HDTV" then return true
    return false
End function

function scale(scalefactor as float, destregion as object, sourceregion as object) as object
    sourceregion.SetAlphaEnable(true)
    destregion.SetAlphaEnable(true)
    destregion.setscalemode(1)
    destregion.clear(&h00000000)
   
    ww=sourceregion.getwidth()*scalefactor
    w=destregion.getwidth()
    hh=sourceregion.getheight()*scalefactor
    h=destregion.getheight()
   
    xOffset=(w/2)-(ww/2)
    yoffset=(h/2)-(hh/2)
    ?"Yoffset:";yoffset;" xOffset:";xoffset   
    destregion.drawscaledobject(xOffset,yOffset,scalefactor,scalefactor,sourceregion)
    ' destregion.finish()
    ' destregion.swapbuffers();
end function