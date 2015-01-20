Library "v30/bslCore.brs"

sub main()
 ' Is this a standard or HD display
 print "Screen Type: ";IsHD()
 
 ' Define font, do this once it is a costly operation
 reg = CreateObject("roFontRegistry")
 reg.Register("pkg:/fonts/SourceSansPro-Regular.ttf")
 sansFont = reg.GetFont("Source Sans Pro", 42, false, false)
 
 screen = CreateObject("roScreen",true)
  
' Header
 img = CreateObject("roBitmap", "pkg:/images/ccinema_logo.png")

 screen.DrawRect(0, 0, 1280, 121, &H1E1E1EFF)
 screen.DrawScaledObject(61, 34, 0.25, 0.25, img) 
 
 ' Draw Sub-Category
 screen.DrawText("Featured Movies", 366, 153, &H5E5E5EFF, sansFont)
  
 ' Draw Menu
 screen.DrawText("New Release", 64, 155, &HFFFFFFFF, sansFont) 
 screen.DrawText("Genre", 64, 218 , &HFFFFFFFF, sansFont) 
 screen.DrawText("Themes", 64, 281, &HFFFFFFFF, sansFont) 
 screen.DrawText("Search", 64, 344, &HFFFFFFFF, sansFont) 
 screen.DrawText("My Account", 64, 407, &HFFFFFFFF, sansFont) 
 
 a_url = [ 
                "http://www.christiancinema.com/catalog/images/3daytest_lg.jpg",
 				"http://www.christiancinema.com/catalog/images/christmassnow_spanish_lg.jpg",
 				"http://www.christiancinema.com/catalog/images/changetheheart_lg.jpg",
 				"http://www.christiancinema.com/catalog/images/brotherwhite_lg.jpg",
 				"http://www.christiancinema.com/catalog/images/courageous_dvd_lg.jpg",
 				"http://www.christiancinema.com/catalog/images/hiddenrage_dvd_lg.jpg"
 		 ]
 				
 fetched_bitmaps = FetchBitmaps(a_url)

 ' Draw Movie Posters
 current_movie = 0
 poster_columns = 3
 poster_height = 285
 poster_row_pad = 50
 poster_width = 201
 poster_column_pad = 50
 
 l_width =  poster_width + poster_column_pad
 l_x = 366
 l_y = 220
 
 For each bitmap in fetched_bitmaps
   screen.DrawScaledObject( l_x, l_y, 0.75, 0.75, bitmap.Bitmap )
   l_x = l_x + l_width
   current_movie = current_movie + 1
   if (current_movie = poster_columns)
        l_x = 366
   		l_y = l_y + (poster_height + poster_row_pad)
   		current_movie = 0
   end if
 end for

 screen.swapbuffers() 
 
 msgport = CreateObject("roMessagePort")
 screen.SetMessagePort(msgport)
 
 codes = bslUniversalControlEventCodes()
 
 ' Start our event loop
   while true
   msg = Wait(0, msgport)
        if type(msg) = "roUniversalControlEvent" then
                keypressed = msg.GetInt()
                if keypressed = codes.BUTTON_UP_PRESSED then
                	print "Up pressed"
                	
                else if keypressed = codes.BUTTON_DOWN_PRESSED then
                	print "Down pressed"
                	
                else if keypressed = codes.BUTTON_RIGHT_PRESSED then
                	print "Right pressed"
                	
                else if keypressed = codes.BUTTON_LEFT_PRESSED then
                	print "Left pressed"
                	
                else if keypressed = codes.BUTTON_BACK_PRESSED then
                	print "Back pressed"
                	
                end if
        end if
    end while

end sub