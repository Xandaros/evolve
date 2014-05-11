/*-------------------------------------------------------------------------------------------------------------------------
	Set the money of a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Money(DarkRP)"
PLUGIN.Description = "Set the money of a player."
PLUGIN.Author = "Grey"
PLUGIN.ChatCommand = "money"
PLUGIN.Usage = "[players] [money]"
PLUGIN.Privileges = { "Money" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Money" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local money = tonumber( args[ #args ] ) or 100
		
		for _, pl in ipairs( players ) do
			RunConsoleCommand("rp_setmoney", pl:Name(), money)
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the money of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to " .. money .. "." )
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
		RunConsoleCommand( "ev", "money", unpack( players ) )
	else
		args = {}
		for i = 1, 10 do
			args[i] = { 10 * 10^(i-1) }
		end
		return "Money(DarkRP)", evolve.category.actions, args
	end
end

evolve:RegisterPlugin( PLUGIN )