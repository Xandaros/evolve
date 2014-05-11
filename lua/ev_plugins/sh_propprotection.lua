local PLUGIN = {}
PLUGIN.Title = "Prop Protection";
PLUGIN.Description = "A Plugin to prevent minges from spawning blacklisted props and touching others props";
PLUGIN.Author = "Northdegree";
PLUGIN.Privileges = { "Can Spawn Blacklist", "Manage BlackList", "Can Touch WorldProps"};
PLUGIN.ChatCommand = "friends"
PLUGIN.Usage = "<add/remove/get> (Name/SteamID)"
PP_Settings = {};
PP_Blacklist = {};


/*================ Add/Remove Func ==========================*/
/*-----------------------------------------------------
  --                    FRIENDS                      --
  ---------------------------------------------------*/
function PLUGIN:Call( ply, args )
	local action = args[1]
	if action == "add" then
		if not ply.PP_Friends then ply.PP_Friends = {} end
		if not args[2] then ply:SendLua("GAMEMODE:AddNotify(\"Missing Argument(s)\", NOTIFY_ERROR, 5)") return end
		local findply = evolve:FindPlayer( args[2] )
		if ( #findply > 1 ) then
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
			return
		end
		if ( #findply == 0) then ply:SendLua("GAMEMODE:AddNotify(\""..args[2].." cannot be found!\", NOTIFY_ERROR, 5)") return end
		findply = findply[1]
		if ( findply == ply) then ply:SendLua("GAMEMODE:AddNotify(\"You cant add yourself as your friend!\", NOTIFY_ERROR, 5)") return end
		local findsteam = findply:SteamID()
		local findname = findply:Nick()
		if CheckFriendship(ply, findply) then ply:SendLua("GAMEMODE:AddNotify(\""..findname.." is already in your Friendlist!\", NOTIFY_ERROR, 5)") return end
		table.insert(ply.PP_Friends, {findsteam, findname})
		sql.Query("INSERT INTO `ev_pp_friends` (ply,friendid,friendname) VALUES ("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(findsteam)..","..sql.SQLStr(findname)..");")
		ply:SendLua("GAMEMODE:AddNotify(\""..findname.." has been added to your Friendlist!\", NOTIFY_GENERIC, 5)")
		findply:SendLua("GAMEMODE:AddNotify(\"You now can touch "..ply:Nick().."'s Props!\", NOTIFY_GENERIC, 5)")
	elseif action == "remove" then
		if string.match( args[2],"STEAM_[0-5]:[0-9]:[0-9]+") then
			if not ply.PP_Friends then ply.PP_Friends = {} end
			if not args[2] then ply:SendLua("GAMEMODE:AddNotify(\"Missing Argument(s)\", NOTIFY_ERROR, 5)") return end
			local findsteam = args[2]
			if !CheckFriendship(ply,findsteam) then ply:SendLua("GAMEMODE:AddNotify(\"This Player is not in your Friendlist!\", NOTIFY_ERROR, 5)") return end
			local findname = ""
			for k,v in pairs(ply.PP_Friends) do
				if v[1] == findsteam then
					findname = v[2]
					table.remove(ply.PP_Friends, k)
				end
			end
			sql.Query("DELETE FROM `ev_pp_friends` WHERE `ply`="..sql.SQLStr(ply:SteamID()).." AND `friendid`="..sql.SQLStr(findsteam)..";")
			ply:SendLua("GAMEMODE:AddNotify(\""..findname.." has been removed from your Friendlist!\", NOTIFY_GENERIC, 5)")
		else
			if not ply.PP_Friends then ply.PP_Friends = {} end
			if not args[2] then ply:SendLua("GAMEMODE:AddNotify(\"Missing Argument(s)\", NOTIFY_ERROR, 5)") return end
			local findply = evolve:FindPlayer( args[2] )
			if ( #findply > 1 ) then
				evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
				return
			end
			if ( #findply == 0) then ply:SendLua("GAMEMODE:AddNotify(\""..args[2].." cannot be found!\", NOTIFY_ERROR, 5)") return end
			findply = findply[1]
			if ( findply == ply) then ply:SendLua("GAMEMODE:AddNotify(\"You are not your own friend!\", NOTIFY_ERROR, 5)") return end
			local findsteam = findply:SteamID()
			local findname = findply:Nick()
			if !CheckFriendship(ply,findsteam) then ply:SendLua("GAMEMODE:AddNotify(\""..findname.." is not in your Friendlist!\", NOTIFY_ERROR, 5)") return end
			for k,v in pairs(ply.PP_Friends) do
				if v[1] == findsteam then
					table.remove(ply.PP_Friends, k)
				end
			end
			sql.Query("DELETE FROM `ev_pp_friends` WHERE `ply`="..sql.SQLStr(ply:SteamID()).." AND `friendid`="..sql.SQLStr(findsteam)..";")
			ply:SendLua("GAMEMODE:AddNotify(\""..findname.." has been removed from your Friendlist!\", NOTIFY_GENERIC, 5)")
			findply:SendLua("GAMEMODE:AddNotify(\"You can't touch "..ply:Nick().."'s Props anymore!\", NOTIFY_GENERIC, 5)")
		end
	else
		if not ply.PP_Friends then ply.PP_Friends = {} end
		evolve:Notify(ply, evolve.colors.blue, ply:Nick().."'s friendlist :")
		for index,frply in pairs(ply.PP_Friends) do
			evolve:Notify(ply, evolve.colors.blue, frply[2], evolve.colors.white, " ("..frply[1]..")")
		end
		evolve:Notify(ply, evolve.colors.blue, "-------------------------")
	end
end


  ---------------------------------------------------*/
local function savePPSettings(ply, cmd, args)
	for sname,setting in pairs(PP_Settings) do
		if (ConVarExists("ev_"..sname)) then
			sql.Query("UPDATE `ev_pp_settings` SET `"..sname.."`='"..GetConVar("ev_"..sname):GetString().."';")
		end
	end
end
concommand.Add("ev_pp_save_settings", savePPSettings)
timer.Create("PP Autosave",60,0,savePPSettings)
/*-----------------------------------------------------
  --                  Blacklist                      --
  ---------------------------------------------------*/
local function PP_AddBlackList(ply, cmd, args)
	if !ply:EV_HasPrivilege( "Manage BlackList" ) then ply:SendLua("GAMEMODE:AddNotify(\"You are not allowed to do that!\", NOTIFY_ERROR, 5)") return end
	if not args[1] then ply:SendLua("GAMEMODE:AddNotify(\"Invalid Argument(s)\", NOTIFY_ERROR, 3)") return end
	local model = string.lower(args[1])
	model = string.Replace(model, "\\", "/")
	if table.HasValue(PP_Blacklist,model) then ply:SendLua("GAMEMODE:AddNotify(\"This Model is already Black-/Whitelisted!\", NOTIFY_ERROR, 5)") return end
	table.insert(PP_Blacklist, model)
	sql.Query("INSERT INTO `ev_pp_blacklist` (model) VALUES ("..sql.SQLStr(model)..");")
	evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has added the Model ", evolve.colors.red, model, evolve.colors.white, " to the Black-/Whitelist." )
end
concommand.Add("ev_pp_add_blacklist", PP_AddBlackList)

local function PP_RemoveBlackList(ply, cmd, args)
	if !ply:EV_HasPrivilege( "Manage BlackList" ) then ply:SendLua("GAMEMODE:AddNotify(\"You are not allowed to do that!\", NOTIFY_ERROR, 5)") return end
	if not args[1] then ply:SendLua("GAMEMODE:AddNotify(\"Invalid Argument(s)\", NOTIFY_ERROR, 3)") return end
	local model = string.lower(args[1])
	model = string.Replace(model, "\\", "/")
	if !table.HasValue(PP_Blacklist,model) then ply:SendLua("GAMEMODE:AddNotify(\"This Model is not Black-/Whitelisted!\", NOTIFY_ERROR, 5)") return end
	for k,v in pairs(PP_Blacklist) do
		if v == model then
			table.remove(PP_Blacklist, k)
		end
	end
	sql.Query("DELETE FROM `ev_pp_blacklist` WHERE `model`="..sql.SQLStr(model)..";")
	evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has removed the Model ", evolve.colors.red, model, evolve.colors.white, " from the Black-/Whitelist." )
end
concommand.Add("ev_pp_Remove_blacklist", PP_RemoveBlackList)

local function PP_GetBlackList(ply, cmd, args)
	for k,model in pairs(PP_Blacklist) do
			umsg.Start("ev_pp_blockedmodel", ply)
				umsg.String(model)
			umsg.End()
	end
end
concommand.Add("ev_pp_get_blacklist", PP_GetBlackList)
/*================ Blacklist ==========================*/

function loadPPBlacklist()
 	sql.Query("SELECT * FROM `ev_pp_blacklist`", function(results)
		if results then
			for k,v in pairs(results) do
				table.insert(PP_Blacklist, v.model)
			end
		end
	end)
end
/*====================================================*/
function CheckFriendship(ply,targetid)
	if not ply.PP_Friends then ply.PP_Friends = {} end
	local friends = false
	for k,v in pairs(ply.PP_Friends) do
		if v[1] == targetid then
			friends = true
			break
		end
	end
	return friends
end
function loadPPFriends(ply)
	local plysteamid = ply:SteamID()
 	sql.Query("SELECT * FROM `ev_pp_friends` WHERE `ply`="..sql.SQLStr(plysteamid).."", function(results)
		if results then
			for k,v in pairs(results) do
				local friendid = v.friendid
				local friendname = v.friendname
				table.insert(ply.PP_Friends, {friendid, friendname})
			end
		end
	end)
end

/*================ SETTINGS ==========================*/
function loadPPSettings()
 	local results=sql.Query("SELECT * FROM `ev_pp_settings`")
		if results then
			for k,v in pairs(results[1]) do
				PP_Settings[k]=v
				if v then
				CreateConVar("ev_"..k,tonumber(v))
				end
			end
		else
			sql.Query("INSERT INTO `ev_pp_settings` (ppison) VALUES ('1');"); // Creating default settings
			sql.Query("INSERT INTO `ev_pp_settings` (blacklistison) VALUES ('0');"); // Creating default settings
			sql.Query("INSERT INTO `ev_pp_settings` (blacklistiswhitelist) VALUES ('0');"); // Creating default settings
			loadPPSettings();
		end
end
/*====================================================*/
function FirstSpawn( ply )
	ply.PP_Friends = {}
 	loadPPFriends(ply)
end
hook.Add( "PlayerInitialSpawn", "PP_Friends_Load_On_Connect", FirstSpawn )

function PLUGIN:Initialize()
	if SERVER then
		/* CREATING ALL TABLES */
		if (!sql.TableExists("ev_pp_settings")) then
			sql.Query("CREATE TABLE `ev_pp_settings` (`ppison` INT DEFAULT '1',`blacklistison` INT DEFAULT '1',`blackiswhitelist` INT DEFAULT '0',`highercantouchlowerrank` INT DEFAULT '1');")
		end
		if (!sql.TableExists("ev_pp_blacklist")) then
			sql.Query("CREATE TABLE `ev_pp_blacklist` (`model` varchar(999));")
		end
		if (!sql.TableExists("ev_pp_friends")) then
			sql.Query("CREATE TABLE `ev_pp_friends` (`ply` varchar(999),`friendid` varchar(999),`friendname` varchar(999));")
		end
		loadPPSettings();
		loadPPBlacklist();
		if FPP then
			RunConsoleCommand("ev_ppison","0")
		end
	end
end
function CustInit()
	if SERVER then
		/* CREATING ALL TABLES */
		if (!sql.TableExists("ev_pp_settings")) then
			sql.Query("CREATE TABLE `ev_pp_settings` (`ppison` INT DEFAULT '1',`blacklistison` INT DEFAULT '1',`blackiswhitelist` INT DEFAULT '0',`highercantouchlowerrank` INT DEFAULT '1');")
		end
		if (!sql.TableExists("ev_pp_blacklist")) then
			sql.Query("CREATE TABLE `ev_pp_blacklist` (`model` varchar(999));")
		end
		if (!sql.TableExists("ev_pp_friends")) then
			sql.Query("CREATE TABLE `ev_pp_friends` (`ply` varchar(999),`friendid` varchar(999),`friendname` varchar(999));")
		end
		loadPPSettings();
		loadPPBlacklist();
		if FPP then
			RunConsoleCommand("ev_ppison","0")
		end
	end
end

//======================== DONT EDIT SOMETHING BELOW THIS UNLESS YOU KNOW WHAT YOU DO!!! =========================================
if SERVER then
	hook.Add("PlayerSpawnProp", "PP_BLACKLIST_CHECK", function(ply, model)
		/* -------------- BLACKLIST -------------- */
		if GetConVar("ev_blacklistison"):GetInt() == 1 then
			if table.HasValue(PP_Blacklist,string.lower(model)) then
				if GetConVar("ev_blackiswhitelist"):GetInt() == 0 then
					if !ply:EV_HasPrivilege( "Can Spawn Blacklist" ) then
						ply:SendLua("GAMEMODE:AddNotify(\"This Model is Blacklisted!\", NOTIFY_ERROR, 3)")
						return false
					else
						return true
					end
				end
			else
				if GetConVar("ev_blackiswhitelist"):GetInt() == 1 then
					if !ply:EV_HasPrivilege( "Can Spawn Blacklist" ) then
						ply:SendLua("GAMEMODE:AddNotify(\"This Model is Blacklisted!\", NOTIFY_ERROR, 3)")
						return false
					else
						return true
					end
				end
			end
		else
			return true
		end
	end)
	/* Physgun Pickup Control*/
	function PlayerPickup(ply, ent)
		local owner = ent:GetNWEntity("Owner")
		local steamid = ent:GetNWString("OwnerID")
		local plysteam = ply:SteamID()
		if !ent:IsPlayer() then
			if (GetConVar("ev_ppison"):GetInt() == 0) or (IsValid(owner) and CheckFriendship(owner,plysteam)) or (steamid == "" and ply:EV_HasPrivilege("Can Touch WorldProps")) or CanTouch(ply, ent) then
				if ply:EV_HasPrivilege("Can Touch WorldProps") and (steamid=="") then
					return true
				elseif (steamid!="") then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
	hook.Add("PhysgunPickup", "PP_Physgun_Pickup", PlayerPickup)
	function CusCanTool( ply, tr, class )
		if ( GAMEMODE.IsSandboxDerived and table.HasValue( evolve.privileges, "#" .. class ) and !ply:EV_HasPrivilege( "#" .. class ) ) then
			evolve:Notify( ply, evolve.colors.red, "You are not allowed to use this tool!" )
			return false
		end
		return true
	end

	function UseTool(ply, trace, toolmode)
		local ent = trace.Entity
		local owner = ent:GetNWEntity("Owner")
		local steamid = ent:GetNWString("OwnerID")
		local plysteam = ply:SteamID()
		if CusCanTool( ply, trace, toolmode)  then
			if (GetConVar("ev_ppison"):GetInt() == 0) or (IsValid(owner) and CheckFriendship(owner,plysteam)) or (!IsValid(owner) and steamid == "" and ply:EV_HasPrivilege("Can Touch WorldProps")) or CanTouch(ply, ent) or !IsValid(ent) then
				return true
			else
				return false
			end
		else
			if (ConVarExists("ev_restrict_tools")) then
				if (GetConVarNumber("ev_restrict_tools")==0) then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
	hook.Add("CanTool", "PP_ToolGun_Use", UseTool)
end
if cleanup then
	oldcleanup = oldcleanup or cleanup.Add
	function cleanup.Add(ply, Type, ent)
		if IsValid(ply) and IsValid(ent) then
			ent:SetNWEntity("Owner", ply)
			ent:SetNWString("OwnerID", ply:SteamID())
			if ent:GetClass() == "gmod_wire_expression2" then
				ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end
		return oldcleanup(ply, Type, ent)
	end
end


function CanTouch(ply, ent)
	local owner = ent:GetNWEntity("Owner")
	if (ent:GetNWString("OwnerID") == ply:SteamID()) then
		return true
	else
		if (SERVER and IsValid(owner) and ply:EV_BetterThan(owner) and GetConVar("ev_highercantouchlowerrank"):GetInt() == 1) then
			return true
		else
			if !IsValid(owner) then
				return true
			else
				return false
			end
		end
	end
end
/* Show the Owner */
if CLIENT then
	local function HUDPaint()
		local LookingEnt = LocalPlayer():GetEyeTraceNoCursor().Entity
		local LEOwner = LookingEnt:GetNWString("OwnerID")
		if LEOwner == "" then LEOwner = "World Prop" end
		if IsValid(LookingEnt) and !LookingEnt:IsPlayer() then
			local owner = LEOwner
			if LEOwner != "World Prop" then
				LEOwner = LookingEnt:GetNWEntity("Owner")
				local k,v = pcall(function() 
						if !IsValid(LEOwner) then owner="Disconnected Player" else owner=LEOwner:Nick() end 
					end)
				if !k then owner="Invalid Player" end
			end
			surface.SetFont("Default")
			local w,h = surface.GetTextSize(owner)
			local col = Color(255,0,0,255)
			pcall(
			function() 
				if CanTouch(LocalPlayer(),LookingEnt) then 
					col = Color(0,255,0,255) 
				else 
					col = Color(255,0,0,255) 
				end 
			end
			)
			draw.RoundedBox(4, 5, ScrH()/2 - h - 2, w + 10, 20, Color(0, 0, 0, 110))
			draw.DrawText(owner, "Default", 7, ScrH()/2 - h, col, 0)
			surface.SetDrawColor(255,255,255,255)
		end
	end
	hook.Add("HUDPaint", "PP_Show_Owner", HUDPaint)
end
/*---------------Console Command*/
function evPropParseCommand( ply, comm, args )
	local action = args[1]
	if action == "add" then
		if not ply.PP_Friends then ply.PP_Friends = {} end
		if not args[2] then ply:SendLua("GAMEMODE:AddNotify(\"Missing Argument(s)\", NOTIFY_ERROR, 5)") return end
		local findply = evolve:FindPlayer( args[2] )
		if ( #findply > 1 ) then
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
			return
		end
		if ( #findply == 0) then ply:SendLua("GAMEMODE:AddNotify(\""..args[2].." cannot be found!\", NOTIFY_ERROR, 5)") return end
		findply = findply[1]
		if ( findply == ply) then ply:SendLua("GAMEMODE:AddNotify(\"You cant add yourself as your friend!\", NOTIFY_ERROR, 5)") return end
		local findsteam = findply:SteamID()
		local findname = findply:Nick()
		if CheckFriendship(ply, findply) then ply:SendLua("GAMEMODE:AddNotify(\""..findname.." is already in your Friendlist!\", NOTIFY_ERROR, 5)") return end
		table.insert(ply.PP_Friends, {findsteam, findname})
		sql.Query("INSERT INTO `ev_pp_friends` (ply,friendid,friendname) VALUES ("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(findsteam)..","..sql.SQLStr(findname)..");")
		ply:SendLua("GAMEMODE:AddNotify(\""..findname.." has been added to your Friendlist!\", NOTIFY_GENERIC, 5)")
		findply:SendLua("GAMEMODE:AddNotify(\"You now can touch "..ply:Nick().."'s Props!\", NOTIFY_GENERIC, 5)")
	elseif action == "remove" then
		if string.match( args[2],"STEAM_[0-5]:[0-9]:[0-9]+") then
			if not ply.PP_Friends then ply.PP_Friends = {} end
			if not args[2] then ply:SendLua("GAMEMODE:AddNotify(\"Missing Argument(s)\", NOTIFY_ERROR, 5)") return end
			local findsteam = args[2]
			if !CheckFriendship(ply,findsteam) then ply:SendLua("GAMEMODE:AddNotify(\"This Player is not in your Friendlist!\", NOTIFY_ERROR, 5)") return end
			local findname = ""
			for k,v in pairs(ply.PP_Friends) do
				if v[1] == findsteam then
					findname = v[2]
					table.remove(ply.PP_Friends, k)
				end
			end
			sql.Query("DELETE FROM `ev_pp_friends` WHERE `ply`="..sql.SQLStr(ply:SteamID()).." AND `friendid`="..sql.SQLStr(findsteam)..";")
			ply:SendLua("GAMEMODE:AddNotify(\""..findname.." has been removed from your Friendlist!\", NOTIFY_GENERIC, 5)")
		else
			if not ply.PP_Friends then ply.PP_Friends = {} end
			if not args[2] then ply:SendLua("GAMEMODE:AddNotify(\"Missing Argument(s)\", NOTIFY_ERROR, 5)") return end
			local findply = evolve:FindPlayer( args[2] )
			if ( #findply > 1 ) then
				evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
				return
			end
			if ( #findply == 0) then ply:SendLua("GAMEMODE:AddNotify(\""..args[2].." cannot be found!\", NOTIFY_ERROR, 5)") return end
			findply = findply[1]
			if ( findply == ply) then ply:SendLua("GAMEMODE:AddNotify(\"You are not your own friend!\", NOTIFY_ERROR, 5)") return end
			local findsteam = findply:SteamID()
			local findname = findply:Nick()
			if !CheckFriendship(ply,findsteam) then ply:SendLua("GAMEMODE:AddNotify(\""..findname.." is not in your Friendlist!\", NOTIFY_ERROR, 5)") return end
			for k,v in pairs(ply.PP_Friends) do
				if v[1] == findsteam then
					table.remove(ply.PP_Friends, k)
				end
			end
			sql.Query("DELETE FROM `ev_pp_friends` WHERE `ply`="..sql.SQLStr(ply:SteamID()).." AND `friendid`="..sql.SQLStr(findsteam)..";")
			ply:SendLua("GAMEMODE:AddNotify(\""..findname.." has been removed from your Friendlist!\", NOTIFY_GENERIC, 5)")
			findply:SendLua("GAMEMODE:AddNotify(\"You can't touch "..ply:Nick().."'s Props anymore!\", NOTIFY_GENERIC, 5)")
		end
	else
		if not ply.PP_Friends then ply.PP_Friends = {} end
		evolve:Notify(ply, evolve.colors.blue, ply:Nick().."'s friendlist :")
		for index,frply in pairs(ply.PP_Friends) do
			evolve:Notify(ply, evolve.colors.blue, frply[2], evolve.colors.white, " ("..frply[1]..")")
		end
		evolve:Notify(ply, evolve.colors.blue, "-------------------------")
	end
end

concommand.Add("EvPropParseCon",evPropParseCommand)
CustInit()
evolve:RegisterPlugin( PLUGIN )