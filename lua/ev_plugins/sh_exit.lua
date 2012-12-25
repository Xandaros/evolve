/*-------------------------------------------------------------------------------------------------------------------------
	Make a player exit a vehicle
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Exit"
PLUGIN.Description = "Make a player exit a vehicle."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "exit"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Exit vehicle" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Exit vehicle" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for k, v in pairs( players ) do
				if ( ValidEntity( v:GetVehicle() ) ) then v:ExitVehicle() else table.remove( players, k ) end
			end
		
		if ( #players > 0 ) then			
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has forced ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " out of their vehicle." )
		else
			evolve:Notify( ply, evolve.colors.red, "No matching players in vehicles found." )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "exit", unpack( players ) )
	else
		return "Exit vehicle", evolve.category.actions
	end
end

evolve:RegisterPlugin( PLUGIN )