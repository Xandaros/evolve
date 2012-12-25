/*-------------------------------------------------------------------------------------------------------------------------
	Run a console command on the server
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "RCON"
PLUGIN.Description = "Run a console command on the server."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "rcon"
PLUGIN.Usage = "<command> [arg1] [arg2] ..."
PLUGIN.Privileges = { "RCON" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "RCON" ) ) then		
		if ( #args > 0 ) then
			RunConsoleCommand( unpack( args ) )
		else
			evolve:Notify( ply, evolve.colors.red, "No command specified." )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )