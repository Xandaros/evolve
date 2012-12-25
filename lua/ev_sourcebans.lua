--[[
	ENABLE SOURCE BANS?
	true OR false
]]--

local SourceBansEnabled = false

--[[
	STOP EDITING AGAIN HERE
]]--

if ( SourceBansEnabled ) then

require( "sourcebans" )

--[[
	EDIT THE FOLLOWING INFO
]]--

sourcebans.SetConfig( "hostname", "127.0.0.1" )
sourcebans.SetConfig( "username", "root" )
sourcebans.SetConfig( "password", "" )
sourcebans.SetConfig( "database", "sourcebans" )
sourcebans.SetConfig( "dbprefix", "sb" )
sourcebans.SetConfig( "portnumb", 3306 )
sourcebans.SetConfig( "serverid", 1 )

--[[
	STOP EDITING HERE
]]--

sourcebans.Activate()

local function syncBans()
	sourcebans.GetAllActiveBans( function( bans )
		for _, ban in ipairs( bans ) do			
			local uid = util.CRC( "gm_" .. ban.SteamID .. "_gm" )
			
			if ( !evolve.PlayerInfo[uid] ) then evolve.PlayerInfo[uid] = {} end
			
			evolve.PlayerInfo[uid].SteamID = ban.SteamID
			if ( ban.BanLength > 0 ) then
				evolve.PlayerInfo[uid].BanEnd = ban.BanEnd
			else
				evolve.PlayerInfo[uid].BanEnd = 0
			end
			evolve.PlayerInfo[uid].BanReason = ban.BanReason
			evolve.PlayerInfo[uid].Nick = ban.Name
			
			if ( ban.AdminID == "STEAM_ID_UNKNOWN" ) then
				evolve.PlayerInfo[uid].BanAdmin = 0
			else
				local adminuid = util.CRC( "gm_" .. ban.AdminID .. "_gm" )
				evolve.PlayerInfo[uid].BanAdmin = adminuid
				
				if ( !evolve.PlayerInfo[adminuid] ) then
					evolve.PlayerInfo[adminuid] = {}
					evolve.PlayerInfo[adminuid].Nick = ban.AdminName
				end
			end
		end
	end )
end
timer.Create( "EV_SourceBansSync", 300, 0, syncBans )
timer.Simple( 1, syncBans )

end