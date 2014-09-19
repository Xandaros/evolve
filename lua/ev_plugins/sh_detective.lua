/*-------------------------------------------------------------------------------------------------------------------------
	detective
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "detective"
PLUGIN.Description = "Makes a player detective"
PLUGIN.Author = "-[LCG]- Marvincmarvin | mostly Overv"
PLUGIN.ChatCommand = "detective"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "TTT Detective" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "TTT Detective" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			pl:SetRole(ROLE_DETECTIVE)
			SendFullStateUpdate()
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has made ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " a detective." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )