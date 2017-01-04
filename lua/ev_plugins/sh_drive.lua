/*-------------------------------------------------------------------------------------------------------------------------
	Allow a player to drive entities
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Entity Drive"
PLUGIN.Description = "Allow a player to drive entities."
PLUGIN.Author = "bellum128"
PLUGIN.Privileges = { "Entity Drive" }

function PLUGIN:CanDrive(ply , ent)
	if (SERVER and !ply:EV_HasPrivilege( "Entity Drive" ) ) then
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		return false
	end
end

evolve:RegisterPlugin( PLUGIN )
