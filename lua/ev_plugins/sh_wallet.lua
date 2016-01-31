/*-------------------------------------------------------------------------------------------------------------------------
	Set the health of a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Wallet"
PLUGIN.Description = "Set the DarkRP Wallet of a player."
PLUGIN.Author = "EntranceJew"
PLUGIN.ChatCommand = "wallet"
PLUGIN.Usage = "<players> [ammount]"
PLUGIN.Privileges = { "Wallet" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Wallet" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local amount = math.Clamp( tonumber( args[ #args ] ) or 100, 0, 2147483647 )
		
		for _, pl in ipairs( players ) do
			pl:addMoney( amount )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has given ", evolve.colors.red, evolve:CreatePlayerList( players ), Color(123,178,68,255), GAMEMODE.Config.currency..amount, evolve.colors.white, "." )
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
		RunConsoleCommand( "ev", "wallet", unpack( players ) )
	else
		args = {}
		for i = 1, 10 do
			args[i] = { i * 10 }
		end
		return "Wallet", evolve.category.actions, args
	end
end

evolve:RegisterPlugin( PLUGIN )