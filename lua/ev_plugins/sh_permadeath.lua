/*-------------------------------------------------------------------------------------------------------------------------
	PermaDeath a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Permadeath"
PLUGIN.Description = "Disable respawning for a player."
PLUGIN.Author = "Grey"
PLUGIN.ChatCommand = "nospawn"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Respawn Control" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Respawn Control" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl:SetNWBool( "EV_NoRespawn", enabled )
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has prevented ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " from respawning." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has allowed ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to respawn." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function NoRespawnCheck( ply )
	if ply:GetNWBool( "EV_NoRespawn", false ) then
		ply:Kill()
	end
end
hook.Add("PlayerSpawn","EVPermaDeathCheck",NoRespawnCheck)
function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "permadeath", unpack( players ) )
	else
		return "Permadeath", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )