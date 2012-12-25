/*-------------------------------------------------------------------------------------------------------------------------
	Freeze a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Freeze"
PLUGIN.Description = "Freeze a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "freeze"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Freeze" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Freeze" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			if ( enabled ) then
				pl:Lock()
			else
				pl:UnLock()
			end
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has frozen ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has unfrozen ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
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
		RunConsoleCommand( "ev", "freeze", unpack( players ) )
	else
		return "Freeze", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )