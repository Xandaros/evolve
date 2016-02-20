/*-------------------------------------------------------------------------------------------------------------------------
	Increases peoples' ranks over time
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Ranks over time"
PLUGIN.Description = "Increases peoples' ranks over time."
PLUGIN.Author = "Divran"
PLUGIN.ChatCommand = "rankup"
PLUGIN.Usage = "<[block/unblock] [player]> OR JUST <[player]>"
PLUGIN.Privileges = { "Block ranks over time", "Unblock ranks over time" }

--------- EDITABLE AREA
-- 					rankname = { targetrank, timerequired (seconds) }
PLUGIN.RankUps = {	
					--["guest"] = { "respected", 60*10 },
					--["respected"] = { "admin", 60*60 },
					--["admin"] = { "superadmin", 60*120 },
					--["superadmin"] = { "owner", 60*240 },
				 }
--------- EDITABLE AREA

-- Don't edit below unless you know what you're doing.

local function formattime( time )
    local days = tonumber(os.date("!%j",time))-1
    return os.date("!"..days.." days, %H:%M:%S",time)
end

function PLUGIN:Initialize()
	if(self.RankUps && table.Count(self.RankUps) == 0) then return end
	timer.Create("EV_RankOverTime",1,0,function()
		for k,ply in ipairs( player.GetAll() ) do
			local BlockRankOverTime = ply:GetProperty("BlockRankOverTime",false)
			if (BlockRankOverTime != true) then
				local PlayTime = ply:GetProperty( "PlayTime" )
				if (PlayTime) then
					local CurPlayTime = math.Round(PlayTime + ply:TimeConnected())
					if (self.RankUps[ply:EV_GetRank()]) then
						local NextRankUp = self.RankUps[ply:EV_GetRank()]
						if (CurPlayTime and NextRankUp and NextRankUp[2] and CurPlayTime > NextRankUp[2]) then
							ply:EV_SetRank(NextRankUp[1])
							evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has been ranked up to ", evolve.colors.red, NextRankUp[1], evolve.colors.white, " for playing on the server for ", evolve.colors.red, formattime(NextRankUp[2]), evolve.colors.white, "." )
						end
					end
				end
			end
		end
	end)
end

function PLUGIN:Call( ply, args )

	if (args and args[1] and args[1] == "block" and ply:EV_HasPrivilege( "Block ranks over time" )) then
		if (args[2]) then
			local temp = evolve:FindPlayer(args[2],false)
			if (temp and temp[1] and temp[1]:IsPlayer()) then
				temp[1]:SetProperty("BlockRankOverTime",true)
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has blocked ", evolve.colors.red, temp[1]:Nick(), evolve.colors.white, " from ranking over time." )
			end
		end
	elseif (args and args[1] and args[1] == "unblock" and ply:EV_HasPrivilege( "Block ranks over time" )) then
		if (args[2]) then
			local temp = evolve:FindPlayer(args[2],false)
			if (temp and temp[1] and temp[1]:IsPlayer()) then
				temp[1]:SetProperty("BlockRankOverTime",nil)
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has unblocked ", evolve.colors.red, temp[1]:Nick(), evolve.colors.white, "'s ranking over time." )
			end
		end
	else
		local tply = ply
		if (args and #args > 0) then
			local temp = evolve:FindPlayer( args[1], false )
			if (temp and temp[1] and temp[1]:IsPlayer()) then
				tply = temp[1]
			end
		end

		local BlockRankOverTime = ply:GetProperty("BlockRankOverTime",false)
		if (BlockRankOverTime != true) then
			local PlayTime = tply:GetProperty( "PlayTime" )
			if (PlayTime) then
				local CurPlayTime = math.Round(PlayTime + tply:TimeConnected())
				if (self.RankUps[tply:EV_GetRank()]) then
					local NextRankUp = self.RankUps[tply:EV_GetRank()]
					if (CurPlayTime and NextRankUp and NextRankUp[2]) then
						evolve:Notify( ply, evolve.colors.blue, tply:Nick(), evolve.colors.white, " has played on this server for ",evolve.colors.red, formattime(CurPlayTime), evolve.colors.white, "." )
						evolve:Notify( ply, evolve.colors.blue, tply:Nick(), evolve.colors.white, " will rank up in ",evolve.colors.red, formattime(NextRankUp[2]-CurPlayTime), evolve.colors.white, "." )
						evolve:Notify( ply, evolve.colors.blue, tply:Nick(), evolve.colors.white, " will become a(n) ",evolve.colors.red, NextRankUp[1], evolve.colors.white, " after the next rankup." )
					else
						evolve:Notify( ply, evolve.colors.blue, tply:Nick(), evolve.colors.white, " will not rank up. Have they already reached the max rank?" )
					end
				else
					evolve:Notify( ply, evolve.colors.blue, tply:Nick(), evolve.colors.white, " will not rank up. Have they already reached the max rank?" )
				end
			end
		else
			evolve:Notify( ply, evolve.colors.blue, tply:Nick(), evolve.colors.white, " will not rank up because their rank over time has been blocked." )
		end
	end
end

evolve:RegisterPlugin( PLUGIN )