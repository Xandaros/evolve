/*-------------------------------------------------------------------------------------------------------------------------
	Innocent
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "innocent"
PLUGIN.Description = "Makes a player innocent"
PLUGIN.Author = "-[LCG]- Marvincmarvin | mostly Overv"
PLUGIN.ChatCommand = "innocent"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "TTT Innocent" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "TTT Innocent" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			pl:SetRole(ROLE_INNOCENT)
			SendFullStateUpdate()
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has made ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "an innocent." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )