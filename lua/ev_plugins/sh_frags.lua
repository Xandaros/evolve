/*-------------------------------------------------------------------------------------------------------------------------
	Set the frags of a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Frags"
PLUGIN.Description = "Set the frags of a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "frags"
PLUGIN.Usage = "<players> [frags]"
PLUGIN.Privileges = { "Frags" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Frags" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local frags = tonumber( args[ #args ] ) or 0
		
		for _, pl in ipairs( players ) do
			pl:SetFrags( frags )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the frags of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to " .. frags .. "." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "frags", unpack( players ) )
	else
		args = {}
		for i = 0, 20 do
			args[i+1] = { i }
		end
		return "Frags", evolve.category.actions, args
	end
end

evolve:RegisterPlugin( PLUGIN )