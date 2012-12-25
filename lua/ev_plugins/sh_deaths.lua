/*-------------------------------------------------------------------------------------------------------------------------
	Set the deaths of a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Deaths"
PLUGIN.Description = "Set the deaths of a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "deaths"
PLUGIN.Usage = "<players> [deaths]"
PLUGIN.Privileges = { "Deaths" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Deaths" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local deaths = tonumber( args[ #args ] ) or 0
		
		for _, pl in ipairs( players ) do
			pl:SetDeaths( deaths )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the deaths of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to " .. deaths .. "." )
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
		RunConsoleCommand( "ev", "deaths", unpack( players ) )
	else
		args = {}
		for i = 1, 20 do
			args[i+1] = i
		end
		return "Deaths", evolve.category.actions, args, "Amount of deaths"
	end
end

evolve:RegisterPlugin( PLUGIN )