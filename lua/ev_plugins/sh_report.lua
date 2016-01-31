/*-------------------------------------------------------------------------------------------------------------------------
	Report something
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Report"
PLUGIN.Description = "Report someone."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "report"
PLUGIN.Usage = "<player> <reason>"
PLUGIN.Privileges = { "Report" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Report" ) ) then
		local pl = evolve:FindPlayer( args[1] )
		
		if ( #pl > 1 ) then
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
		elseif ( #pl == 1 ) then
			if ( #args > 1 ) then
				local msg = table.concat( args, " ", 2 )
				
				file.Append( "evolve/reports.txt", "[" .. os.date() .. "] " ..  evolve:PlayerLogStr( ply ) .. " reported " .. evolve:PlayerLogStr( pl[1] ) .. " with reason '" .. msg .. "'\n" )
				
				for _, admin in ipairs( player.GetAll() ) do
					if ( admin:EV_IsAdmin() ) then evolve:Notify( admin, evolve.colors.red, ply:Nick() .. " reported " .. pl[1]:Nick() .. " with reason: ", evolve.colors.white, msg ) end
				end
			else
				evolve:Notify( ply, evolve.colors.red, "No reason specified!" )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayersnoimmunity )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )
