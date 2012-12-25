/*-------------------------------------------------------------------------------------------------------------------------
	View usage information for a given command
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Command Help"
PLUGIN.Description = "View the usage of a command if available."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "help"
PLUGIN.Usage = "<command>"

function PLUGIN:Call( ply, args )
	for _, plugin in ipairs( evolve.plugins ) do
		if ( plugin.ChatCommand and plugin.ChatCommand == string.lower( args[1] or "" ) ) then
			if ( plugin.Usage ) then
				evolve:Notify( ply, evolve.colors.blue, plugin.Title, evolve.colors.white, " - " .. plugin.Description )
				evolve:Notify( ply, evolve.colors.white, "Usage: !" .. plugin.ChatCommand .. " " .. plugin.Usage )
			else
				evolve:Notify( ply, evolve.colors.red, "No help is available for that command." )
			end
			return 
		end
	end
	
	evolve:Notify( ply, evolve.colors.red, "Unknown command '" .. ( args[1] or "" ) .. "'." )
end

evolve:RegisterPlugin( PLUGIN )