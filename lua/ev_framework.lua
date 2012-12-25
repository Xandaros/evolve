/*-------------------------------------------------------------------------------------------------------------------------
	Framework providing the main Evolve functions
-------------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------------
	Comfortable constants
-------------------------------------------------------------------------------------------------------------------------*/

evolve.constants = {}
evolve.colors = {}
evolve.ranks = {}
evolve.privileges = {}
evolve.bans = {}
evolve.constants.notallowed = "You are not allowed to do that."
evolve.constants.noplayers = "No matching players with an equal or lower immunity found."
evolve.constants.noplayers2 = "No matching players with a lower immunity found."
evolve.constants.noplayersnoimmunity = "No matching players found."
evolve.admins = 1
evolve.colors.blue = Color( 98, 176, 255, 255 )
evolve.colors.red = Color( 255, 62, 62, 255 )
evolve.colors.white = color_white
evolve.category = {}
evolve.category.administration = 1
evolve.category.actions = 2
evolve.category.punishment = 3
evolve.category.teleportation = 4
evolve.plugins = {}
evolve.version = 179

/*-------------------------------------------------------------------------------------------------------------------------
	Messages and notifications
-------------------------------------------------------------------------------------------------------------------------*/

function evolve:Message( msg )
	print( "[EV] " .. msg )
end

if ( SERVER ) then
	evolve.SilentNotify = false
	
	function evolve:Notify( ... )
		local ply
		local arg = { ... }
		
		if ( type( arg[1] ) == "Player" or arg[1] == NULL ) then ply = arg[1] end
		if ( arg[1] == evolve.admins ) then
			for _, pl in ipairs( player.GetAll() ) do
				if ( pl:IsAdmin() ) then
					table.remove( arg, 1 )
					evolve:Notify( pl, unpack( arg ) )
				end
			end
			return
		end
		
		if ( ply != NULL and !self.SilentNotify ) then
			umsg.Start( "EV_Notification", ply )
				umsg.Short( #arg )
				for _, v in ipairs( arg ) do
					if ( type( v ) == "string" ) then
						umsg.String( v )
					elseif ( type ( v ) == "table" ) then
						umsg.Short( v.r )
						umsg.Short( v.g )
						umsg.Short( v.b )
						umsg.Short( v.a )
					end
				end
			umsg.End()
		end
		
		local str = ""
		for _, v in ipairs( arg ) do
			if ( type( v ) == "string" ) then str = str .. v end
		end
		
		if ( ply ) then
			print( "[EV] " .. ply:Nick() .. " -> " .. str )
			evolve:Log( evolve:PlayerLogStr( ply ) .. " -> " .. str )
		else
			print( "[EV] " .. str )
			evolve:Log( str )
		end
	end
else
	function evolve:Notify( ... )
		local arg = { ... }
		
		args = {}
		for _, v in ipairs( arg ) do
			if ( type( v ) == "string" or type( v ) == "table" ) then table.insert( args, v ) end
		end
		
		chat.AddText( unpack( args ) )
	end
	
	usermessage.Hook( "EV_Notification", function( um )
		local argc = um:ReadShort()
		local args = {}
		for i = 1, argc / 2, 1 do
			table.insert( args, Color( um:ReadShort(), um:ReadShort(), um:ReadShort(), um:ReadShort() ) )
			table.insert( args, um:ReadString() )
		end
		
		chat.AddText( unpack( args ) )
	end )
end

/*-------------------------------------------------------------------------------------------------------------------------
	Utility functions
-------------------------------------------------------------------------------------------------------------------------*/

function evolve:BoolToInt( bool )
	if ( bool ) then return 1 else return 0 end
end

function evolve:KeyByValue( tbl, value, iterator )
	iterator = iterator or pairs
	for k, v in iterator( tbl ) do
		if ( value == v ) then return k end
	end
end

function evolve:FormatTime( t )
	if ( t < 0 ) then
		return "Forever"
	elseif ( t < 60 ) then
		if ( t == 1 ) then return "one second" else return t .. " seconds" end
	elseif ( t < 3600 ) then
		if ( math.ceil( t / 60 ) == 1 ) then return "one minute" else return math.ceil( t / 60 ) .. " minutes" end
	elseif ( t < 24 * 3600 ) then
		if ( math.ceil( t / 3600 ) == 1 ) then return "one hour" else return math.ceil( t / 3600 ) .. " hours" end
	elseif ( t < 24 * 3600 * 7 ) then
		if ( math.ceil( t / ( 24 * 3600 ) ) == 1 ) then return "one day" else return math.ceil( t / ( 24 * 3600 ) ) .. " days" end
	elseif ( t < 24 * 3600 * 30 ) then
		if ( math.ceil( t / ( 24 * 3600 * 7 ) ) == 1 ) then return "one week" else return math.ceil( t / ( 24 * 3600 * 7 ) ) .. " weeks" end
	else
		if ( math.ceil( t / ( 24 * 3600 * 30 ) ) == 1 ) then return "one month" else return math.ceil( t / ( 24 * 3600 * 30 ) )  .. " months" end
	end
end

/*-------------------------------------------------------------------------------------------------------------------------
	Plugin management
-------------------------------------------------------------------------------------------------------------------------*/

local pluginFile

function evolve:LoadPlugins()	
	evolve.plugins = {}
	
	local plugins = file.FindInLua( "ev_plugins/*.lua" )
	for _, plugin in ipairs( plugins ) do
		local prefix = string.Left( plugin, string.find( plugin, "_" ) - 1 )
		pluginFile = plugin
		
		if ( CLIENT and ( prefix == "sh" or prefix == "cl" ) ) then
			include( "ev_plugins/" .. plugin )
		elseif ( SERVER ) then
			include( "ev_plugins/" .. plugin )
			if ( prefix == "sh" or prefix == "cl" ) then AddCSLuaFile( "ev_plugins/" .. plugin ) end
		end
	end
end

function evolve:RegisterPlugin( plugin )
	if ( string.Left( pluginFile, string.find( pluginFile, "_" ) - 1 ) != "cl" or CLIENT ) then
		table.insert( evolve.plugins, plugin )
		plugin.File = pluginFile
		if ( plugin.Privileges and SERVER ) then table.Add( evolve.privileges, plugin.Privileges ) table.sort( evolve.privileges ) end
	else
		table.insert( evolve.plugins, { Title = plugin.Title, File = pluginFile } )
	end
end

function evolve:FindPlugin( name )
	for _, plugin in ipairs( evolve.plugins ) do
		if ( plugin.Title == name ) then return plugin end
	end
end

if ( !evolve.HookCall ) then evolve.HookCall = hook.Call end
hook.Call = function( name, gm, ... )
	local arg = { ... }
	
	for _, plugin in ipairs( evolve.plugins ) do
		if ( plugin[ name ] ) then			
			local retValues = { pcall( plugin[name], plugin, ... ) }
			
			if ( retValues[1] and retValues[2] != nil ) then
				table.remove( retValues, 1 )
				return unpack( retValues )
			elseif ( !retValues[1] ) then
				evolve:Notify( evolve.colors.red, "Hook '" .. name .. "' in plugin '" .. plugin.Title .. "' failed with error:" )
				evolve:Notify( evolve.colors.red, retValues[2] )
			end
		end
	end
	
	if ( CLIENT ) then
		for _, tab in ipairs( evolve.MENU.Tabs ) do
			if ( tab[ name ] ) then			
				local retValues = { pcall( tab[name], tab, ... ) }
				
				if ( retValues[1] and retValues[2] != nil ) then
					table.remove( retValues, 1 )
					return unpack( retValues )
				elseif ( !retValues[1] ) then
					evolve:Notify( evolve.colors.red, "Hook '" .. name .. "' in tab '" .. tab.Title .. "' failed with error:" )
					evolve:Notify( evolve.colors.red, retValues[2] )
				end
			end
		end
	end
	
	return evolve.HookCall( name, gm, ... )
end

if ( SERVER ) then
	concommand.Add( "ev_reloadplugin", function( ply, com, args )
		if ( !ply:IsValid() and args[1] ) then
			local found
			
			for k, plugin in ipairs( evolve.plugins ) do
				if ( string.lower( plugin.Title ) == string.lower( args[1] ) ) then
					found = k
					break
				end
			end
			
			if ( found ) then
				print( "[EV] Reloading plugin " .. evolve.plugins[found].Title .. "..." )
				
				local plugin = evolve.plugins[found].File
				local title = evolve.plugins[found].Title
				local prefix = string.Left( plugin, string.find( plugin, "_" ) - 1 )
				
				if ( prefix != "cl" ) then table.remove( evolve.plugins, found ) pluginFile = plugin include( "ev_plugins/" .. plugin ) end
				
				if ( prefix == "sh" or prefix == "cl" ) then
					datastream.StreamToClients( player.GetAll(), "EV_PluginFile", { Title = title, Contents = file.Read( "../lua/ev_plugins/" .. plugin ) } )
				end
			else
				print( "[EV] Plugin '" .. tostring( args[1] ) .. "' not found!" )
			end
		end
	end )
else
	datastream.Hook( "EV_PluginFile", function( handler, id, encoded, decoded )
		for k, plugin in ipairs( evolve.plugins ) do
			if ( string.lower( plugin.Title ) == string.lower( decoded.Title ) ) then
				found = k
				table.remove( evolve.plugins, k )
			end
		end
		
		RunString( decoded.Contents )
	end )
end

/*-------------------------------------------------------------------------------------------------------------------------
	Player collections
-------------------------------------------------------------------------------------------------------------------------*/

function evolve:IsNameMatch( ply, str )
	if ( str == "*" ) then
		return true
	elseif ( str == "@" and ply:IsAdmin() ) then
		return true
	elseif ( str == "!@" and !ply:IsAdmin() ) then
		return true
	elseif ( string.match( str, "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
		return ply:SteamID() == str
	elseif ( string.Left( str, 1 ) == "\"" and string.Right( str, 1 ) == "\"" ) then
		return ( ply:Nick() == string.sub( str, 2, #str - 1 ) )
	else
		return ( string.lower( ply:Nick() ) == string.lower( str ) or string.find( string.lower( ply:Nick() ), string.lower( str ), nil, true ) )
	end
end

function evolve:FindPlayer( name, def, nonum, noimmunity )
	local matches = {}
	
	if ( !name or #name == 0 ) then
		matches[1] = def
	else
		if ( type( name ) != "table" ) then name = { name } end
		local name2 = table.Copy( name )
		if ( nonum ) then
			if ( #name2 > 1 and tonumber( name2[ #name2 ] ) ) then table.remove( name2, #name2 ) end
		end
		
		for _, ply in ipairs( player.GetAll() ) do
			for _, pm in ipairs( name2 ) do
				if ( evolve:IsNameMatch( ply, pm ) and !table.HasValue( matches, ply ) and ( noimmunity or !def or def:EV_BetterThanOrEqual( ply ) ) ) then table.insert( matches, ply ) end
			end
		end
	end
	
	return matches
end

function evolve:CreatePlayerList( tbl, notall )
	local lst = ""
	local lword = "and"
	if ( notall ) then lword = "or" end
	
	if ( #tbl == 1 ) then
		lst = tbl[1]:Nick()
	elseif ( #tbl == #player.GetAll() ) then
		lst = "everyone"
	else
		for i = 1, #tbl do
			if ( i == #tbl ) then lst = lst .. " " .. lword .. " " .. tbl[i]:Nick() elseif ( i == 1 ) then lst = tbl[i]:Nick() else lst = lst .. ", " .. tbl[i]:Nick() end
		end
	end
	
	return lst
end

/*-------------------------------------------------------------------------------------------------------------------------
	Ranks
-------------------------------------------------------------------------------------------------------------------------*/

function _R.Player:EV_IsRespected()
	return self:EV_GetRank() == "respected" or self:EV_IsAdmin()
end

function _R.Player:EV_IsAdmin()
	return self:EV_GetRank() == "admin" or self:IsAdmin() or self:EV_IsSuperAdmin()
end

function _R.Player:EV_IsSuperAdmin()
	return self:EV_GetRank() == "superadmin" or self:IsSuperAdmin() or self:EV_IsOwner()
end

function _R.Player:EV_IsOwner()
	if ( SERVER ) then
		return self:EV_GetRank() == "owner" or self:IsListenServerHost()
	else
		return self:EV_GetRank() == "owner"
	end
end

function _R.Player:EV_IsRank( rank )
	return self:EV_GetRank() == rank
end

/*-------------------------------------------------------------------------------------------------------------------------
	Console
-------------------------------------------------------------------------------------------------------------------------*/

function _R.Entity:Nick() if ( !self:IsValid() ) then return "Console" end end
function _R.Entity:EV_IsRespected() if ( !self:IsValid() ) then return true end end
function _R.Entity:EV_IsAdmin() if ( !self:IsValid() ) then return true end end
function _R.Entity:EV_IsSuperAdmin() if ( !self:IsValid() ) then return true end end
function _R.Entity:EV_IsOwner() if ( !self:IsValid() ) then return true end end
function _R.Entity:EV_GetRank() if ( !self:IsValid() ) then return "owner" end end
function _R.Entity:UniqueID() if ( !self:IsValid() ) then return 0 end end

/*-------------------------------------------------------------------------------------------------------------------------
	Player information
-------------------------------------------------------------------------------------------------------------------------*/

function evolve:LoadPlayerInfo()
	if ( file.Exists( "ev_playerinfo.txt" ) ) then
		debug.sethook()
		self.PlayerInfo = glon.decode( file.Read( "ev_playerinfo.txt" ) )
	else
		self.PlayerInfo = {}
	end
end
evolve:LoadPlayerInfo()

function evolve:SavePlayerInfo()
	file.Write( "ev_playerinfo.txt", glon.encode( self.PlayerInfo ) )
end

function _R.Player:GetProperty( id, defaultvalue )	
	if ( evolve.PlayerInfo[ self:UniqueID() ] ) then
		return evolve.PlayerInfo[ self:UniqueID() ][ id ] or defaultvalue
	else
		return defaultvalue
	end
end

function _R.Player:SetProperty( id, value )
	if ( !evolve.PlayerInfo[ self:UniqueID() ] ) then evolve.PlayerInfo[ self:UniqueID() ] = {} end
	
	evolve.PlayerInfo[ self:UniqueID() ][ id ] = value
end

function evolve:UniqueIDByProperty( property, value, exact )	
	for k, v in pairs( evolve.PlayerInfo ) do
		if ( v[ property ] == value ) then
			return k
		elseif ( !exact and string.find( string.lower( v[ property ] or "" ), string.lower( value ) ) ) then
			return k
		end
	end
end

function evolve:GetProperty( uniqueid, id, defaultvalue )
	uniqueid = tostring( uniqueid )
	
	if ( evolve.PlayerInfo[ uniqueid ] ) then
		return evolve.PlayerInfo[ uniqueid ][ id ] or defaultvalue
	else
		return defaultvalue
	end
end

function evolve:SetProperty( uniqueid, id, value )
	uniqueid = tostring( uniqueid )
	if ( !evolve.PlayerInfo[ uniqueid ] ) then evolve.PlayerInfo[ uniqueid ] = {} end
	
	evolve.PlayerInfo[ uniqueid ][ id ] = value
end

function evolve:CommitProperties()
	/*-------------------------------------------------------------------------------------------------------------------------
		Check if a cleanup would be convenient
	-------------------------------------------------------------------------------------------------------------------------*/
	
	local count = table.Count( evolve.PlayerInfo )
	
	if ( count > 800 ) then
		local original = count
		local info = {}
		for uid, entry in pairs( evolve.PlayerInfo ) do
			table.insert( info, { UID = uid, LastJoin = entry.LastJoin, Rank = entry.Rank } )
		end
		table.SortByMember( info, "LastJoin", function(a, b) return a > b end )
		
		for _, entry in pairs( info ) do
			if ( ( !entry.BanEnd or entry.BanEnd < os.time() ) and ( !entry.Rank or entry.Rank == "guest" ) ) then
				evolve.PlayerInfo[ entry.UID ] = nil
				count = count - 1
				if ( count < 800 ) then break end
			end
		end
		
		evolve:Message( "Cleaned up " .. original - count .. " players." )
	end
	
	evolve:SavePlayerInfo()
end

/*-------------------------------------------------------------------------------------------------------------------------
	Entity ownership
-------------------------------------------------------------------------------------------------------------------------*/

hook.Add( "PlayerSpawnedProp", "EV_SpawnHook", function( ply, model, ent ) ent.EV_Owner = ply:UniqueID() evolve:Log( evolve:PlayerLogStr( ply ) .. " spawned prop '" .. model .. "'." ) end )
hook.Add( "PlayerSpawnedSENT", "EV_SpawnHook", function( ply, ent ) ent.EV_Owner = ply:UniqueID() evolve:Log( evolve:PlayerLogStr( ply ) .. " spawned scripted entity '" .. ent:GetClass() .. "'." ) end )
hook.Add( "PlayerSpawnedNPC", "EV_SpawnHook", function( ply, ent ) ent.EV_Owner = ply:UniqueID() evolve:Log( evolve:PlayerLogStr( ply ) .. " spawned npc '" .. ent:GetClass() .. "'." ) end )
hook.Add( "PlayerSpawnedVehicle", "EV_SpawnHook", function( ply, ent ) ent.EV_Owner = ply:UniqueID() evolve:Log( evolve:PlayerLogStr( ply ) .. " spawned vehicle '" .. ent:GetClass() .. "'." ) end )
hook.Add( "PlayerSpawnedEffect", "EV_SpawnHook", function( ply, model, ent ) ent.EV_Owner = ply:UniqueID() evolve:Log( evolve:PlayerLogStr( ply ) .. " spawned effect '" .. model .. "'." ) end )
hook.Add( "PlayerSpawnedRagdoll", "EV_SpawnHook", function( ply, model, ent ) ent.EV_Owner = ply:UniqueID() evolve:Log( evolve:PlayerLogStr( ply ) .. " spawned ragdoll '" .. model .. "'." ) end )

evolve.AddCount = _R.Player.AddCount
function _R.Player:AddCount( type, ent )
	ent.EV_Owner = self:UniqueID()
	return evolve.AddCount( self, type, ent )
end

evolve.CleanupAdd = cleanup.Add
function cleanup.Add( ply, type, ent )
	if ( ent ) then ent.EV_Owner = ply:UniqueID() end
	return evolve.CleanupAdd( ply, type, ent )
end

function _R.Entity:EV_GetOwner()
	return self.EV_Owner
end

/*-------------------------------------------------------------------------------------------------------------------------
	Ranks
-------------------------------------------------------------------------------------------------------------------------*/

// COMPATIBILITY
evolve.compatibilityRanks = glon.decode( file.Read( "ev_ranks.txt" ) )
// COMPATIBILITY

function _R.Player:EV_HasPrivilege( priv )
	if ( evolve.ranks[ self:EV_GetRank() ] ) then
		return self:EV_GetRank() == "owner" or table.HasValue( evolve.ranks[ self:EV_GetRank() ].Privileges, priv )
	else
		return false
	end
end

function _R.Entity:EV_BetterThan( ply )
	return true
end

function _R.Entity:EV_BetterThanOrEqual( ply )
	return true
end

function _R.Player:EV_BetterThan( ply )
	return tonumber( evolve.ranks[ self:EV_GetRank() ].Immunity ) > tonumber( evolve.ranks[ ply:EV_GetRank() ].Immunity ) or self == ply
end

function _R.Player:EV_BetterThanOrEqual( ply )
	return tonumber( evolve.ranks[ self:EV_GetRank() ].Immunity ) >= tonumber( evolve.ranks[ ply:EV_GetRank() ].Immunity )
end

function _R.Entity:EV_HasPrivilege( priv )
	if ( self == NULL ) then return true end
end

function _R.Entity:EV_BetterThan( ply )
	if ( self == NULL ) then return true end
end

function _R.Player:EV_SetRank( rank )
	self:SetProperty( "Rank", rank )
	evolve:CommitProperties()
	
	self:SetNWString( "EV_UserGroup", rank )
	
	evolve:RankGroup( self, rank )
	
	if ( self:EV_HasPrivilege( "Ban menu" ) ) then
		evolve:SyncBans( self )
	end
end

function _R.Player:EV_GetRank()
	if ( !self:IsValid() ) then return false end
	if ( SERVER and self:IsListenServerHost() ) then return "owner" end
	
	local rank
	
	if ( SERVER ) then
		rank = self:GetProperty( "Rank", "guest" )
	else
		rank = self:GetNWString( "EV_UserGroup", "guest" )
	end
	
	if ( evolve.ranks[ rank ] ) then
		return rank
	else
		return "guest"
	end
end

function _R.Player:IsUserGroup( group )
	if ( !self:IsValid() ) then return false end
	return self:GetNWString( "UserGroup" ) == group or self:EV_GetRank() == group
end

function evolve:RankGroup( ply, rank )
	ply:SetUserGroup( evolve.ranks[ rank ].UserGroup )
end

function evolve:Rank( ply )
	if ( !ply:IsValid() ) then return end
	
	self:TransferPrivileges( ply )
	self:TransferRanks( ply )
	
	if ( ply:IsListenServerHost() ) then ply:SetNWString( "EV_UserGroup", "owner" ) ply:SetNWString( "UserGroup", "superadmin" ) return end
	
	local usergroup = ply:GetNWString( "UserGroup", "guest" )
	if ( usergroup == "user" ) then usergroup = "guest" end
	ply:SetNWString( "EV_UserGroup", usergroup )
	
	local rank = ply:GetProperty( "Rank" )
	if ( rank and evolve.ranks[ rank ] ) then
		ply:SetNWString( "EV_UserGroup", rank )
		usergroup = rank
	else
		// COMPATIBILITY
		if ( evolve.compatibilityRanks ) then
			for _, ranks in ipairs( evolve.compatibilityRanks ) do
				if ( ranks.steamID == ply:SteamID() ) then
					rank = ranks.rank
					
					ply:SetNWString( "EV_UserGroup", rank )
					usergroup = rank
					
					ply:SetProperty( "Rank", rank )
					evolve:CommitProperties()
					
					break
				end
			end
		end
		// COMPATIBILITY
	end
	
	if ( ply:EV_HasPrivilege( "Ban menu" ) ) then
		evolve:SyncBans( ply )
	end
	
	evolve:RankGroup( ply, usergroup )
end

hook.Add( "PlayerSpawn", "EV_RankHook", function( ply )
	if ( !ply.EV_Ranked ) then
		ply:SetNWString( "EV_UserGroup", ply:GetProperty( "Rank", "guest" ) )
		
		timer.Simple( 1, function()
			evolve:Rank( ply )
		end )
		ply.EV_Ranked = true
		
		ply:SetNWInt( "EV_JoinTime", os.time() )
		ply:SetNWInt( "EV_PlayTime", ply:GetProperty( "PlayTime" ) or 0 )
		SendUserMessage( "EV_TimeSync", ply, os.time() )
	end
end )

/*-------------------------------------------------------------------------------------------------------------------------
	Time synchronisation
-------------------------------------------------------------------------------------------------------------------------*/

usermessage.Hook( "EV_TimeSync", function( um )
	evolve.timeoffset = um:ReadLong() - os.time()
end )

function evolve:Time()
	if ( CLIENT ) then
		return os.time() + ( evolve.timeoffset or 0 )
	else
		return os.time()
	end
end

/*-------------------------------------------------------------------------------------------------------------------------
	Rank management
-------------------------------------------------------------------------------------------------------------------------*/

function evolve:SaveRanks()
	file.Write( "ev_userranks.txt", glon.encode( evolve.ranks ) )
end

function evolve:LoadRanks()
	if ( file.Exists( "ev_userranks.txt" ) ) then
		evolve.ranks = glon.decode( file.Read( "ev_userranks.txt" ) )
	else
		include( "ev_defaultranks.lua" )
		evolve:SaveRanks()
	end
end

if ( SERVER ) then evolve:LoadRanks() end

function evolve:SyncRanks()
	for _, pl in ipairs( player.GetAll() ) do evolve:TransferRanks( pl ) end
end

function evolve:TransferPrivileges( ply )
	if ( !ply:IsValid() ) then return end
	
	for id, privilege in ipairs( evolve.privileges ) do
		umsg.Start( "EV_Privilege", ply )
			umsg.Short( id )
			umsg.String( privilege )
		umsg.End()
	end
end

function evolve:TransferRank( ply, rank )
	if ( !ply:IsValid() ) then return end
	
	local data = evolve.ranks[ rank ]
	local color = data.Color
	
	umsg.Start( "EV_Rank", ply )			
		umsg.String( rank )
		umsg.String( data.Title )
		umsg.String( data.Icon )
		umsg.String( data.UserGroup )
		umsg.Short( data.Immunity )
		
		if ( color ) then
			umsg.Bool( true )
			umsg.Short( color.r )
			umsg.Short( color.g )
			umsg.Short( color.b )
		else
			umsg.Bool( false )
		end
	umsg.End()
	
	local privs = #( data.Privileges or {} )
	local count
	
	for i = 1, privs, 100 do
		count = math.min( privs, i + 99 ) - i
		
		umsg.Start( "EV_RankPrivileges", ply )
			umsg.String( rank )
			umsg.Short( count + 1 )
			
			for ii = i, i + count do
				umsg.Short( evolve:KeyByValue( evolve.privileges, data.Privileges[ii], ipairs ) )
			end
		umsg.End()
	end
end

function evolve:TransferRanks( ply )
	for id, data in pairs( evolve.ranks ) do
		evolve:TransferRank( ply, id )
	end
end

usermessage.Hook( "EV_Rank", function( um )
	local id = string.lower( um:ReadString() )
	local title = um:ReadString()
	local created = evolve.ranks[id] == nil
	
	evolve.ranks[id] = {
		Title = title,
		Icon = um:ReadString(),
		UserGroup = um:ReadString(),
		Immunity = um:ReadShort(),
		Privileges = {},
	}
	
	if ( um:ReadBool() ) then
		evolve.ranks[id].Color = Color( um:ReadShort(), um:ReadShort(), um:ReadShort() )
	end
	
	evolve.ranks[id].IconTexture = surface.GetTextureID( "gui/silkicons/" .. evolve.ranks[id].Icon )
	
	if ( created ) then
		hook.Call( "EV_RankCreated", nil, id )
	else
		hook.Call( "EV_RankUpdated", nil, id )
	end
end )

usermessage.Hook( "EV_Privilege", function( um )
	local id = um:ReadShort()
	local name = um:ReadString()
	
	evolve.privileges[ id ] = name
end )

usermessage.Hook( "EV_RankPrivileges", function( um )
	local rank = um:ReadString()
	local privilegeCount = um:ReadShort()
	
	for i = 1, privilegeCount do
		table.insert( evolve.ranks[ rank ].Privileges, evolve.privileges[ um:ReadShort() ] )
	end
end )

usermessage.Hook( "EV_RemoveRank", function( um )
	local rank = um:ReadString()
	hook.Call( "EV_RankRemoved", nil, rank )
	evolve.ranks[ rank ] = nil
end )

usermessage.Hook( "EV_RenameRank", function( um )
	local rank = um:ReadString():lower()
	evolve.ranks[ rank ].Title = um:ReadString()
	
	hook.Call( "EV_RankRenamed", nil, rank, evolve.ranks[ rank ].Title )
end )

usermessage.Hook( "EV_RankPrivilege", function( um )
	local rank = um:ReadString()
	local priv = evolve.privileges[ um:ReadShort() ]
	local enabled = um:ReadBool()
	
	if ( enabled ) then
		table.insert( evolve.ranks[ rank ].Privileges, priv )
	else
		table.remove( evolve.ranks[ rank ].Privileges, evolve:KeyByValue( evolve.ranks[ rank ].Privileges, priv ) )
	end
	
	hook.Call( "EV_RankPrivilegeChange", nil, rank, priv, enabled )
end )

usermessage.Hook( "EV_RankPrivilegeAll", function( um )
	local rank = um:ReadString()
	local enabled = um:ReadBool()
	local filter = um:ReadString()
	
	if ( enabled ) then
		for _, priv in ipairs( evolve.privileges ) do
			if ( ( ( #filter == 0 and !string.match( priv, "[@:#]" ) ) or string.Left( priv, 1 ) == filter ) and !table.HasValue( evolve.ranks[rank].Privileges, priv ) ) then				
				hook.Call( "EV_RankPrivilegeChange", nil, rank, priv, true )
				table.insert( evolve.ranks[ rank ].Privileges, priv )
			end
		end
	else
		local i = 1
		
		while ( i <= #evolve.ranks[rank].Privileges ) do
			if ( ( #filter == 0 and !string.match( evolve.ranks[rank].Privileges[i], "[@:#]" ) ) or string.Left( evolve.ranks[rank].Privileges[i], 1 ) == filter ) then
				hook.Call( "EV_RankPrivilegeChange", nil, rank, evolve.ranks[rank].Privileges[i], false )
				table.remove( evolve.ranks[rank].Privileges, i )
			else
				i = i + 1
			end
		end
	end
end )

/*-------------------------------------------------------------------------------------------------------------------------
	Rank modification
-------------------------------------------------------------------------------------------------------------------------*/

if ( SERVER ) then
	concommand.Add( "ev_renamerank", function( ply, com, args )
		if ( ply:EV_HasPrivilege( "Rank modification" ) ) then
			if ( #args > 1 and evolve.ranks[ args[1] ] ) then
				evolve:Notify( evolve.colors.red, ply:Nick(), evolve.colors.white, " has renamed ", evolve.colors.blue, evolve.ranks[ args[1] ].Title, evolve.colors.white, " to ", evolve.colors.blue, table.concat( args, " ", 2 ), evolve.colors.white, "." )
				
				evolve.ranks[ args[1] ].Title = table.concat( args, " ", 2 )
				evolve:SaveRanks()
				
				umsg.Start( "EV_RenameRank" )
					umsg.String( args[1] )
					umsg.String( evolve.ranks[ args[1] ].Title )
				umsg.End()
			end
		end
	end )
	
	concommand.Add( "ev_setrank", function( ply, com, args )
		if ( ply:EV_HasPrivilege( "Rank modification" ) ) then
			if ( #args == 3 and args[1] != "owner" and evolve.ranks[ args[1] ] and table.HasValue( evolve.privileges, args[2] ) and tonumber( args[3] ) ) then
				local rank = args[1]
				local privilege = args[2]
				
				if ( tonumber( args[3] ) == 1 ) then
					if ( !table.HasValue( evolve.ranks[ rank ].Privileges, privilege ) ) then
						table.insert( evolve.ranks[ rank ].Privileges, privilege )
					end
				else
					if ( table.HasValue( evolve.ranks[ rank ].Privileges, privilege ) ) then
						table.remove( evolve.ranks[ rank ].Privileges, evolve:KeyByValue( evolve.ranks[ rank ].Privileges, privilege ) )
					end
				end
				
				evolve:SaveRanks()
				
				umsg.Start( "EV_RankPrivilege" )
					umsg.String( rank )
					umsg.Short( evolve:KeyByValue( evolve.privileges, privilege ) )
					umsg.Bool( tonumber( args[3] ) == 1 )
				umsg.End()
			elseif ( #args >= 2 and evolve.ranks[ args[1] ] and tonumber( args[2] ) and ( !args[3] or #args[3] == 1 ) ) then
				local rank = args[1]
				
				if ( tonumber( args[2] ) == 1 ) then					
					for _, priv in ipairs( evolve.privileges ) do
						if ( ( ( !args[3] and !string.match( priv, "[@:#]" ) ) or string.Left( priv, 1 ) == args[3] ) and !table.HasValue( evolve.ranks[ rank ].Privileges, priv ) ) then
							table.insert( evolve.ranks[ rank ].Privileges, priv )
						end
					end
				else
					local i = 1
					
					while ( i <= #evolve.ranks[rank].Privileges ) do
						if ( ( !args[3] and !string.match( evolve.ranks[rank].Privileges[i], "[@:#]" ) ) or string.Left( evolve.ranks[rank].Privileges[i], 1 ) == args[3] ) then
							table.remove( evolve.ranks[rank].Privileges, i )
						else
							i = i + 1
						end
					end
				end
				
				evolve:SaveRanks()
				
				umsg.Start( "EV_RankPrivilegeAll" )
					umsg.String( rank )
					umsg.Bool( tonumber( args[2] ) == 1 )
					umsg.String( args[3] or "" )
				umsg.End()
			end
		end
	end )
	
	concommand.Add( "ev_setrankp", function( ply, com, args )
		if ( ply:EV_HasPrivilege( "Rank modification" ) ) then
			if ( #args == 6 and tonumber( args[2] ) and evolve.ranks[ args[1] ] and ( args[3] == "guest" or args[3] == "admin" or args[3] == "superadmin" ) and tonumber( args[4] ) and tonumber( args[5] ) and tonumber( args[6] ) ) then						
				if ( args[1] != "owner" ) then
					evolve.ranks[ args[1] ].Immunity = tonumber( args[2] )
					evolve.ranks[ args[1] ].UserGroup = args[3]
				end
				
				evolve.ranks[ args[1] ].Color = Color( args[4], args[5], args[6] )
				evolve:SaveRanks()
				
				for _, pl in ipairs( player.GetAll() ) do
						evolve:TransferRank( pl, args[1] )
						
						if ( args[1] != "owner" and pl:EV_GetRank() == args[1] ) then
							pl:SetNWString( "UserGroup", args[3] )
						end
					end
			end
		end
	end )
	
	concommand.Add( "ev_removerank", function( ply, com, args )
		if ( ply:EV_HasPrivilege( "Rank modification" ) ) then
			if ( args[1] != "guest" and args[1] != "owner" and evolve.ranks[ args[1] ] ) then
				evolve:Notify( evolve.colors.red, ply:Nick(), evolve.colors.white, " has removed the rank ", evolve.colors.blue, evolve.ranks[ args[1] ].Title, evolve.colors.white, "." )
				
				evolve.ranks[ args[1] ] = nil
				evolve:SaveRanks()
				
				for _, pl in ipairs( player.GetAll() ) do
					if ( pl:EV_GetRank() == args[1] ) then
						pl:EV_SetRank( "guest" )
					end
				end
				
				umsg.Start( "EV_RemoveRank" )
					umsg.String( args[1] )
				umsg.End()
			end
		end
	end )
	
	concommand.Add( "ev_createrank", function( ply, com, args )
		if ( ply:EV_HasPrivilege( "Rank modification" ) ) then
			if ( ( #args == 2 or #args == 3 ) and !string.find( args[1], " " ) and string.lower( args[1] ) == args[1] and !evolve.ranks[ args[1] ] ) then
				if ( #args == 2 ) then
					evolve.ranks[ args[1] ] = {
						Title = args[2],
						Icon = "user",
						UserGroup = "guest",
						Immunity = 0,
						Privileges = {},
					}
				elseif ( #args == 3 and evolve.ranks[ args[3] ] ) then
					local parent = evolve.ranks[ args[3] ]
					
					evolve.ranks[ args[1] ] = {
						Title = args[2],
						Icon = parent.Icon,
						UserGroup = parent.UserGroup,
						Immunity = tonumber( parent.Immunity ),
						Privileges = table.Copy( parent.Privileges ),
					}
				end
				
				evolve:SaveRanks()
				evolve:SyncRanks()
				
				evolve:Notify( evolve.colors.red, ply:Nick(), evolve.colors.white, " has created the rank ", evolve.colors.blue, args[2], evolve.colors.white, "." )
			end
		end
	end )
end

/*-------------------------------------------------------------------------------------------------------------------------
	Banning
-------------------------------------------------------------------------------------------------------------------------*/

if ( SERVER ) then
	function evolve:SyncBans( ply )
		for uniqueid, info in pairs( evolve.PlayerInfo ) do
			if ( info.BanEnd and ( info.BanEnd > os.time() or info.BanEnd == 0 ) ) then
				local time = info.BanEnd - os.time()
				if ( info.BanEnd == 0 ) then time = 0 end
				SendUserMessage( "EV_BanEntry", ply, tostring( uniqueid ), info.Nick, info.SteamID, info.BanReason, evolve:GetProperty( info.BanAdmin, "Nick" ), time )
			end
		end
	end
	
	function evolve:Ban( uid, length, reason, adminuid )		
		if ( length == 0 ) then length = -os.time() end
		
		evolve:SetProperty( uid, "BanEnd", os.time() + length )
		evolve:SetProperty( uid, "BanReason", reason )
		evolve:SetProperty( uid, "BanAdmin", adminuid )
		evolve:CommitProperties()
		
		local a = "Console"
		if ( adminuid != 0 ) then a = player.GetByUniqueID( adminuid ):Nick() end
		SendUserMessage( "EV_BanEntry", nil, uid, evolve:GetProperty( uid, "Nick" ), evolve:GetProperty( uid, "SteamID" ), reason, a, length )
		
		-- Let SourceBans do the kicking or Evolve
		if ( sourcebans ) then
			local admin
			if ( adminuid != 0 ) then admin = player.GetByUniqueID( adminuid ) end
			
			sourcebans.BanPlayerBySteamIDAndIP( evolve:GetProperty( uid, "SteamID" ), evolve:GetProperty( uid, "IPAddress" ) or "", math.max( 0, length ), reason, admin, evolve:GetProperty( uid, "Nick" ) )
		else
			local pl
			if ( uid != 0 ) then pl = player.GetByUniqueID( uid ) end
			
			if ( pl ) then
				game.ConsoleCommand( "banid " .. length / 60 .. " " .. pl:SteamID() .. "\n" )
				
				if ( length < 0 ) then
					pl:Kick( "Permabanned! (" .. reason .. ")" )
				else
					pl:Kick( "Banned for " .. length / 60 .. " minutes! (" .. reason .. ")" )
				end
			else
				game.ConsoleCommand( "addip " .. length / 60 .. " \"" .. string.match( evolve:GetProperty( uid, "IPAddress" ), "(%d+%.%d+%.%d+%.%d+)" ) .. "\"\n" )
			end
		end
	end
	
	function evolve:UnBan( uid, adminuid )		
		evolve:SetProperty( uid, "BanEnd", nil )
		evolve:SetProperty( uid, "BanReason", nil )
		evolve:SetProperty( uid, "BanAdmin", nil )
		evolve:CommitProperties()
		
		SendUserMessage( "EV_RemoveBanEntry", nil, tostring( uid ) )
		
		if ( sourcebans ) then
			local admin
			if ( adminuid != 0 ) then admin = player.GetByUniqueID( adminuid ) end
			
			sourcebans.UnbanPlayerBySteamID( evolve:GetProperty( uid, "SteamID" ), "No reason specified.", admin )
		else
			game.ConsoleCommand( "removeip \"" .. ( evolve:GetProperty( uid, "IPAddress" ) or "" ) .. "\"\n" )
			game.ConsoleCommand( "removeid " .. evolve:GetProperty( uid, "SteamID" ) .. "\n" )
		end
	end
	
	function evolve:IsBanned( uid )
		local banEnd = evolve:GetProperty( uid, "BanEnd" )
		
		if ( banEnd and banEnd > 0 and os.time() > banEnd ) then
			evolve:UnBan( uid )
			return false
		end
		
		return banEnd and ( banEnd > os.time() or banEnd == 0 )
	end
else
	usermessage.Hook( "EV_BanEntry", function( um )
		if ( !evolve.bans ) then evolve.bans = {} end
		
		local id = um:ReadString()
		evolve.bans[id] =  {
			Nick = um:ReadString(),
			SteamID = um:ReadString(),
			Reason = um:ReadString(),
			Admin = um:ReadString()
		}
		
		local time = um:ReadLong()
		if ( time > 0 ) then
			evolve.bans[id].End = time + os.time()
		else
			evolve.bans[id].End = 0
		end
		
		hook.Call( "EV_BanAdded", nil, id )		
	end )
	
	usermessage.Hook( "EV_RemoveBanEntry", function( um )
		if ( !evolve.bans ) then return end
		
		local id = um:ReadString()
		hook.Call( "EV_BanRemoved", nil, id )
		evolve.bans[id] = nil
	end )
end

/*-------------------------------------------------------------------------------------------------------------------------
	Global data system
-------------------------------------------------------------------------------------------------------------------------*/

function evolve:SaveGlobalVars()
	file.Write( "ev_globalvars.txt", glon.encode( evolve.globalvars ) )
end

function evolve:LoadGlobalVars()
	if ( file.Exists( "ev_globalvars.txt" ) ) then
		evolve.globalvars = glon.decode( file.Read( "ev_globalvars.txt" ) )
	else
		evolve.globalvars = {}
		evolve:SaveGlobalVars()
	end
end
evolve:LoadGlobalVars()

function evolve:SetGlobalVar( name, value )
	evolve.globalvars[name] = value
	evolve:SaveGlobalVars()
end

function evolve:GetGlobalVar( name, default )
	return evolve.globalvars[name] or default
end

/*-------------------------------------------------------------------------------------------------------------------------
	Log system
-------------------------------------------------------------------------------------------------------------------------*/

function evolve:Log( str )
	if ( CLIENT ) then return end
	
	local logFile = "ev_logs/" .. os.date( "%d-%m-%Y" ) .. ".txt"
	local files = file.Find( "ev_logs/" .. os.date( "%d-%m-%Y" ) .. "*.txt" )
	table.sort( files )
	if ( #files > 0 ) then logFile = "ev_logs/" .. files[math.max(#files-1,1)] end
	
	local src = file.Read( logFile ) or ""
	if ( #src > 200 * 1024 ) then
		logFile = "ev_logs/" .. os.date( "%d-%m-%Y" ) .. " (" .. #files + 1 .. ").txt"
	end
	
	filex.Append( logFile, "[" .. os.date() .. "] " .. str .. "\n" )
end

function evolve:PlayerLogStr( ply )
	if ( ply:IsValid() ) then
		if ( ply:IsPlayer() ) then
			return ply:Nick() .. " [" .. ply:SteamID() .. "|" .. ply:IPAddress() .. "]"
		else
			return ply:GetClass()
		end
	else
		return "Console"
	end
end

hook.Add( "InitPostEntity", "EV_LogInit", function()
	evolve:Log( "== Started in map '" .. game.GetMap() .. "' and gamemode '" .. GAMEMODE.Name .. "' ==" )
end )

hook.Add( "PlayerDisconnected", "EV_LogDisconnect", function( ply )
	evolve:Log( evolve:PlayerLogStr( ply ) .. " disconnected from the server." )
end )

hook.Add( "PlayerInitialSpawn", "EV_LogSpawn", function( ply )
	evolve:Log( evolve:PlayerLogStr( ply ) .. " spawned for the first time this session." )
end )

hook.Add( "PlayerConnect", "EV_LogConnect", function( name, address )
	evolve:Log( name .. " [" .. address .. "] connected to the server." )
end )

hook.Add( "PlayerDeath", "EV_LogDeath", function( ply, inf, killer )
	if ( ply != killer ) then
		evolve:Log( evolve:PlayerLogStr( ply ) .. " was killed by " .. evolve:PlayerLogStr( killer ) .. "." )
	end
end )

hook.Add( "PlayerSay", "EV_PlayerChat", function( ply, txt )
	evolve:Log( evolve:PlayerLogStr( ply ) .. ": " ..  txt )
end )