local PLUGIN = {}
PLUGIN.Title = "Restriction"
PLUGIN.Description = "Restricts weapons."
PLUGIN.Author = "Overv"

function PLUGIN:PlayerSpawnSWEP( ply, name, tbl )
	if ( GAMEMODE.IsSandboxDerived and table.HasValue( evolve.privileges, "@" .. name ) and !ply:EV_HasPrivilege( "@" .. name ) ) then
		evolve:Notify( ply, evolve.colors.red, "You are not allowed to spawn this weapon!" )
		return false
	end
end
function PLUGIN:PlayerGiveSWEP( ply, name, tbl )
	if ( self:PlayerSpawnSWEP( ply, name, tbl ) == false ) then
		return false
	end
end

function PLUGIN:PlayerSpawnSENT( ply, class )
	if ( GAMEMODE.IsSandboxDerived and table.HasValue( evolve.privileges, ":" .. class ) and !ply:EV_HasPrivilege( ":" .. class ) ) then
		evolve:Notify( ply, evolve.colors.red, "You are not allowed to spawn this entity!" )
		return false
	end
end

function PLUGIN:CanTool( ply, tr, class )
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
	if ( GAMEMODE.IsSandboxDerived and table.HasValue( evolve.privileges, "@" .. wep:GetClass() ) and !ply:EV_HasPrivilege( "@" .. wep:GetClass() ) and ( !ply.EV_PickupTimeout or CurTime() < ply.EV_PickupTimeout ) ) then
		return false
	end
end

function PLUGIN:Initialize()	
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
		"@weapon_rpg",
		"@weapon_ar2",
		"@weapon_physgun",
		"@weapon_annabelle",
		"@weapon_slam",
		"@weapon_stunstick",
	} )
	
	table.Add( evolve.privileges, weps )
	
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
		local stools,_ = file.Find( "weapons/gmod_tool/stools/*.lua", "LUA" )
		for _, val in ipairs( stools ) do
			local _, __, class = string.find( val, "([%w_]*)%.lua" )
			table.insert( tools, "#" .. class )
		end
	end
	
	table.Add( evolve.privileges, tools )
	
	// If this is the first time the restriction plugin runs, add all weapon and entity privileges to all ranks so it doesn't break anything
	if ( !evolve:GetGlobalVar( "RestrictionSetUp", false ) ) then		
		for id, rank in pairs( evolve.ranks ) do
			if ( id != "owner" ) then
				table.Add( rank.Privileges, weps )
			end
		end
		
		evolve:SetGlobalVar( "RestrictionSetUp", true )
		evolve:SaveRanks()
	end
	
	if ( !evolve:GetGlobalVar( "RestrictionSetUpEnts", false ) ) then		
		for id, rank in pairs( evolve.ranks ) do
			if ( id != "owner" ) then
				table.Add( rank.Privileges, entities )
			end
		end
		
		evolve:SetGlobalVar( "RestrictionSetUpEnts", true )
		evolve:SaveRanks()
	end
	
	if ( !evolve:GetGlobalVar( "RestrictionSetUpTools2", false ) ) then		
		for id, rank in pairs( evolve.ranks ) do
			if ( id != "owner" ) then
				table.Add( rank.Privileges, tools )
			end
		end
		
		evolve:SetGlobalVar( "RestrictionSetUpTools2", true )
		evolve:SaveRanks()
	end
end

evolve:RegisterPlugin( PLUGIN )