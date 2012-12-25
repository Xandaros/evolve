/*-------------------------------------------------------------------------------------------------------------------------
	Make a player enter a vehicle
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Enter"
PLUGIN.Description = "Make a player enter a vehicle."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "enter"
PLUGIN.Usage = "[player]"
PLUGIN.Privileges = { "Enter vehicle" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Enter vehicle" ) ) then
		local players = evolve:FindPlayer( args, ply )
		local vehicle = ply:GetEyeTrace().Entity
		
		if ( !ValidEntity( vehicle ) or !vehicle:IsVehicle() ) then
			evolve:Notify( ply, evolve.colors.red, "You are not looking at a vehicle!" )
		else
			if ( #players == 1 ) then
				if ( ValidEntity( vehicle:GetDriver() ) ) then vehicle:GetDriver():ExitVehicle() end
				players[1]:EnterVehicle( vehicle )
				
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has forced ", evolve.colors.red, players[1]:Nick(), evolve.colors.white, " into a vehicle." )
			elseif ( #players > 1 ) then
				evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( players, true ), evolve.colors.white, "?" )
			else
				evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
			end
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "enter", unpack( players ) )
	else
		return "Enter vehicle", evolve.category.actions
	end
end

evolve:RegisterPlugin( PLUGIN )