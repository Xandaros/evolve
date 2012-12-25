/*-------------------------------------------------------------------------------------------------------------------------
	Arm a player with the default loadout
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Arm"
PLUGIN.Description = "Arm players with the default loadout."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "arm"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Arm" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Arm" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			GAMEMODE:PlayerLoadout( pl )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has armed ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "arm", unpack( players ) )
	else
		return "Arm", evolve.category.actions
	end
end

evolve:RegisterPlugin( PLUGIN )