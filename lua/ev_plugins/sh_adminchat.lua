/*-------------------------------------------------------------------------------------------------------------------------
	Display a message to online admins
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Admin Chat"
PLUGIN.Description = "Display a message to all online admins."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "a"
PLUGIN.Usage = "<message>"
PLUGIN.Privileges = { "Admin chat" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Admin chat" ) ) then
		if ( #args == 0 ) then return end
		local msg = table.concat( args, " " )
		
		for _, pl in ipairs( player.GetAll() ) do
			if ( pl:EV_HasPrivilege( "Admin chat" ) ) then evolve:Notify( pl, evolve.colors.red, "(Admins) ", team.GetColor( ply:Team() ), ply:Nick(), evolve.colors.white, ": " .. msg ) end
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )