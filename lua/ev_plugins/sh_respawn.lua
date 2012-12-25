/*-------------------------------------------------------------------------------------------------------------------------
	Respawn a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Respawn"
PLUGIN.Description = "Respawn a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "spawn"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Respawn" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Respawn" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			pl:Spawn()
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has respawned ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "spawn", unpack( players ) )
	else
		return "Respawn", evolve.category.actions
	end
end

evolve:RegisterPlugin( PLUGIN )