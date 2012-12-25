/*-------------------------------------------------------------------------------------------------------------------------
	Set the armor of a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Armor"
PLUGIN.Description = "Set the armor of a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "armor"
PLUGIN.Usage = "<players> [armor]"
PLUGIN.Privileges = { "Armor" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Armor" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local armor = tonumber( args[ #args ] ) or 100
		
		for _, pl in ipairs( players ) do
			pl:SetArmor( armor )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the armor of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to " .. armor .. "." )
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
		RunConsoleCommand( "ev", "armor", unpack( players ) )
	else
		args = {}
		for i = 1, 10 do
			args[i] = { i * 10 }
		end
		return "Armor", evolve.category.actions, args
	end
end

evolve:RegisterPlugin( PLUGIN )