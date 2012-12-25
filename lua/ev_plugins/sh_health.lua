/*-------------------------------------------------------------------------------------------------------------------------
	Set the health of a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Health"
PLUGIN.Description = "Set the health of a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "hp"
PLUGIN.Usage = "<players> [health]"
PLUGIN.Privileges = { "Health" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Health" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local hp = math.Clamp( tonumber( args[ #args ] ) or 100, 0, 2147483647 )
		
		for _, pl in ipairs( players ) do
			pl:SetHealth( hp )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the health of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to " .. hp .. "." )
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
		RunConsoleCommand( "ev", "hp", unpack( players ) )
	else
		args = {}
		for i = 1, 10 do
			args[i] = { i * 10 }
		end
		return "Health", evolve.category.actions, args
	end
end

evolve:RegisterPlugin( PLUGIN )