/*-------------------------------------------------------------------------------------------------------------------------
	Retrieve playtime
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Playtime"
PLUGIN.Description = "View the playtime of someone or yourself."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "playtime"
PLUGIN.Usage = "[player]"

function PLUGIN:Call( ply, args )
	local uid, pl
	if ( string.match( args[1] or "", "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
		uid = evolve:UniqueIDByProperty( "SteamID", args[1] )
		pl = player.GetByUniqueID( uid )
	else
		pl = evolve:FindPlayer( args[1], ply )
		
		if ( #pl > 1 ) then
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
			return
		elseif ( #pl == 0 ) then
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayersnoimmunity )
			return
		elseif ( !pl[1]:IsValid() ) then
			evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
			return
		else
			pl = pl[1]
			uid = pl:UniqueID()
		end
	end
	
	local time = evolve:GetProperty( uid, "PlayTime" )
	if ( pl and pl:IsValid() ) then
		time = time + os.clock() - pl.EV_LastPlaytimeSave
		evolve:Notify( ply, evolve.colors.blue, evolve:GetProperty( uid, "Nick" ), evolve.colors.white, " has spent ", evolve.colors.red, evolve:FormatTime( time ), evolve.colors.white, " on this server, with ", evolve.colors.red, evolve:FormatTime( pl:TimeConnected() ), evolve.colors.white, " this session." )
	else
		evolve:Notify( ply, evolve.colors.blue, evolve:GetProperty( uid, "Nick" ), evolve.colors.white, " has spent ", evolve.colors.red, evolve:FormatTime( time ), evolve.colors.white, " on this server." )
	end
end

evolve:RegisterPlugin( PLUGIN )