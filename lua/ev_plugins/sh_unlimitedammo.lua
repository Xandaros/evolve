/*-------------------------------------------------------------------------------------------------------------------------
	Enable unlimited ammo for a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Unlimited ammo"
PLUGIN.Description = "Enable unlimited ammo for a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "uammo"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Unlimited ammo" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Unlimited ammo" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl.EV_UnlimitedAmmo = enabled
			
			if ( enabled ) then
				for _, wep in ipairs( pl:GetWeapons() ) do
					self:FillClips( pl, wep )
				end
			end
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has enabled unlimited ammo for ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has disabled unlimited ammo for ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:FillClips( ply, wep )
	if wep:Clip1() < 255 then wep:SetClip1( 250 ) end
	if wep:Clip2() < 255 then wep:SetClip2( 250 ) end
	
	if wep:GetPrimaryAmmoType() == 10 or wep:GetPrimaryAmmoType() == 8 then
		ply:GiveAmmo( 9 - ply:GetAmmoCount( wep:GetPrimaryAmmoType() ), wep:GetPrimaryAmmoType() )
	elseif wep:GetSecondaryAmmoType() == 9 or wep:GetSecondaryAmmoType() == 2 then
		ply:GiveAmmo( 9 - ply:GetAmmoCount( wep:GetSecondaryAmmoType() ), wep:GetSecondaryAmmoType() )
	end
end

function PLUGIN:Tick()
	for _, ply in ipairs( player.GetAll() ) do
		if ( ply.EV_UnlimitedAmmo and ply:Alive() and ply:GetActiveWeapon() != NULL ) then
			self:FillClips( ply, ply:GetActiveWeapon() )
		end
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "uammo", unpack( players ) )
	else
		return "Unlimited ammo", evolve.category.actions, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )