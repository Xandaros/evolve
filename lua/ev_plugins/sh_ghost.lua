/*-------------------------------------------------------------------------------------------------------------------------
	Ghost a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Ghost"
PLUGIN.Description = "Ghost a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "ghost"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Ghost" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Ghost" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			if ( enabled ) then
				pl:SetRenderMode( RENDERMODE_NONE )
				pl:SetColor( 255, 255, 255, 0 )
				pl:SetCollisionGroup( COLLISION_GROUP_WEAPON )
				
				for _, w in ipairs( pl:GetWeapons() ) do
					w:SetRenderMode( RENDERMODE_NONE )
					w:SetColor( 255, 255, 255, 0 )
				end
			else
				pl:SetRenderMode( RENDERMODE_NORMAL )
				pl:SetColor( 255, 255, 255, 255 )
				pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
				
				for _, w in ipairs( pl:GetWeapons() ) do
					w:SetRenderMode( RENDERMODE_NORMAL )
					w:SetColor( 255, 255, 255, 255 )
				end
			end
			
			pl:SetNWBool( "EV_Ghosted", enabled )
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has ghosted ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has unghosted ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:EV_ShowPlayerName( ply )
	if ( ply:GetNWBool( "EV_Ghosted", false ) ) then return false end
end

function PLUGIN:PlayerSpawn( ply )
	if ( ply:GetNWBool( "EV_Ghosted", false ) ) then
		ply:SetRenderMode( RENDERMODE_NONE )
		ply:SetColor( 255, 255, 255, 0 )
		ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		
		for _, w in ipairs( ply:GetWeapons() ) do
			w:SetRenderMode( RENDERMODE_NONE )
			w:SetColor( 255, 255, 255, 0 )
		end
	end
end

function PLUGIN:PlayerCanPickupWeapon( ply, wep )
	if ( ply:GetNWBool( "EV_Ghosted", false ) ) then
		wep:SetRenderMode( RENDERMODE_NONE )
		wep:SetColor( 255, 255, 255, 0 )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "ghost", unpack( players ) )
	else
		return "Ghost", evolve.category.actions, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )