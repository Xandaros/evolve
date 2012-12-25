/*-------------------------------------------------------------------------------------------------------------------------
	Unban a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Unban"
PLUGIN.Description = "Unban a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "unban"
PLUGIN.Usage = "<steamid|nick>"
PLUGIN.Privileges = { "Unban" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Unban" ) ) then
		if ( args[1] ) then
			local uniqueID
			
			if ( string.match( args[1], "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
				uniqueID = evolve:UniqueIDByProperty( "SteamID", args[1], true )
			else
				uniqueID = evolve:UniqueIDByProperty( "Nick", args[1], false )
			end
			
			if ( uniqueID and evolve:IsBanned( uniqueID ) ) then
				evolve:UnBan( uniqueID, ply:UniqueID() )
				
				evolve:Notify( evolve.colors.blue, ply:Nick(), color_white, " has unbanned ", evolve.colors.red, evolve:GetProperty( uniqueID, "Nick" ), color_white, "." )
			elseif ( uniqueID ) then
				evolve:Notify( ply, evolve.colors.red, evolve:GetProperty( uniqueID, "Nick" ) .. " is not currently banned." )
			else
				evolve:Notify( ply, evolve.colors.red, "No matching players found!" )
			end
		else
			evolve:Notify( ply, evolve.colors.red, "You need to specify a SteamID or nickname!" )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )