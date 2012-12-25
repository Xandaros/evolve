/*-------------------------------------------------------------------------------------------------------------------------
	Extinguish everything
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Extinguish"
PLUGIN.Description = "Extinguish every entity in the map."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "extinguish"
PLUGIN.Privileges = { "Extinguish" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Extinguish" ) ) then
		evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has extinguished all fires." )
		
		for _, ent in ipairs( ents.GetAll() ) do
			ent:Extinguish()
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )