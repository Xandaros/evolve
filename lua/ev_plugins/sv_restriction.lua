--[[

	Fixed by MadDog
	May 2012
]]

/*-------------------------------------------------------------------------------------------------------------------------
	Restriction
-------------------------------------------------------------------------------------------------------------------------*/
require ("player_manager")
local PLUGIN = {}
PLUGIN.Title = "Restriction"
PLUGIN.Description = "Restricts weapons."
PLUGIN.Author = "Overv"
ForcePMTest = false
if SERVER then
	util.PrecacheModel( "models/player/kleiner.mdl" )
	function PlayerChangeModel( ply )
		timer.Simple(0.1,function()
			local tmpname = ply:GetModel()
			--print(tmpname)
			local playermodels = player_manager.AllValidModels()
			local name = "WTFBBQ"
			for k,v in pairs(playermodels) do
				if (string.lower(v) == string.lower(tmpname)) then
					name = k
				end
			end
			--print("Player's new model: "..name)
			if ( GAMEMODE.IsSandboxDerived  and table.HasValue( evolve.privileges, "&" .. name ) and !ply:EV_HasPrivilege( "&" .. name ) and string.lower(name) != "kleiner") or (ForcePMTest and !string.find(name,"kleiner")) then
				evolve:Notify( ply, evolve.colors.red, "You can't use this player model!" )
				ply:SetModel("models/player/kleiner.mdl")
				ply:ConCommand("cl_playermodel kleiner")
				if ply:Alive() then
					ply:Kill()
				end
				return
			end
		end)
	end
	hook.Add("PlayerSpawn","EVPMRestrictOnSpawn",PlayerChangeModel)
	hook.Add("PlayerSetModel","EVPMRestrict",PlayerChangeModel)
end
function PLUGIN:PlayerSpawnSWEP( ply, name, tbl )
	if ( ply.EV_Jailed ) then return false end
	local nametest = string.lower(gmod.GetGamemode().Name)
	if (nametest!="trouble in terrorist town") then
		if (ConVarExists("ev_restrict_weapons")) then
			if (GetConVarNumber("ev_restrict_weapons")==0) then
				return true
			end
		end
		if ( GAMEMODE.IsSandboxDerived  and table.HasValue( evolve.privileges, "@" .. name ) and !ply:EV_HasPrivilege( "@" .. name ) )  then
			evolve:Notify( ply, evolve.colors.red, "You are not allowed to spawn this weapon!" )
			return false
		else
			return true
		end
	end
end
function PLUGIN:PlayerGiveSWEP( ply, name, tbl )
	if ( ply.EV_Jailed ) then return false end
	local nametest = string.lower(gmod.GetGamemode().Name)
	if (nametest!="trouble in terrorist town") then
		if (ConVarExists("ev_restrict_weapons")) then
			if (GetConVarNumber("ev_restrict_weapons")==0) then
				return true
			end
		end
		if ( self:PlayerSpawnSWEP( ply, name, tbl ) == false ) then
			return false
		else
			return true
		end
	end
end

function PLUGIN:PlayerSpawnSENT( ply, class )
	if ( ply.EV_Jailed ) then return false end
	local nametest = string.lower(gmod.GetGamemode().Name)
	if (nametest!="trouble in terrorist town") then
		if (ConVarExists("ev_restrict_entities")) then
			if (GetConVarNumber("ev_restrict_entities")==0) then
				return true
			end
		end
		if ( GAMEMODE.IsSandboxDerived and table.HasValue( evolve.privileges, ":" .. class ) and !ply:EV_HasPrivilege( ":" .. class ) ) then
			evolve:Notify( ply, evolve.colors.red, "You are not allowed to spawn this entity!" )
			return false
		else
			return true
		end
	end
end

function PLUGIN:CanTool( ply, tr, class )
	if ( ply.EV_Jailed ) then return false end
	if ( GAMEMODE.IsSandboxDerived and table.HasValue( evolve.privileges, "#" .. class ) and !ply:EV_HasPrivilege( "#" .. class ) ) then
		evolve:Notify( ply, evolve.colors.red, "You are not allowed to use this tool!" )
		return false
	end
end

function PLUGIN:PlayerSpawn( ply )
	// Only block picking up when a player spawns, because we still want to make it possible to use !give and allow admins to drop weapons for players!
	ply.EV_PickupTimeout = CurTime() + 0.5
end

function PLUGIN:PlayerCanPickupWeapon( ply, wep )
	if ( ply.EV_Jailed ) then return false end
	local nametest = string.lower(gmod.GetGamemode().Name)
	if (nametest!="trouble in terrorist town") then
		if (ConVarExists("ev_restrict_weapons")) then
			if (GetConVarNumber("ev_restrict_weapons")==0) then
				return true
			end
		end
		if ( GAMEMODE.IsSandboxDerived and table.HasValue( evolve.privileges, "@" .. wep:GetClass() ) and !ply:EV_HasPrivilege( "@" .. wep:GetClass() ) and ( !ply.EV_PickupTimeout or CurTime() < ply.EV_PickupTimeout ) ) then
			return false
		else
			return true
		end
	end
end

function PLUGIN:Initialize()
	if CLIENT then return end

	evolve:LoadRanks()
	// Weapons
	local weps = {}

	for _, wep in pairs( weapons.GetList() ) do
		table.insert( weps, "@" .. wep.ClassName )
	end

	table.Add( weps, {
		"@weapon_crowbar",
		"@weapon_pistol",
		"@weapon_smg1",
		"@weapon_frag",
		"@weapon_physcannon",
		"@weapon_crossbow",
		"@weapon_shotgun",
		"@weapon_357",
		"@weapon_Rpg",
		"@weapon_ar2",
		"@weapon_physgun",	
		"@weapon_annabelle",
		"@weapon_slam",
		"@weapon_stunstick",
	} )

	table.Add( evolve.privileges, weps )
	local playermodels = {}
	for k,v in pairs(player_manager.AllValidModels()) do
		table.insert(playermodels,  "&" .. tostring(k))
	end
	table.Add( evolve.privileges, playermodels )
	// Entities
	local entities = {}

	for class, ent in pairs( scripted_ents.GetList() ) do
		if ( ent.t.Spawnable or ent.t.AdminSpawnable ) then
			table.insert( entities, ":" .. ( ent.ClassName or class ) )
		end
	end

	table.Add( evolve.privileges, entities )

	// Tools
	local tools = {}

	if ( GAMEMODE.IsSandboxDerived ) then
		for _, val in ipairs( file.Find( "weapons/gmod_tool/stools/*.lua", "LUA" )  ) do
			local _, __, class = string.find( val, "([%w_]*).lua" )
			table.insert( tools, "#" .. class )
		end
		
		// wiremod support
		local stools,_ = file.Find( "wire/stools/*.lua", "LUA" )
		for _, val in ipairs(stools) do
			local _, __, class = string.find( val, "([%w_]*)%.lua" )
			table.insert( tools, "#" .. class )
		end
	end

	table.Add( evolve.privileges, tools )

	--this table is kept so when new entities/tools are added they get added to every rank
	if ( file.Exists( "ev_allentitiescache.txt", "DATA" ) ) then
		evolve.allentities = von.deserialize(file.Read( "ev_allentitiescache.txt", "DATA" ))
	else
		evolve.allentities = {}
	end

	for id, rank in pairs( evolve.ranks ) do
		if ( id == "owner" ) then continue; end

		for id,name in pairs(weps) do
			if !table.HasValue(evolve.allentities, name) then
				table.insert( rank.Privileges, name )
				table.insert( evolve.allentities, name)
			end
		end

		for id,name in pairs(entities) do
			if !table.HasValue(evolve.allentities, name) then
				table.insert( rank.Privileges, name )
				table.insert( evolve.allentities, name)
			end
		end

		for id,name in pairs(tools) do
			if !table.HasValue(evolve.allentities, name) then
				table.insert( rank.Privileges, name )
				table.insert( evolve.allentities, name)
			end
		end
	end

	file.Write( "ev_allentitiescache.txt",  von.serialize(evolve.allentities))

	evolve:SaveRanks()
end
evolve:RegisterPlugin( PLUGIN )