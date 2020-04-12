/*-------------------------------------------------------------------------------------------------------------------------
	Traitor
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Traitor"
PLUGIN.Description = "Makes a player traitor"
PLUGIN.Author = "-[LCG]- Marvincmarvin | mostly Overv"
PLUGIN.ChatCommand = "traitor"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "TTT Traitor" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "TTT Traitor" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			pl:SetRole(ROLE_TRAITOR)
			SendFullStateUpdate()
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has traitorized ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )