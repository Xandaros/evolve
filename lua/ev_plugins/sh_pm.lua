/*-------------------------------------------------------------------------------------------------------------------------
	Send a private message to someone
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "PM"
PLUGIN.Description = "Send someone a private message."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "pm"
PLUGIN.Usage = "<playersayer> <message>"
PLUGIN.Privileges = { "Private messages" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Private messages" ) ) then
		local players = evolve:FindPlayer( args[1] )
		
		if ( #players < 2 or !players[1] ) then			
			if ( #players > 0 ) then
				local msg = table.concat( args, " ", 2 )
				
				if ( #msg > 0 ) then
					evolve:Notify( ply, evolve.colors.white, "To ", team.GetColor( players[1]:Team() ), players[1]:Nick(), evolve.colors.white, ": " .. msg )
					evolve:Notify( players[1], evolve.colors.white, "From ", team.GetColor( players[1]:Team() ), ply:Nick(), evolve.colors.white, ": " .. msg )
				else
					evolve:Notify( ply, evolve.colors.red, "No message specified." )
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