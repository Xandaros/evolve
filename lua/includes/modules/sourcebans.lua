--[[
	~ Sourcebans Module ~
	~ Lexi ~
	WARNING:
	Do *NOT* run with sourcemod active. It will have unpredictable effects!
--]]

require("mysqloo");
-- These are put here to lower the amount of upvalues and so they're grouped together
-- They provide something like the documentation the SM ones do. 
CreateConVar("sb_version", "1.41", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY, "The current version of the SourceBans.lua module");
-- This creates a fake concommand that doesn't exist but makes the engine think it does. Useful.
AddConsoleCommand("sb_reload", "Doesn't do anything - Legacy from the SourceMod version.");

local error, ErrorNoHalt, GetConVarNumber, GetConVarString, Msg, pairs, print, ServerLog, tonumber, tostring, unpack =
      error, ErrorNoHalt, GetConVarNumber, GetConVarString, Msg, pairs, print, ServerLog, tonumber, tostring, unpack ;

local concommand, game, hook, math, os, player, string, table, timer, mysqloo =
      concommand, game, hook, math, os, player, string, table, timer, mysqloo ;

---
-- Sourcebans.lua provides an interface to SourceBans through GLua, so that SourceMod is not required.
-- It also attempts to duplicate the effects that would be had by running SourceBans, such as the concommand and convars it creates.
-- @release version 1.41 Now with better integration support (and more oddity fixes)!
module("sourcebans");
--[[

	CreateConVar("sb_version", SB_VERSION, _, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	RegServerCmd("sm_rehash",sm_rehash,"Reload SQL admins");
	RegAdminCmd("sm_ban", CommandBan, ADMFLAG_BAN, "sm_ban <#userid|name> <minutes|0> [reason]");
	RegAdminCmd("sm_banip", CommandBanIp, ADMFLAG_BAN, "sm_banip <ip|#userid|name> <time> [reason]");
	RegAdminCmd("sm_addban", CommandAddBan, ADMFLAG_RCON, "sm_addban <time> <steamid> [reason]");
	RegAdminCmd("sb_reload", ADMFLAG_RCON, "Reload sourcebans config and ban reason menu options");
	RegAdminCmd("sm_unban", CommandUnban, ADMFLAG_UNBAN, "sm_unban <steamid|ip> [reason]");
--]]
--[[ Config ]]--
local config = {
	hostname = "localhost";
	username = "root";
	password = "";
	database = "sourcebans";
	dbprefix = "sbans";
	website  = "";
	portnumb = 3306;
	serverid = -1;
	dogroups = false;
};
--[[ Automatic IP Locator ]]--
local serverport = GetConVarNumber("hostport");
local serverip;
do -- Thanks raBBish! http://www.facepunch.com/showpost.php?p=23402305&postcount=1382
	local function band( x, y )
		local z, i, j = 0, 1
		for j = 0,31 do
			if ( x%2 == 1 and y%2 == 1 ) then
				z = z + i
			end
			x = math.floor( x/2 )
			y = math.floor( y/2 )
			i = i * 2
		end
		return z
	end
	local hostip = tonumber(string.format("%u", GetConVarString("hostip")))
	local parts = {
		band( hostip / 2^24, 0xFF );
		band( hostip / 2^16, 0xFF );
		band( hostip / 2^8, 0xFF );
		band( hostip, 0xFF );
	}
	
	serverip = string.format( "%u.%u.%u.%u", unpack( parts ) )
end
--]]

--[[ Tables ]]--
local admins, adminsByID, adminGroups, database;
local queries = {
	-- BanChkr
	["Check for Bans"] = "SELECT bid, name, ends, authid, ip FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND (authid = '%s' OR ip = '%s') LIMIT 1";
	["Check for Bans by IP"] = "SELECT bid, name, ends, authid, ip FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND ip = '%s' LIMIT 1";
	["Check for Bans by SteamID"] = "SELECT bid, name, ends, authid, ip FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND authid = '%s' LIMIT 1";
	["Get All Active Bans"] = "SELECT ip, authid, name, created, ends, length, reason, aid  FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL;";
	
	["Log Join Attempt"] = "INSERT INTO %s_banlog (sid, time, name, bid) VALUES( %i, %i, '%s', %i)";
	
	-- Admins
	["Select Admin Groups"] = "SELECT flags, immunity, name FROM %s_srvgroups";
	["Select Admins"] = "SELECT a.aid, a.user, a.authid, a.srv_group, a.srv_flags, a.immunity FROM %s_admins a, %s_admins_servers_groups g WHERE g.server_id = %i AND g.admin_id = a.aid";
	
	-- Bannin
	["Ban Player"] = "INSERT INTO %s_bans (ip, authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES('%s', '%s', '%s', %i, %i, %i, '%s', %i, '%s', %i, ' ')";
	
	-- Unbannin
	["Unban SteamID"] = "UPDATE %s_bans SET RemovedBy = %i, RemoveType = 'U', RemovedOn = UNIX_TIMESTAMP(), ureason = '%s' WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND authid = '%s'";
	["Unban IPAddress"] = "UPDATE %s_bans SET RemovedBy = %i, RemoveType = 'U', RemovedOn = UNIX_TIMESTAMP(), ureason = '%s' WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND ip = '%s'";
};

--[[ ENUMs ]]--
-- Sourcebans
FLAG_BAN 	= "d";
FLAG_PERMA	= "e";
FLAG_UNBAN	= "e";
FLAG_ADDBAN	= "m";

-- The mysqloo ones are descriptive, but a mouthful.
STATUS_READY	= mysqloo.DATABASE_CONNECTED;
STATUS_WORKING	= mysqloo.DATABASE_CONNECTING;
STATUS_OFFLINE	= mysqloo.DATABASE_NOT_CONNECTED;
STATUS_ERROR	= mysqloo.DATABASE_INTERNAL_ERROR;

--[[ Convenience Functions ]]--
local function notifyerror(...)
	ErrorNoHalt("[", os.date(), "][SourceBans.lua] ", ...);
	print();
end
local function notifymessage(...)
	local words = table.concat({"[",os.date(),"][SourceBans.lua] ",...},"").."\n";
	ServerLog(words);
	Msg(words);
end
local function banid(id)
	game.ConsoleCommand("banid 5 " .. id .. "\n");
end
local function kickid(id)
	game.ConsoleCommand("kickid " .. id .. " You are BANNED from this server!\n");
end
local function cleanIP(ip)
	return string.match(ip, "(%d+%.%d+%.%d+%.%d+)");
end
local function getIP(ply)
	return cleanIP(ply:IPAddress());
end
local function getAdminDetails(admin)
	if (admin and admin:IsValid()) then
		local data = admins[admin:SteamID()]
		if (data) then
			return data.aid, getIP(admin);
		end
	end
	return 0, serverip;
end
local function blankCallback() end


--[[ Query Functions ]]--
local checkBan, banCheckerOnData, banCheckerOnFailure;
local joinAttemptLoggerOnFailure;
local adminGroupLoaderOnSuccess, adminGroupLoaderOnFailure;
local loadAdmins, adminLoaderOnData, adminLoaderOnFailure;
local doBan, banOnSuccess, banOnFailure;
local startDatabase, databaseOnConnected, databaseOnFailure;
local activeBansOnSuccess, activeBansOnFailure;
local doUnban, unbanOnFailure;
local checkBanBySteamID, checkSIDOnSuccess, checkSIDOnFailure;

-- Functions --
function checkBan(ply, steamID, ip, name)
	local queryText = queries["Check for Bans"]:format(config.dbprefix, steamID, ip);
	local query = database:query(queryText);
	if (query) then
		query.steamID	= steamID;
		query.player	= ply;
		query.name		= name;
		query.onData	= banCheckerOnData;
		query.onFailure	= banCheckerOnFailure;
		query:start();
	else
		table.insert(database.pending, {queryText, steamID, name, ply});
		CheckStatus();
	end
end

function checkBanBySteamID(steamID, callback)
	local query = database:query(queries["Check for Bans by SteamID"]:format(config.dbprefix, steamID));
		query.steamID	= steamID;
		query.callback  = callback;
		query.onSuccess	= checkSIDOnSuccess;
		query.onFailure	= checkSIDOnFailure;
		query:start();
end

function loadAdmins()
	admins = {};
	adminGroups = {};
	adminsByID = {};
	local query = database:query(queries["Select Admin Groups"]:format(config.dbprefix));
	query.onFailure = adminGroupLoaderOnFailure;
	query.onSuccess = adminGroupLoaderOnSuccess;
	query:start();
	notifymessage("Loading Admin Groups . . .");
end

function startDatabase()
	database = mysqloo.connect(config.hostname, config.username, config.password, config.database, config.portnumb);
	database.onConnected = databaseOnConnected;
	database.onConnectionFailed = databaseOnFailure;
	database.pending = {};
	database:connect();
end

function doUnban(query, id, reason, admin)
	local aid = getAdminDetails(admin)
	query = database:query(query:format(config.dbprefix, aid, database:escape(reason), id));
	query.onFailure = unbanOnFailure;
	query.id = id;
	query:start();
end

function doBan(steamID, ip, name, length, reason, admin, callback)
	local time = os.time();
	local adminID, adminIP = getAdminDetails(admin);
	name = name or "";
	local query = database:query(queries["Ban Player"]:format(config.dbprefix, ip, steamID, database:escape(name), time, time + length, length, database:escape(reason), adminID, adminIP, config.serverid));
	query.onSuccess = banOnSuccess;
	query.onFailure = banOnFailure;
	query.callback = callback;
	query.name = name;
	query:start();
	if (steamID ~= "") then
		kickid(steamID);
		banid(steamID);
	end
end
-- Data --
function banCheckerOnData(self, data)
	notifymessage(self.name, " has been identified as ", data.name, ", who is banned. Kicking ... ");
	kickid(self.steamID);
	banid(self.steamID);
	local query = database:query(queries["Log Join Attempt"]:format(config.dbprefix, config.serverid, os.time(), self.name, data.bid));
	query.onFailure = joinAttemptLoggerOnFailure;
	query.name = self.name;
	query:start();
end

function adminLoaderOnData(self, data)
	data.srv_group = data.srv_group or "NO GROUP ASSIGNED";
	local group = adminGroups[data.srv_group];
	if (group) then
		data.srv_flags = (data.srv_flags or "") .. (group.flags or "");
		if (data.immunity < group.immunity) then
			data.immunity = group.immunity;
		end
	end
	if (string.find(data.srv_flags, 'z')) then
		data.zflag = true;
	end
	admins[data.authid] = data;
	adminsByID[data.aid] = data;
	notifymessage("Loaded admin ", data.user, " with group ", tostring(data.srv_group), ".");
end

-- Success --
function adminGroupLoaderOnSuccess(self)
	local data = self:getData();
	for _, data in pairs(data) do
		adminGroups[data.name] = data;
		notifymessage("Loaded admin group ", data.name);
	end
	local query = database:query(queries["Select Admins"]:format(config.dbprefix,config.dbprefix,config.serverid));
	query.onFailure = adminLoaderOnFailure;
	query.onData = adminLoaderOnData;
	query:start();	
	notifymessage("Loading Admins . . .");
end

function banOnSuccess(self)
	self.callback(true);
end

function databaseOnConnected(self)
	self.automaticretry = nil;
	if (config.serverid < 0) then
		local query = self:query("SELECT sid FROM %s_servers WHERE ip = '" .. serverip .. "' AND port = '" .. serverport .. "' LIMIT 1")
		query.onSuccess = function(self, data) config.sererid = data.sid; end;
		query:start();
	end
	if (not admins) then
		loadAdmins();
	end
	if (#self.pending == 0) then return; end
	local query, ply, steamID;
	for _, info in pairs(self.pending) do
		query 			= self:query(info[1]);
		query.steamID	= info[2];
		query.name		= info[3];
		query.player	= info[4];
		query.onData	= banCheckerOnData;
		query.onFailure	= banCheckerOnFailure;
		query:start();
	end
	self.pending = {};
end

function activeBansOnSuccess(self)
	local ret = {}
	local adminName, adminID;
	for _, data in pairs(self:getData()) do
		if (data.aid ~= 0) then
			local admin = adminsByID[data.aid];
			if (not admin) then -- 
				adminName = "Unknown";
				adminID = "STEAM_ID_UNKNOWN";
			else
				adminName = admin.user;
				adminID = admin.authid
			end
		else
			adminName = "Console";
			adminID = "STEAM_ID_SERVER";
		end
		
		ret[#ret + 1] = {
			IPAddress	= data.ip;
			SteamID		= data.authid;
			Name		= data.name;
			BanStart	= data.created;
			BanEnd		= data.ends;
			BanLength	= data.length;
			BanReason	= data.reason;
			AdminName	= adminName;
			AdminID		= adminID;
		}
	end
	self.callback(ret);
end

function checkSIDOnSuccess(self)
	self.callback(#self:getData() > 0);
end

-- Failure --
function banCheckerOnFailure(self, err)
	notifyerror("SQL Error while checking ", self.name, "'s ban status! ", err);
	kickid(self.steamID);
end

function joinAttemptLoggerOnFailure(self, err)
	notifyerror("SQL Error while storing ", self.name, "'s foiled join attempt! ", err);
end

function adminGroupLoaderOnFailure(self, err)
	notifyerror("SQL Error while loading the admin groups! ", err);
end

function adminLoaderOnFailure(self, err)
	notifyerror("SQL Error while loading the admins! ", err);
end

function banOnFailure(self, err)
	notifyerror("SQL Error while storing ", self.name, "'s ban! ", err);
	self.callback(false, err);
end

function databaseOnFailure(self, err)
	notifyerror("Failed to connect to the database: ", err, ". Retrying in 60 seconds.");
	self.automaticretry = true;
	timer.Simple(60, self.connect, self);
end

function activeBansOnFailure(self, err)
	notifyerror("SQL Error while loading all active bans! ", err);
	self.callback(false, err);
end

function unbanOnFailure(self, err)
	notifyerror("SQL Error while removing the ban for ", self.id, "! ", err);
end

function checkSIDOnFailure(self, err)
	notifyerror("SQL Error while checking ", self.steamID, "'s ban status! ", err);
	self.callback(false, err);
end
--[[ Hooks ]]--
do
	local function ShutDown()
		if (database) then
			database:abortAllQueries();
		end
	end

	local function PlayerAuthed(ply, steamID)
		if (not database) then
			notifyerror("Player ", ply:Name(), " joined, but SourceBans.lua is not active!");
			return;
		end
		checkBan(ply, steamID, getIP(ply), ply:Name());
		if (not admins) then
			return;
		end
		local info = admins[ply:SteamID()];
		if (info) then
			if (config.dogroups) then
				ply:SetUserGroup(string.lower(info.srv_group))
			end
			ply.sourcebansinfo = info;
			notifymessage(ply:Name(), " has joined, and they are a ", tostring(info.srv_group), "!");
		end
	end

	hook.Add("ShutDown", "SourceBans.lua - ShutDown", ShutDown);
	hook.Add("PlayerAuthed", "SourceBans.lua - PlayerAuthed", PlayerAuthed);
end


--[[ Exported Functions ]]--		
local function checkConnection()
	return database and database:query("") ~= nil;
end

---
-- Starts the database and activates the module's functionality.
function Activate()
	startDatabase();
	notifymessage("Starting the database.");
end

---
-- Bans a player by object
-- @param ply The player to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayer(ply, time, reason, admin, callback)
	callback = callback or blankCallback;
	if (not checkConnection()) then
		return callback(false, "No Database Connection");
	elseif (not ply:IsValid()) then
		error("Expected player, got NULL!", 2);
	end
	local sid = ply:SteamID();
	doBan(sid, getIP(ply), ply:Name(), time, reason, admin, callback);
	kickid(sid);
end

---
-- Bans a player by steamID
-- @param steamID The SteamID to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param name (Optional) The name to give the ban if no active player matches the SteamID.
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayerBySteamID(steamID, time, reason, admin, name, callback)
	callback = callback or blankCallback;
	if (not checkConnection()) then
		return callback(false, "No Database Connection");
	end
	for _, ply in pairs(player.GetAll()) do
		if (ply:SteamID() == steamID) then
			return BanPlayer(ply, time, reason, admin, callback);
		end
	end
	doBan(steamID, '', name, time, reason, admin, callback)
end

---
-- Bans a player by IPAddress
-- @param ip The IPAddress to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param name (Optional) The name to give the ban if no active player matches the IP.
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayerByIP(ip, time, reason, admin, name, callback)
	callback = callback or blankCallback;
	if (not checkConnection()) then
		return callback(false, "No Database Connection");
	end
	for _, ply in pairs(player.GetAll()) do
		if (getIP(ply) == ip) then
			return BanPlayer(ply, time, reason, admin, callback);
		end
	end
	doBan('', cleanIP(ip), name, time, reason, admin, callback);
	game.ConsoleCommand("addip 5 " .. ip .. "\n");
end

---
-- Bans a player by object
-- @param ply The player to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayer(ply, time, reason, admin, callback)
	callback = callback or blankCallback;
	if (not checkConnection()) then
		return callback(false, "No Database Connection");
	elseif (not ply:IsValid()) then
		error("Expected player, got NULL!", 2);
	end
	doBan(ply:SteamID(), getIP(ply), ply:Name(), time, reason, admin, callback);
end

---
-- Bans a player by SteamID and IPAddress
-- @param steamID The SteamID to ban
-- @param ip The IPAddress to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param name (Optional) The name to give the ban
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayerBySteamIDAndIP(steamID, ip, time, reason, admin, name, callback)
	callback = callback or blankCallback;
	if (not checkConnection()) then
		return callback(false, "No Database Connection");
	end
	doBan(steamID, cleanIP(ip), name, time, reason, admin, callback);
end


---
-- Unbans a player by SteamID
-- @param steamID The SteamID to unban
-- @param reason The reason they are being unbanned.
-- @param admin (Optional) The admin who did the unban. Leave nil for CONSOLE.
function UnbanPlayerBySteamID(steamID, reason, admin)
	if (not checkConnection()) then
		return false, "No Database Connection";
	end
	doUnban(queries["Unban SteamID"], steamID, reason, admin);
	game.ConsoleCommand("removeid " .. steamID .. "\n");
end

---
-- Unbans a player by IPAddress. If multiple players match the IP, they will all be unbanned.
-- @param ip The IPAddress to unban
-- @param reason The reason they are being unbanned.
-- @param admin (Optional) The admin who did the unban. Leave nil for CONSOLE.
function UnbanPlayerByIPAddress(ip, reason, admin)
	if (not checkConnection()) then
		return false, "No Database Connection";
	end
	doUnban(queries["Unban IPAddress"], ip, reason, admin);
	game.ConsoleCommand("removeip " .. ip .. "\n");
end

---
-- Fetches all currently active bans in a table.
-- If the ban was inacted by the server, the AdminID will be "STEAM_ID_SERVER".<br />
-- If the server does not know who the admin who commited the ban is, the AdminID will be "STEAM_ID_UNKNOWN".<br/>
-- Example table structure: <br/>
-- <pre>{ <br/>
-- &nbsp; BanStart = 1271453312, <br/>
-- &nbsp; BanEnd = 1271453312, <br/>
-- &nbsp; BanLength = 0, <br/>
-- &nbsp; BanReason = "'Previously banned for repeately crashing the server'", <br/>
-- &nbsp; IPAddress = "99.101.125.168", <br/>
-- &nbsp; SteamID = "STEAM_0:0:20924001", <br/>
-- &nbsp; Name = "MINOTAUR", <br/>
-- &nbsp; AdminName = "Lexi", <br/>
-- &nbsp; AdminID = "STEAM_0:1:16678762" <br/>
-- }</pre> <br/>
-- Bear in mind that SteamID or IPAddress may be a blank string.
-- @param callback The function to be given the table
function GetAllActiveBans(callback)
	if (not callback) then
		error("Function expected, got nothing!", 2);
	elseif (not checkConnection()) then
		return callback(false, "No Database Connection");
	end
	local query = database:query(queries["Get All Active Bans"]:format(config.dbprefix));
	query.onSuccess = activeBansOnSuccess;
	query.onFailure = activeBansOnFailure;
	query.callback = callback;
	query:start();
end

---
-- Set the config variables. Most will not take effect until the next database connection.<br />
-- NOTE: These settings do *NOT* persist. You will need to set them all each time.
-- @param key The settings key to set
-- @param value The value to set the key to.
-- @usage Acceptable keys: hostname, username, password, database, dbprefix, portnumb, serverid and dogroups.
function SetConfig(key, value)
	if (config[key] == nil) then
		error("Invalid key provided. Please check your information.",2);
	end
	if (key == "portnumb" or key == "serverid") then
		value = tonumber(value);
	end
	config[key] = value;
end


---
-- Checks the status of the database and recovers if there are errors
-- WARNING: This function is blocking. It is auto-called every 5 minutes.
function CheckStatus()
	if (not database or database.automaticretry) then return; end
	local status = database:status();
	if (status == STATUS_WORKING or status == STATUS_READY) then
		return;
	elseif (status == STATUS_ERROR) then
		notifyerror("The database object has suffered an inernal error and will be recreated.");
		local pending = database.pending;
		startDatabase();
		database.pending = pending;
	else
		notifyerror("The server has lost connection to the database. Retrying...")
		database:connect();
	end
end
timer.Create("SourceBans.lua - Status Checker", 300, 0, CheckStatus);

---
-- Checks to see if a SteamID is banned from the system
-- @param steamID The SteamID to check
-- @param callback The callback function to tell the results to
function CheckForBan(steamID, callback)
	if (not checkConnection()) then
		return callback(false, "No Database Connection");
	elseif (not callback) then
		error("Callback function required!", 2);
	elseif (not steamID) then
		error("SteamID required!", 2);
	end
	checkBanBySteamID(steamID, callback);
end

---
-- Gets all the admins active on this server
-- @returns A table.
function GetAdmins()
	local ret = {}
	for id,data in pairs(admins) do
		ret[id] = {
			Name = data.user;
			SteamID = id;
			UserGroup = data.srv_group;
			AdminID = data.aid;
			Flags = data.srv_flags;
			ZFlagged = data.zflag;
			Immunity = data.immunity;
		}
	end
	return ret;
end



--[[ ConCommands ]]--


-- Borrowed from my gamemode
local function playerGet(id)
	local res, len, name, num, pname, lon;
	name = string.lower(id);
	num = tonumber(id);
	if (res) then return res; end
	for _,ply in pairs(player.GetAll()) do
		pname = ply:Name():lower();
		if (ply:UserID() == num) then
			return ply;
		elseif (pname:find(name)) then
			lon = pname:len();
			if (res) then
				if (lon < len) then
					res = ply;
					len = lon;
				end
			else
				res = ply;
				len = lon;
			end
		end
	end
	return res;
end
local function complain(ply, msg)
	if (not (ply and ply:IsValid())) then
		print(msg);
		print("Consol",msg);
	else
		ply:PrintMessage(2--[[HUD_PRINTCONSOLE]], msg);
	end
	return false;
end
-- Gets a steamID from concommand calls that don't bother to quote it.
local function getSteamID(tab)
	local a,b,c,d,e = tab[1], tab[2], tonumber(tab[3]), tab[4], tonumber(tab[5]);
	if (string.find(a, "STEAM_%d:%d:%d+")) then
		return table.remove(tab, 1);
	elseif (string.find(a, "STEAM_") and b == ":" and c and d == ":" and e) then
		-- Kill the five entries as if they were one
		table.remove(tab, 1);
		table.remove(tab, 1);
		table.remove(tab, 1);
		table.remove(tab, 1);
		table.remove(tab, 1);
		return a .. b .. c .. d .. e;
	end
end
-- Check if a player has authorisation to run the command.
local function authorised(ply, flag)
	if (not (ply and ply:IsValid())) then
		return true;
	elseif (not ply.sourcebansinfo) then
		return false;
	end
	return ply.sourcebansinfo.zflag or string.find(ply.sourcebansinfo.srv_flags, flag);
end

local function complainer(ply, pl, time, reason, usage)
	if (not pl) then
		return complain(ply, "Invalid player!" .. usage);
	elseif (not time or time < 0) then
		return complain(ply, "Invalid time!" .. usage);
	elseif (reason == "") then
		return complain(ply, "Invalid reason!" .. usage);
	elseif (time == 0 and not authorised(ply, FLAG_PERMA)) then
		return complain(ply, "You are not authorised to permaban!");
	end
	return true;
end

concommand.Add("sm_rehash", function(ply)
	if (ply and ply:IsValid()) then return; end
	notifymessage("Rehash command recieved, reloading admins:");
	loadAdmins();
end, nil, "Reload the admin list from the SQL");

local usage = "\n - Usage: sm_ban <#userid|name> <minutes|0> <reason>";
concommand.Add("sm_ban", function(ply, _, args)
	if (#args < 3) then
		return complain(ply, usage:sub(4));
	elseif (not checkConnection()) then
		return complain(ply, "The database is not active at the moment. Your command could not be completed.");
	elseif (not authorised(ply, FLAG_BAN)) then
		return complain(ply, "You do not have access to this command!");
	end
	local pl, time, reason = table.remove(args,1), tonumber(table.remove(args,1)), table.concat(args, " "):Trim();
	pl = playerGet(pl);
	if (not complainer(ply, pl, time, reason, usage)) then
		return;
	end
	local name = pl:Name();
	local function callback(res, err)
		if (res) then
			complain(ply, "sm_ban: " .. name .. " has been banned successfully.")
		else
			complain(ply, "sm_ban: " .. name .. " has not been banned. " .. err);
		end
	end
	BanPlayer(pl, time * 60, reason, ply, callback);
	complain(ply, "sm_ban: Your ban request has been sent to the database.");
end, nil, "Bans a player" .. usage);

-- Author's note: Why would you want to only ban someone by only their IP when you have their SteamID? This is a stupid concommand. Hopefully no one will use it.
local usage = "\n - Usage: sm_banip <ip|#userid|name> <minutes|0> <reason>";
concommand.Add("sm_banip", function(ply, _, args)
	if (#args < 3) then
		return complain(ply, usage:sub(4));
	elseif (not checkConnection()) then
		return complain(ply, "The database is not active at the moment. Your command could not be completed.");
	elseif (not authorised(ply, FLAG_BAN)) then
		return complain(ply, "You do not have access to this command!");
	end
	local id, time, reason = table.remove(args,1), tonumber(table.remove(args,1)), table.concat(args, " "):Trim();
	local pl;
	if (string.find(id, "%d+%.%d+%.%d+%.%d+")) then
		for _, ply in pairs(player.GetAll()) do
			if (ply:SteamID() == id) then
				pl = ply; 
				break;
			end
		end
		id = cleanIP(id);
	else
		pl = playerGet(id)
		id = nil;
		if (pl) then
			id = getIP(pl);
		end
	end
	if (not complainer(ply, pl, time, reason, usage)) then
		return;
	end
	local name = pl:Name();
	kickid(pl:SteamID());
	game.ConsoleCommand("addip 5 " .. id .. "\n");
	local function callback(res, err)
		if (res) then
			complain(ply, "sm_banip: " .. name .. " has been IP banned successfully.")
		else
			complain(ply, "sm_banip: " .. name .. " has not been IP banned. " .. err);
		end
	end
	doBan('', id, name, time * 60, reason, ply, callback)
	complain(ply, "sm_banip: Your ban request has been sent to the database.");
end, nil, "Bans a player by only their IP" .. usage);

local usage = "\n - Usage: sm_addban <minutes|0> <steamid> <reason>";
concommand.Add("sm_addban", function(ply, _, args)
	if (#args < 3) then
		return complain(ply, usage:sub(4));
	elseif (not checkConnection()) then
		return complain(ply, "The database is not active at the moment. Your command could not be completed.");
	elseif (not authorised(ply, FLAG_ADDBAN)) then
		return complain(ply, "You do not have access to this command!");
	end
	local time, id, reason = tonumber(table.remove(args,1)), getSteamID(args), table.concat(args, " "):Trim();
	if (not id) then
		return complain(ply, "Invalid SteamID!" .. usage);
	elseif (not time or time < 0) then
		return complain(ply, "Invalid time!" .. usage);
	elseif (reason == "") then
		return complain(ply, "Invalid reason!" .. usage);
	elseif (time == 0 and not authorised(ply, FLAG_PERMA)) then
		return complain(ply, "You are not authorised to permaban!");
	end
	local function callback(res, err)
		if (res) then
			complain(ply, "sm_addban: " .. id .. " has been banned successfully.")
		else
			complain(ply, "sm_addban: " .. id .. " has not been banned. " .. err);
		end
	end
	BanPlayerBySteamID(id, time * 60, reason, ply, '', callback);
	complain(ply, "sm_addban: Your ban request has been sent to the database.");
end, nil, "Bans a player by their SteamID" .. usage);

local usage = "\n - Usage: sm_unban <steamid|ip> <reason>";
concommand.Add("sm_unban", function(ply, _, args)
	if (#args < 2) then
		return complain(ply, usage:sub(4));
	elseif (not checkConnection()) then
		return complain(ply, "The database is not active at the moment. Your command could not be completed.");
	elseif (not authorised(ply, FLAG_UNBAN)) then
		return complain(ply, "You do not have access to this command!");
	end
	local id, reason, func;
	if (string.find(args[1], "%d+%.%d+%.%d+%.%d+")) then
		id = table.remove(args,1);
		func = UnbanPlayerByIPAddress;
	else
		id = getSteamID(args);
		func = UnbanPlayerBySteamID;
	end
	if (not id) then
		return complain(ply, "Invalid SteamID!" .. usage);
	end
	reason = table.concat(args, " "):Trim()
	if (reason == "") then
		return complain(ply, "Invalid reason!" .. usage);
	end
	func(id, reason, ply);
	complain(ply, "Your unban request has been sent to the database.");
end, nil, "Unbans a player" .. usage);