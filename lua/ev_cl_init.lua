/*-------------------------------------------------------------------------------------------------------------------------
	Clientside initialization
-------------------------------------------------------------------------------------------------------------------------*/

// Show startup message
print( "\n=====================================================" )
print( " Evolve 1.0 by Overv succesfully started clientside." )
print( "=====================================================\n" )

usermessage.Hook( "EV_Init", function( um )
	evolve.installed = true
	
	// Load plugins
	evolve:LoadPlugins()
end )