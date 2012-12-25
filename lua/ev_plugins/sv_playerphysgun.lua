/*-------------------------------------------------------------------------------------------------------------------------
	Physgun players
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Physgun Players"
PLUGIN.Description = "Physgun a player."
PLUGIN.Author = "Overv"
PLUGIN.Privileges = { "Physgun players" }

function PLUGIN:PhysgunPickup( ply, pl )
	if ( ply:EV_HasPrivilege( "Physgun players" ) and pl:IsPlayer() and ply:EV_BetterThanOrEqual( pl ) ) then
		pl.EV_PickedUp = true
		pl:SetMoveType( MOVETYPE_NOCLIP )
		return true
	end
end

function PLUGIN:PhysgunDrop( ply, pl )
	if ( pl:IsPlayer() ) then
		pl.EV_PickedUp = false
		pl:SetMoveType( MOVETYPE_WALK )
		return true
	end
end

function PLUGIN:PlayerNoclip( ply )
	if ( pl.EV_PickedUp ) then return false end
end

evolve:RegisterPlugin( PLUGIN )