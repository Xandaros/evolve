/*-------------------------------------------------------------------------------------------------------------------------
	Change the map
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Change Map"
PLUGIN.Description = {"Change the map.", "Change the gamemode."}
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = {"map", "gamemode"}
PLUGIN.Usage = {"<map>", "<gamemode>"}
PLUGIN.Privileges = { "Map changing", "Gamemode changing" }

function PLUGIN:Call( ply, args, arg, cmd )
	if cmd == "map" then
		if ( ply:EV_HasPrivilege( "Map changing" ) ) then
			if ( args[1] and file.Exists( "maps/" .. args[1] .. ".bsp", "GAME" ) ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has changed the map to ", evolve.colors.red, args[1], evolve.colors.white, "." )
				
				timer.Simple( 0.5, function() RunConsoleCommand( "changelevel", args[1] ) end )
			else
				evolve:Notify( ply, evolve.colors.red, "Specified map not found!" )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		end
	elseif cmd == "gamemode" then
		if ply:EV_HasPrivilege("Gamemode changing") then
			if (args[1] and file.Exists("gamemodes/" .. args[1], "GAME")) then
				evolve:Notify(evolve.colors.blue, ply:Nick(), evolve.colors.white, " has changed the gamemode to ", evolve.colors.red, args[1], evolve.colors.white, ".")
				
				timer.Simple(0.5, function() RunConsoleCommand("gamemode", args[1]) end)
			else
				evolve:Notify(ply, evolve.colors.red, "Specified gamemode not found!")
			end
		else
			evolve:Notify(ply, evolve.colors.red, evolve.constants.notallowed)
		end
	end
end

evolve:RegisterPlugin( PLUGIN )