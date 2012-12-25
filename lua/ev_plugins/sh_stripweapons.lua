/*-------------------------------------------------------------------------------------------------------------------------
	Strip a player's weapons
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Strip Weapons"
PLUGIN.Description = "Strip a player's weapons."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "strip"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Strip" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Strip" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			pl:StripWeapons()
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has stripped the weapons of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "strip", unpack( players ) )
	else
		return "Strip weapons", evolve.category.punishment
	end
end

evolve:RegisterPlugin( PLUGIN )