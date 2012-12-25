/*-------------------------------------------------------------------------------------------------------------------------
	Run a console command on someone
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Client Exec"
PLUGIN.Description = "Run a console command on someone."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "cexec"
PLUGIN.Usage = "<player> <command> [args]"
PLUGIN.Privileges = { "Client Exec" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Client Exec" ) ) then
		local players = evolve:FindPlayer( args[1] )
		
		if ( #players < 2 or !players[1] ) then			
			if ( #players > 0 ) then
				local command = table.concat( args, " ", 2 )
				
				if ( #command > 0 ) then
					players[1]:ConCommand( command )
				else
					evolve:Notify( ply, evolve.colors.red, "No command specified." )
				end
			else
				evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
			end
		else
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( players, true ), evolve.colors.white, "?" )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )