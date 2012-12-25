/*-------------------------------------------------------------------------------------------------------------------------
	Clean up the decals
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Decals"
PLUGIN.Description = "Remove all decals from the map."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "decals"
PLUGIN.Privileges = { "Decal cleanup" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Decal cleanup" ) ) then
		evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has cleaned up the decals." )
		
		for _, pl in ipairs( player.GetAll() ) do
			pl:ConCommand( "r_cleardecals" )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )