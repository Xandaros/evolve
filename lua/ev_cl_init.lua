/*-------------------------------------------------------------------------------------------------------------------------
	Clientside initialization
-------------------------------------------------------------------------------------------------------------------------*/

print( "\n=====================================================" )
print( " Evolve 1.0 by Overv succesfully started clientside." )
print( "=====================================================\n" )

net.Receive( "EV_Init", function( length )
	evolve.installed = true
	
	evolve:GetSettings()
	evolve:LoadPlugins()
end )