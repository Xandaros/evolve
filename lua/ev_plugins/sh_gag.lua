/*-------------------------------------------------------------------------------------------------------------------------
	Gag a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Gag"
PLUGIN.Description = "Gag a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "gag"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Gag" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Gag" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl.EV_Gagged = enabled
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has gagged ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has ungagged ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:PlayerSay( ply, msg )
	if ( ply.EV_Gagged and string.Left( msg, 1 ) != "!" and string.Left( msg, 1 ) != "/" ) then return "" end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "gag", unpack( players ) )
	else
		return "Gag", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )