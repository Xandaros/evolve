/*-------------------------------------------------------------------------------------------------------------------------
	Enable noclip for someone
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Noclip"
PLUGIN.Description = "Enable noclip for a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "noclip"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Noclip", "Noclip access" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Noclip" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			if ( enabled ) then pl:SetMoveType( MOVETYPE_NOCLIP ) else pl:SetMoveType( MOVETYPE_WALK ) end
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has noclipped ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has un-noclipped ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "noclip", unpack( players ) )
	else
		return "Noclip", evolve.category.actions, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

function PLUGIN:PlayerNoClip( ply )
	if ( SERVER and !ply:EV_HasPrivilege( "Noclip access" ) ) then return false end
end

evolve:RegisterPlugin( PLUGIN )