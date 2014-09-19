/*-------------------------------------------------------------------------------------------------------------------------
	NoRecoil a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Spawn Protection"
PLUGIN.Description = "Players with this permission have spawn protection."
PLUGIN.Author = "Grey"
PLUGIN.Usage = "none"
PLUGIN.Privileges = { "Spawn Protection" }
if SERVER then
	local weps = {}

	local function Think()
		for k,v in pairs(player.GetAll()) do
			if weps[v] then
				if v:GetActiveWeapon() && v:GetActiveWeapon():IsValid() && v:GetActiveWeapon() != weps[v] then
					hook.Call("PlayerWeaponChanged", gmod.GetGamemode(), v, weps[v], v:GetActiveWeapon()) -- Params: Player (who changed the weapon), Weapon (weapon switch from), Weapon(weapon switched to)
					weps[v] = v:GetActiveWeapon()
				end
			else
				if v:GetActiveWeapon() && v:GetActiveWeapon():IsValid() then
					weps[v] = v:GetActiveWeapon()
				end
			end
		end
	end
	hook.Add("Think", "WeaponCheck.Think", Think)
	function SPOnWeaponEquip( ply, oldwep, eqwep )
		if (!eqwep:IsWeapon()) then
			return;
		end
		local wepname = string.lower(eqwep:GetClass())
		local hassp = ply:GetNWBool( "EV_SpawnProtected", false)
		if (string.match(wepname,"weapon_physgun") or string.match(wepname,"gmod_tool") or string.match(wepname,"gmod_camera") or string.match(wepname,"toolgun") or string.match(wepname,"tool gun") or string.match(wepname,"physgun") or string.match(wepname,"physicsgun") or string.match(wepname,"physcannon") or string.match(wepname,"physicscannon")or string.match(wepname,"phys gun") or string.match(wepname,"physics gun")or string.match(wepname,"phys cannon") or string.match(wepname,"physics cannon")or string.match(wepname,"camera")) then
			ply:SetNWBool( "EV_SpawnProtected", hassp )
		else
			ply:SetNWBool( "EV_SpawnProtected", false )
			if (hassp == true) then
				hassp = false
				print("Spawn protection ended for "..ply:Nick()..".")
			end
		end
	end
	function SPOnSpawn( ply )
		if ( ply:EV_HasPrivilege( "Spawn Protection" ) ) then
			ply:SetNWBool( "EV_SpawnProtected", true )
			timer.Simple(15, function() 
				if ply and ply:IsPlayer() then
					local hassp = ply:GetNWBool( "EV_SpawnProtected", false)
					if (hassp == true) then
						ply:SetNWBool( "EV_SpawnProtected", false ) 
						print("Spawn protection ended for "..ply:Nick()..".")
					end
				end
			end)
			evolve:Notify( ply, evolve.colors.white, "Your spawn protection lasts for ", evolve.colors.red, " 15 seconds ", evolve.colors.white, " or until you draw a weapon.")
		else
			ply:SetNWBool( "EV_SpawnProtected", false )
		end
	end
	function SPShouldTakeDamage( ply, attacker)
		if (ply:GetNWBool( "EV_SpawnProtected", false) == true) then
			if attacker:IsPlayer() then
				evolve:Notify( evolve.colors.red, attacker:Nick(), evolve.colors.white, " has attempted to spawnkill!" )
				local atwep = attacker:GetActiveWeapon()
				if atwep:IsWeapon() then
					local ammotype=atwep:GetPrimaryAmmoType( )
					attacker:RemoveAmmo(attacker:GetAmmoCount(ammotype),ammotype)
					attacker:DropWeapon(atwep)
				end
				return false;
			end
		end
	end
	hook.Add("PlayerWeaponChanged","EVSpawnProtect_OnWeaponDraw",SPOnWeaponEquip)
	hook.Add("PlayerSpawn","EVSpawnProtect_OnPlayerSpawn",SPOnSpawn)
	hook.Add("PlayerShouldTakeDamage","EVSpawnProtect_OnPlayerDamage",SPShouldTakeDamage)
end
evolve:RegisterPlugin( PLUGIN )