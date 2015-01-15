' Is this an HD tv

Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayType() = "HDTV" then return true
    return false
End Function

' Draws and fills the overhang
Function CreateOverhang(canvas)
	' Draw layer for header
 		headerLocation = {
  		x: 0,
  		y: 0,
  		w: 1280,
  		h: 121 }
  		
  		canvas.setLayer(1, {
  		color: "#1E1E1E",
  		targetRect: headerLocation
 		})
 		
 	' Draw Christian Media Logo
 	logo = [
 			{ 
            url:"pkg:/images/ccinema_logo.png"
            TargetRect:{x:61,y:34,w:254,h:82}
            }
        ]
    
    canvas.setLayer(10, logo)
  		
End Function

' Draw menu selection boxes
Function CreateSelectionBox(canvas, index)

    ' coordinates for HD display
    if (index = 1)
		newReleasesSelectionBox = {
  			x: 42,
  			y: 134,
  			w: 285,
  			h: 53 }
  		
  			canvas.setLayer(2, {
  			color: "#227AE6",
  			targetRect: newReleasesSelectionBox
 		})

    else if (index = 2)
		genreSelectionBox = {
  			x: 42,
  			y: 198,
  			w: 285,
  			h: 53 }
  		
  			canvas.setLayer(2, {
  			color: "#227AE6",
  			targetRect: genreSelectionBox
 		})
 		
 	else if (index = 3)
		themesSelectionBox = {
  			x: 42,
  			y: 262,
  			w: 285,
  			h: 53 }
  		
  			canvas.setLayer(2, {
  			color: "#227AE6",
  			targetRect: themesSelectionBox
 		})
 		
 	else if (index = 4)
		searchSelectionBox = {
  			x: 42,
  			y: 326,
  			w: 285,
  			h: 53 }
  		
  			canvas.setLayer(2, {
  			color: "#227AE6",
  			targetRect: searchSelectionBox
 		})
 		
 	else if (index = 5)
		searchSelectionBox = {
  			x: 42,
  			y: 390,
  			w: 285,
  			h: 53 }
  		
  			canvas.setLayer(2, {
  			color: "#227AE6",
  			targetRect: searchSelectionBox
 		})
    End If
End Function

' Draws the left navigation menu
Function CreateHomePageMenu(canvas, menuFont)

 menuTextAttributes = {
  color: "#F6F6F6"
  font: menuFont
  Halign: "Left"
  Valign: "Vcenter"
 }
 
 menuItems = []
 

 menuItems.Push({
  text: "New Releases",
  textAttrs: menuTextAttributes,
  targetRect: { x: 64, y: 155, w: 247, h: 25 }
 })
 
 menuItems.Push({
  text: "Genre",
  textAttrs: menuTextAttributes,
  targetRect: { x: 64, y: 218, w: 141, h: 25 }
 })
  
 menuItems.Push({
  text: "Themes",
  textAttrs: menuTextAttributes,
  targetRect: { x: 64, y: 281, w: 234, h: 25 }
 })
 
 menuItems.Push({
  text: "Search",
  textAttrs: menuTextAttributes,
  targetRect: { x: 64, y: 344, w: 218, h: 25 }
 })
 
 menuItems.Push({
  text: "My Account",
  textAttrs: menuTextAttributes,
  targetRect: { x: 64, y: 407, w: 218, h: 25 }
 })
 
 canvas.SetLayer(3, menuItems)
End Function

Function ShowContent(canvas, contentFont)
 	contentTextAttributes = {
  	color: "#656565"
  	font: contentFont
  	Halign: "Left"
  	Valign: "Vcenter"
 	}
 	
 	canvas.setLayer(6, {
  	 text: "Featured Movies",
  	 textAttrs: contentTextAttributes,
  	 targetRect: {
   	 x: 366, y: 153, w: 215, h: 25
  	 }
 	})
 
End Function

Function ShowMovieGrid(canvas)
	 movieRowOne = []
	 movieRowTwo = []
	 
	 ' First Row
	 movieRowOne.Push({
  		url:"http://www.christiancinema.com/catalog/images/3daytest_lg.jpg"
        TargetRect:{x:366,y:198,w:268,h:380}
 	 })
 	 
 	 movieRowOne.Push({
  		url:"http://www.christiancinema.com/catalog/images/christmassnow_spanish_lg.jpg"
        TargetRect:{x:656,y:198,w:268,h:380}
 	 })
 	 
 	 movieRowOne.Push({
  		url:"http://www.christiancinema.com/catalog/images/changetheheart_lg.jpg"
        TargetRect:{x:946,y:198,w:268,h:380}
 	 })
 	 
 	 ' Second Row
 	 
 	 movieRowTwo.Push({
  		url:"http://www.christiancinema.com/catalog/images/brotherwhite_lg.jpg"
        TargetRect:{x:366,y:600,w:268,h:380}
 	 })
 	 
 	  movieRowTwo.Push({
  		url:"http://www.christiancinema.com/catalog/images/courageous_dvd_lg.jpg"
        TargetRect:{x:656,y:600,w:268,h:380}
 	 })
 	 
 	  movieRowTwo.Push({
  		url:"http://www.christiancinema.com/catalog/images/hiddenrage_dvd_lg.jpg"
        TargetRect:{x:946,y:600,w:268,h:380}
 	 })
	 
	 canvas.SetLayer(11, movieRowOne)
	 canvas.SetLayer(12, movieRowTwo)
End Function

sub main()

 print "Roku thinks this is "; IsHD()
 
 canvas = CreateObject("roImageCanvas")
 canvas.setLayer(0, { color: "#000000" })
 
 ' setup a message port so we can receive event information
  port = CreateObject("roMessagePort")
  canvas.SetMessagePort(port)
  
  ' Do this once it is a costly operation
  reg = CreateObject("roFontRegistry")
  reg.Register("pkg:/fonts/SourceSansPro-Regular.ttf")
  sansFont = reg.GetFont("Sans Pro", 42, false, false)
 
 CreateOverhang(canvas)
 CreateHomePageMenu(canvas, sansFont)
 CreateSelectionBox(canvas, 1)
 ShowContent(canvas, sansFont)
 ShowMovieGrid(canvas)
 
 canvas.show()
 
 ' Setup menu indexes
 mainMenuIndex = 1
 
 ' Start our event loop
  while true
    msg = Wait(0, port) ' wait for an event

    if type(msg) = "roImageCanvasEvent"
      ' we got an image canvas event
      if (msg.isRemoteKeyPressed()) then
        	' Remote Key Map
      		' 2 = up
      		' 3 = down
      		' 4 = left
      		' 5 = right
      		' 6 = ok
      	
            i = msg.GetIndex()
            if (i = 2) ' up
                canvas.ClearLayer(2)
                
            	if (mainMenuIndex = 1)
            		mainMenuIndex = 5
            	else
            		mainMenuIndex = mainMenuIndex - 1
            	end if
            	
            	CreateSelectionBox(canvas, mainMenuIndex)
            else if (i = 3) ' down
            	canvas.ClearLayer(2)
            	
            	if (mainMenuIndex = 5)
            		mainMenuIndex = 1
            	else
            		mainMenuIndex = mainMenuIndex + 1
            	end if
            	
            	CreateSelectionBox(canvas, mainMenuIndex)
            end if 
      end if
      
      if msg.isScreenClosed()
        ' the user closed the screen
        exit while
      end if
    end if
  end while

' This will cause the channel to exit
canvas.close() 

end sub