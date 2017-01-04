/*-------------------------------------------------------------------------------------------------------------------------
	Permission for spawning objects.
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Spawn Object"
PLUGIN.Description = "Permission for spawning objects."
PLUGIN.Author = "bellum128"
PLUGIN.Privileges = { "Spawn Object" }

function PLUGIN:PlayerSpawnObject( ply )
	if (SERVER and !ply:EV_HasPrivilege( "Spawn Object" ) ) then
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		return false
	end
end

function PLUGIN:PlayerSpawnVehicle( ply )
	if (SERVER and !ply:EV_HasPrivilege( "Spawn Object" ) ) then
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		return false
	end
end

function PLUGIN:PlayerSpawnSENT( ply )
	if (SERVER and !ply:EV_HasPrivilege( "Spawn Object" ) ) then
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		return false
	end
end

function PLUGIN:PlayerSpawnSWEP( ply )
	if (SERVER and !ply:EV_HasPrivilege( "Spawn Object" ) ) then
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		return false
	end
end

function PLUGIN:PlayerSpawnNPC( ply )
	if (SERVER and !ply:EV_HasPrivilege( "Spawn Object" ) ) then
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		return false
	end
end

evolve:RegisterPlugin( PLUGIN )