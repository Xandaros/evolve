/*-------------------------------------------------------------------------------------------------------------------------
	Display a notification at the top
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Notice"
PLUGIN.Description = "Pops up a notification for everyone."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "notice"
PLUGIN.Usage = "<message> [time=10]"
PLUGIN.Privileges = { "Notice" }

function PLUGIN:Initialize()
	util.AddNetworkString( "EV_Notify" )
end

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Notice" ) ) then
		local time = tonumber( args[ #args ] ) or 10
		if ( tonumber( args[ #args ] ) ) then args[ #args ] = nil end
		local msg = table.concat( args, " " )
		
		if ( #msg > 0 ) then
			net.Start( "EV_Notify" )
				net.WriteUInt( time, 8 )
				net.WriteString( msg )
			net.Broadcast()
			
			evolve:Notify( evolve.colors.white, msg )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

if ( CLIENT ) then
	net.Receive( "EV_Notify", function( length )
		local time = net.ReadUInt(8)
		local msg = net.ReadString()
		
		GAMEMODE:AddNotify( msg, NOTIFY_GENERIC, time )
		surface.PlaySound( "ambient/water/drip" .. math.random( 1, 4 ) .. ".wav" )
	end )
end

evolve:RegisterPlugin( PLUGIN )