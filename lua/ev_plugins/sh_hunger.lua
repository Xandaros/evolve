/*-------------------------------------------------------------------------------------------------------------------------
	Set the health of a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Hunger"
PLUGIN.Description = "Set the hunger of a player."
PLUGIN.Author = "EntranceJew"
PLUGIN.ChatCommand = "hunger"
PLUGIN.Usage = "<players> [hunger]"
PLUGIN.Privileges = { "Hunger" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Hunger" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local hunger = math.Clamp( tonumber( args[ #args ] ) or 100, 0, 2147483647 )
		
		for _, pl in ipairs( players ) do
			pl:setDarkRPVar("Energy", hunger )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the hunger of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to " .. hunger .. "." )
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
		RunConsoleCommand( "ev", "hunger", unpack( players ) )
	else
		args = {}
		for i = 1, 10 do
			args[i] = { i * 10 }
		end
		return "Hunger", evolve.category.actions, args
	end
end

evolve:RegisterPlugin( PLUGIN )