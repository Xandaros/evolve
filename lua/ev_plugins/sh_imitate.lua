/*-------------------------------------------------------------------------------------------------------------------------
	Imitate a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Imitate"
PLUGIN.Description = "Imitate a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "im"
PLUGIN.Usage = "<player> <message>"
PLUGIN.Privileges = { "Imitate" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Imitate" ) ) then	
		local players = evolve:FindPlayer( args[1] )
		local msg = table.concat( args, " ", 2 )
		
		if ( #players == 1 ) then
			if ( #msg > 0 ) then
				umsg.Start( "EV_Imitate" )
					umsg.Entity( players[1] )
					umsg.String( msg )
					umsg.Bool( players[1]:IsBot() or players[1]:Alive() )
				umsg.End()
			else
				evolve:Notify( ply, evolve.colors.red, "No message specified." )
			end
		elseif ( #players > 1 ) then
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( players, true ), evolve.colors.white, "?" )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

usermessage.Hook( "EV_Imitate", function( um )
	local ply = um:ReadEntity()
	hook.Call( "OnPlayerChat", nil, ply, um:ReadString(), false, !um:ReadBool() )
end )

evolve:RegisterPlugin( PLUGIN )