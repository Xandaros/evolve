/*-------------------------------------------------------------------------------------------------------------------------
	Ignite a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Ignite"
PLUGIN.Description = "Ignite a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "ignite"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Ignite" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Ignite" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			if ( enabled ) then pl:Ignite( 99999, 1 ) else pl:Extinguish() end
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has ignited ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has extinguished ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:PlayerDeath( ply )
	if ( ply:IsOnFire() ) then
		ply:Extinguish()
	end
end

function PLUGIN:Move( ply )
	if ( !SERVER ) then return end
	
	if ( ply:IsOnFire() and ply:WaterLevel() == 3 ) then
		ply:Extinguish()
		evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " extinguished himself by jumping into water." )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "ignite", unpack( players ) )
	else
		return "Ignite", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )