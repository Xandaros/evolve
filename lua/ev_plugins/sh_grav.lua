/*-------------------------------------------------------------------------------------------------------------------------
	Set the gravity of the server.
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Gravity"
PLUGIN.Description = "Set the server gravity."
PLUGIN.Author = "Mattocaster 6 & Matt J"
PLUGIN.ChatCommand = "gravity"
PLUGIN.Usage = "<strength>"
PLUGIN.Privileges = { "Gravity" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Gravity" ) ) then		
		if ( #args > 0 ) then
			RunConsoleCommand( "sv_gravity",args[1] )
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the server gravity to ",evolve.colors.red, args[1], evolve.colors.white, "." )
		else
			RunConsoleCommand( "sv_gravity","600")
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has reset the server gravity." )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )