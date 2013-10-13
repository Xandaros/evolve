/*-------------------------------------------------------------------------------------------------------------------------
	Enable godmode for a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Godmode"
PLUGIN.Description = "Enable godmode for a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "god"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "God" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "God" ) ) then
		local players = {}
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( evolve:FindPlayer( args, ply, true ) ) do
			if ply:EV_IsAdmin() or ply:EV_GetRank() ~= pl:EV_GetRank() or ply == pl then
				players[#players+1] = pl
				
				if ( enabled ) then pl:GodEnable() else pl:GodDisable() end
				pl.EV_GodMode = enabled
			end
		end
				
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has enabled godmode for ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has disabled godmode for ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:PlayerSpawn( ply )
	if ( ply.EV_GodMode ) then ply:GodEnable() end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "god", unpack( players ) )
	else
		return "Godmode", evolve.category.actions, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )