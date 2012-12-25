/*-------------------------------------------------------------------------------------------------------------------------
	Enable no limits for a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "No Limits"
PLUGIN.Description = "Disable limits for a player."
PLUGIN.Author = "Overv and Divran"
PLUGIN.ChatCommand = "nolimits"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "No limits", "Limits disabled" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "No limits" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl.EV_NoLimits = enabled
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has disabled limits for ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has enabled limits for ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

if ( SERVER ) then
	timer.Simple( 1, function()
		PLUGIN.GetCount = _R.Player.GetCount
		function _R.Player:GetCount( limit, minus )
			if ( self.EV_NoLimits or self:EV_HasPrivilege( "No limits" ) ) then
				return -1
			else
				return PLUGIN.GetCount( self, limit, minus )
			end
		end
	end )
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "nolimits", unpack( players ) )
	else
		return "No limits", evolve.category.actions, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )