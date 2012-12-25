/*-------------------------------------------------------------------------------------------------------------------------
	Current time
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Time"
PLUGIN.Description = "Returns the current time."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "time"
PLUGIN.Privileges = { "The time" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "The time" ) ) then
		umsg.Start( "EV_ShowTime", ply )
		umsg.End()
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

usermessage.Hook( "EV_ShowTime", function()
	evolve:Notify( evolve.colors.white, "It is now ", evolve.colors.blue, os.date( "%H:%M" ), evolve.colors.white, "." )
end )

evolve:RegisterPlugin( PLUGIN )