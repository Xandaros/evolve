
local PLUGIN = {};

PLUGIN.Title = "Spawnpoint";
PLUGIN.Description = "Set your spawnpoint.";
PLUGIN.Author = "DarKSunrise";
PLUGIN.ChatCommand = "spawnpoint";
PLUGIN.Usage = "[set/reset]";
PLUGIN.Privileges = {"Set and reset spawnpoint",}

PLUGIN.spawnpoints = {};

function PLUGIN:Call(ply, args)
	if(not ply:EV_HasPrivilege("Set and reset spawnpoint")) then
		evolve:Notify(ply, evolve.colors.red, evolve.constants.notallowed);
		return;
	end	
	local players = evolve:FindPlayer( args, ply, true )
	local arg1 = tostring(args[ 1 ]) or ""
	local enabled = tostring(args[ #args ]) or ""
	if (arg1 == "set") or (arg1 == "reset") then
		players = {};
		table.insert(players,ply)
		enabled = arg1
	end
	for _, pl in ipairs( players ) do
		if (string.lower(enabled) != "reset") then
			evolve:Notify(pl, evolve.colors.white, "Your ", evolve.colors.blue, "spawnpoint ", evolve.colors.white, "has been ", evolve.colors.blue, "set", evolve.colors.white, "!");
			
			self.spawnpoints[pl] = {
				pos = ply:GetPos(),
				ang = ply:EyeAngles()
			};
		else
			evolve:Notify(pl, evolve.colors.white, "Your ", evolve.colors.blue, "spawnpoint ", evolve.colors.white, "has been ", evolve.colors.red, "reset", evolve.colors.white, "!");
			
			self.spawnpoints[pl] = nil;
		end
	end
end

function PLUGIN:PlayerSpawn(ply)
	if(self.spawnpoints[ply] and ply:EV_HasPrivilege("Set and reset spawnpoint")) then
		ply:SetPos(self.spawnpoints[ply].pos);
		ply:SetEyeAngles(self.spawnpoints[ply].ang);
	end
end

evolve:RegisterPlugin(PLUGIN);