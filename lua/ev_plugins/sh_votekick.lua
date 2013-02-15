local PLUGIN = {}
PLUGIN.Title = "Votekick"
PLUGIN.Description = "Kick a player by majority vote."
PLUGIN.Author = "Xandaros"
PLUGIN.ChatCommand = "votekick"
PLUGIN.Usage = "<player>"
PLUGIN.Privileges = {"Votekick", "Votekick no cooldown"}
PLUGIN.Dependencies = {"Vote"}

PLUGIN.BanTime = 30
PLUGIN.Cooldown = 30

function PLUGIN:Call(ply, args)
	if not ply:EV_HasPrivilege("Votekick") then
		evolve:Notify(ply, evolve.colors.red, evolve.constants.notallowed)
		return
	end
	
	if #player.GetAll() <= 2 then
		evolve:Notify(ply, evolve.colors.red, "There are not enough players to start a votekick")
		return
	end
	
	if #args < 1 then
		evolve:Notify(ply, evolve.colors.red, "You must specify a player!")
		return
	end
	
	local potentialVictims = evolve:FindPlayer(args[1])
	if #potentialVictims > 1 then
		evolve:Notify(ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( potentialVictims, true ), evolve.colors.white, "?")
		return
	end
	
	local victim = potentialVictims[1]
	
	if victim == nil or evolve.ranks[victim:EV_GetRank()].Immunity > evolve.ranks[ply:EV_GetRank()].Immunity then
		evolve:Notify(ply, evolve.colors.red, evolve.constants.noplayers)
		return
	end
	
	if not ply:EV_HasPrivilege("Votekick no cooldown") and ply.EV_LastVotekick and ply.EV_LastVotekick + PLUGIN.Cooldown*60 > os.time() then
		evolve:Notify(ply, evolve.colors.red, "You started a votekick too recently. Please try again later.")
		return
	end
	
	ply.EV_LastVotekick = os.time()
	
	evolve:Notify(evolve.colors.blue, ply:GetName(), evolve.colors.white, " started a vote to kick ", evolve.colors.red, victim:GetName())
	
	evolve:FindPlugin("Vote"):VoteStart("[Votekick] Kick player " .. victim:GetName(), {"Yes", "No"}, function(percent, absolute)
		if #absolute == 0 then return end
		if absolute[1] > (#player.GetAll())/2 then
			evolve:Notify(evolve.colors.red, victim:GetName(), evolve.colors.white, " has been kicked by vote.")
			evolve:Ban(victim:UniqueID(), self.BanTime*60, "Votekicked", 0)
		else
			evolve:Notify(evolve.colors.white, "Votekicking of ", evolve.colors.red, victim:GetName(), evolve.colors.white, " failed.")
		end
	end)
end

evolve:RegisterPlugin(PLUGIN)
