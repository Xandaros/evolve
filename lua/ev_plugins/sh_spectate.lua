/*-------------------------------------------------------------------------------------------------------------------------
	Spectate a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Spectate"
PLUGIN.Description = "Spectate a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "spec"
PLUGIN.Usage = "<player> or nothing to disable"
PLUGIN.Privileges = { "Spectate" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Spectate" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		if ( #args > 0 ) then
			if ( #players == 1 ) then
				ply.EV_SpectatePos = ply:GetPos()
				ply:SetNWBool( "EV_Spectating", true )
				
				ply:Spectate( OBS_MODE_CHASE )
				ply:SpectateEntity( players[1] )
				ply:SetMoveType( MOVETYPE_OBSERVER )
				
				ply:StripWeapons()
			elseif ( #players > 1 or players[1] == ply ) then
				evolve:Notify( ply, evolve.colors.red, "You can not spectate multiple players or yourself." )
			else
				evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
			end
		elseif ( ply:GetNWBool( "EV_Spectating", false ) ) then
			ply:Spectate( OBS_MODE_NONE )
			ply:UnSpectate()
			ply:SetMoveType( MOVETYPE_WALK )
			
			ply:SetNWBool( "EV_Spectating", false )
			
			ply:Spawn()
			timer.Simple( 0.05, function() ply:SetPos( ply.EV_SpectatePos ) ply.EV_SpectatePos = nil end )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:EV_ShowPlayerName( ply )
	if ( ply:GetNWBool( "EV_Spectating", false ) ) then return false end
end

evolve:RegisterPlugin( PLUGIN )