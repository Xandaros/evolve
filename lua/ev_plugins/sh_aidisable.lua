/*-------------------------------------------------------------------------------------------------------------------------
	Disable or enable AI with a chat command.
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "AI Disable/Enable"
PLUGIN.Description = "Enable or disable AI."
PLUGIN.Author = "Mattocaster 6"
PLUGIN.ChatCommand = "ai"
PLUGIN.Usage = "<1=enabled 0=disabled>"
PLUGIN.Privileges = { "AI Control" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "AI Control" ) ) then		
		if ( tonumber(args[1])==1 ) then
			RunConsoleCommand( "ai_disable","1" )
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has enabled the ai. " )
		else
			RunConsoleCommand( "ai_disabled","0")
			evolve:Notify( evolve.colors.red, ply:Nick(), evolve.colors.white, " has disabled the ai. " )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )