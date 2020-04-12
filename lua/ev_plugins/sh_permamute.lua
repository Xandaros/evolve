local Plugin = {}
Plugin.Title = "PermaMuter"
Plugin.Description = "Permanently mute players."
Plugin.Author = "Tom"
Plugin.ChatCommand = "permamute"
Plugin.Usage = "[players] [1/0]"
Plugin.Privileges = { "PermaMute" }

function Plugin:Call( ply, args )
	if (!sql.TableExists( "permamuted_players" ) ) then
		query = "CREATE TABLE permamuted_players ( steamID varchar(255), isMuted int )"
		result = sql.Query(query)
	end

	if ( ply:EV_HasPrivilege( "PermaMute" )) then
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		local players = evolve:FindPlayer( args, ply, true )
		for _, pl in ipairs( players ) do
			if ( enabled ) then
				query = "UPDATE permamuted_players SET isMuted = 1 WHERE steamID = '"..pl:SteamID().."'"
				sql.Query(query)
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has permanently muted ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
				pl:SetNWBool( "Muted", enabled )
				pl:SendLua( "LocalPlayer():ConCommand( \"-voicerecord\" )" )
			else
				query = "UPDATE permamuted_players SET isMuted = 0 WHERE steamID = '"..pl:SteamID().."'"
				sql.Query(query)
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has unmuted ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
				pl:SetNWBool( "Muted", enabled )
			end
		end
	end
end

function Plugin:PlayerCanHearPlayersVoice( _, ply )
  ID = sql.QueryValue( "SELECT isMuted from permamuted_players WHERE steamID = '"..ply:SteamID().."'" )
  if ( ID == 1 || ply.EV_MUTED) then return false end
end

function CMOnSpawn( ply)
	ID = sql.QueryValue( "SELECT isMuted from permamuted_players WHERE steamID = '"..ply:SteamID().."'" )
	if ( ID == 1 || ply.EV_MUTED) then 
		ply:SetNWBool( "Muted", enabled )
		ply:SendLua( "LocalPlayer():ConCommand( \"-voicerecord\" )" )
	end
end
hook.Add("PlayerSpawn","CheckIfMuted",CMOnSpawn)
function Plugin:Menu( arg, players )
  if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "permamute", unpack( players ) )
  else
	return "Permanently Mute", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( Plugin )