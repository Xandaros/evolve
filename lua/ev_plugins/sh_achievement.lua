/*-------------------------------------------------------------------------------------------------------------------------
	Fake an achievement
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Achievement"
PLUGIN.Description = "Fake someone earning an achievement."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "ach"
PLUGIN.Usage = "<player> <achievement>"
PLUGIN.Privileges = { "Achievement" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Achievement" ) ) then
		local players = evolve:FindPlayer( args[1], nil, nil, true )
		
		if ( players[1] ) then			
			local achievement = table.concat( args, " ", 2 )
			
			if ( #achievement > 0 ) then
				for _, pl in ipairs( players ) do
					evolve:Notify( team.GetColor( pl:Team() ), pl:Nick(), color_white, " earned the achievement ", Color( 255, 201, 0, 255 ), achievement )
				end
			else
				evolve:Notify( ply, evolve.colors.red, "No achievement specified." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayersnoimmunity )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )