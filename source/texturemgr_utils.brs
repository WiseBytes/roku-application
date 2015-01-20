Function FetchBitmaps(a_url)

	l_textureList = CreateObject( "roArray", a_url.Count(), False )

	for each url in a_url
 		l_textureList.Push( NewTextureObject( url ) )
	end for
	
	l_textureManager = NewTextureManager()
    l_textureManager.Reset()
    
    ' For each texture in the list request it from the manager
    for each l_texture in l_textureList
      l_textureManager.RequestTexture( l_texture )
    end for
   
    ' Ask the manager to poll for the textures
    l_textureManager.PollTextures()
    
    return l_textureList
End Function


' Add this function to test the code
Function TextureTest() As Void

    ' This directory is temporary and will be available for testing
    l_url = "http://s3.amazonaws.com/NMLiving/texture_test/"
   
   ' I have created 25 simple textures texture1.jpg to texture25.jpg
    l_textureList = CreateObject( "roArray", 25, False )
   
   ' Create the url, the textureobject and push onto the texture list
   for l_i = 1 to 25
      l_turl = l_url + "texture" + l_i.ToStr() + ".jpg"
      l_textureList.Push( NewTextureObject( l_turl ) )
   end for
   
   ' Create an instance of the texturemanager and reset (optional)
   ' However you should know when to reset
   l_textureManager = NewTextureManager()
   l_textureManager.Reset()
   
   print "REQUESTING"
   print "============================================================="
   
   ' For each texture in the list request it from the manager
   for each l_texture in l_textureList
      l_textureManager.RequestTexture( l_texture )
   end for
   
   print ""
   print "RECEIVING"
   print "============================================================"
   
   ' Ask the manager to poll for the textures
   l_textureManager.PollTextures()
   
   ' Verify that we have a valid bitmap for each texture
   for each l_texture in l_textureList
      print type( l_texture.Bitmap )
   end for
   
   
End Function


' Creates a texture cache object which contains the returned bitmap, the textureRequest
' a Url and a resend count
Function NewTextureObject( a_url As String ) As Object
   return { Bitmap: Invalid, TRequest: Invalid, TUrl: a_url, ResendCount: 0 }
End Function

' Very stripped down version of my own manager.  This version offers only polling
' you would not use polling to populate a grid during realtime scrolling on for preloading
Function NewTextureManager() As Object

   tl = CreateObject( "roAssociativeArray" )
   
   tl.TManager = CreateObject( "roTextureManager" )
   tl.TMPort   = CreateObject( "roMessagePort" )
   tl.TManager.SetMessagePort( tl.TMPort )
   
   tl.RequestList = CreateObject( "roAssociativeArray" )
   
   tl.SendCount = 0
   tl.ReceiveCount = 0
   
   tl.STATE_READY   = 3
   tl.STATE_FAILED  = 4
   
   tl.AddItem    = tl_add_item
   tl.RemoveItem = tl_remove_item
   tl.Reset = tl_reset
   
   tl.RequestTexture = tl_request_texture
   tl.ReceiveTexture = tl_receive_texture
   tl.PollTextures   = tl_poll_textures
   
   return tl
   
End Function

' Adds an item to the list and increments the list count. The key is the textures id
Function tl_add_item( a_ID As Integer, a_value As DYNAMIC ) As Void
   m.RequestList.AddReplace( a_ID.ToStr(), a_value )
   m.ListCount = m.ListCount + 1
End Function

' Removes an item from the list, decrements the count
Function tl_remove_item( a_ID As Integer ) As Object
 
   l_key   = a_ID.ToStr()
   l_value = m.RequestList.LookUp( l_key )
     
   if l_value = Invalid then return Invalid
   
   m.RequestList.Delete( l_key )
   m.ListCount = m.ListCount - 1
     
   return l_value
   
End Function

' Resets the list by emptying the manager and clearing
' out any items remaing, resets all values
Function tl_reset() As Void
   
   m.TManager.CleanUp()
   m.RequestList.Clear()
 
   m.ListCount = 0
   m.SendCount = 0
   m.ReceiveCount = 0
   
End Function

' Each texture object is sent to this function, which creates the texturerequest and sends it
' It also increments the sendcount
Function tl_request_texture( a_texture As Object ) As Integer
   
   ' Create the texture request and assign to the items TRequest member
   a_texture.TRequest = CreateObject( "roTextureRequest", a_texture.TUrl )
   ' Add the item into the async list
   m.AddItem( a_texture.TRequest.GetID(), a_texture )
   ' Asynchronously request the texture
   m.TManager.RequestTexture( a_texture.TRequest )
   ' Increment the send count
   m.SendCount = m.SendCount + 1
   ' Return the current total sent
   
   print m.SendCount"   "; a_texture.TUrl
   
   return m.SendCount
   
End Function

' This function receives the texture and processes it, if successful it increments the receive count
Function tl_receive_texture( a_tmsg as DYNAMIC ) As Boolean

   ' Get the returned state
   l_state = a_tmsg.GetState()
 
   ' If return state is Ready, Failed, or Cancelled - either case, remove it from the list
   if l_state = m.STATE_READY or l_state >= m.STATE_FAILED
   
      ' Removed the received texture from the asynclist. But do not increment the received count
      l_texture = m.RemoveItem( a_tmsg.GetID() )
      ' There SHOULD ALWAYS be one in there if used properly
      if l_texture = Invalid then return False
     
      ' Assign the bitmap to the texture object
      l_texture.Bitmap = a_tmsg.GetBitmap()
      ' A state of 3 with a valid bitmap is complete
      if l_state = m.STATE_READY and l_texture.Bitmap <> Invalid
       
         ' Increment the receive count and get rid of the texture request
         m.ReceiveCount = m.ReceiveCount + 1
         l_texture.TRequest = Invalid
         
         print m.ReceiveCount;"   "; l_texture.TUrl
         
         return True
     
     ' If a failure occurs you can try to resend it, but usually it is a more serious problem which
     ' can put you in an endless loop if you dont put a limit on it.  I handle it differently but for this
     ' example it is resent a limited number of times
      else if l_state = m.STATE_FAILED and l_texture.ResendCount <= 5
         
         ' Optional
         l_texture.TRequest = Invalid
       
         ' Rebuild and resend
         l_texture.ResendCount = l_texture.ResendCount + 1
         l_texture.TRequest = CreateObject( "roTextureRequest", l_texture.TUrl )
         m.AddItem( l_texture.TRequest.GetID(), l_texture )
         m.TManager.RequestTexture( l_texture.TRequest )
     
         ' Set the global error
         l_str = "Resend Texture Request. State : " + l_state.ToStr()
         l_str = l_str + "  Bitmap: " + type( a_tmsg.GetBitmap() ) + "  ResendCount: " + l_texture.ResendCount.ToStr()
         l_str = l_str + " URI: " + l_texture.TUrl
         
         print l_str
         
         return False
 
      ' This can occur with the dylnamic allocation when the textures are not removed from the queue fast enough
      ' or the resend count has expired, cancelled etc...
      else
     
         l_str = "Unhandled Message. State: " + l_state.ToStr() + "  Bitmap: " + type( a_tmsg.GetBitmap() )
         l_str = l_str + " URI: " + l_texture.TUrl
         
         print l_str
         
         return False
         
      end if
     
   end if
   
   ' Otherwise it is some other code such as downloading if it even exists.  Never seen it
   return True
   
End Function

' This function simply polls for all the textures to return. To populate a grid during realtime scrolling
' a little modification is needed to the grids I have put out here and this manager  I have this available
' in my own library
Function tl_poll_textures() As Boolean

   ' Just a timeout here you may want to add something like I do to allow the user to abort under
   ' certain conditions.  That was removed for simplicity
   l_timer = CreateObject( "roTimeSpan" )
   l_timeOut = 45
   l_kp_BK   = 0
   
   l_success = False
   
   while( True )
   
      ' Monitor the managers port
      l_TMsg = m.TMPort.GetMessage()
     
      if l_TMsg <> Invalid
     
         ' Process the received texture
         m.ReceiveTexture( l_TMsg )
       
         ' When receivecount is = to send count then we have them all
         ' you have to be careful here any abnormality or failure in the chain can effect this
         ' I do it differently with more error checking but this is only a demonstration
         l_success = ( m.ReceiveCount = m.SendCount )
         if l_success then exit while
         
         ' Reset the timer
         l_timer.Mark()
         
      end if
     
      ' Should always have a timeout as anything can occur
      if ( l_timer.TotalSeconds() >= l_timeout )
     
         print "TextureRequest Timed Out"
         exit while
         
      end if
     
   end while
   
   return l_success
   
   
End Function