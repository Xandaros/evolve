/*-------------------------------------------------------------------------------------------------------------------------
	Display a public message as an admin
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Public Admin Message"
PLUGIN.Description = "Display a message to all online players as an admin."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "pa"
PLUGIN.Usage = "<message>"
PLUGIN.Privileges = { "Public admin message" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Public admin message" ) ) then
		if ( #args > 0 ) then
			evolve:Notify( evolve.colors.red, "(ADMIN)", evolve.colors.white, " " .. table.concat( args, " " ) )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )