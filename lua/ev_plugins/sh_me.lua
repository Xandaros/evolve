/*-------------------------------------------------------------------------------------------------------------------------
	/me command
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Me"
PLUGIN.Description = "Represent an action."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "me"
PLUGIN.Usage = "<action>"
PLUGIN.Privileges = { "Me" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Me" ) ) then
		local action = table.concat( args, " " )
		
		if ( #action > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " " .. tostring( action ) )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )