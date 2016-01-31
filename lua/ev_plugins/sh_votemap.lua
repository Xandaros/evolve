/*-------------------------------------------------------------------------------------------------------------------------
	Vote for a map
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Votemap"
PLUGIN.Description = "Vote for a map."
PLUGIN.Author = "Feha and [DARK]Grey"
PLUGIN.ChatCommand = "votemap"
PLUGIN.Usage = '[name/num]'
PLUGIN.Privileges = { "Votemap" }
PLUGIN.Maps = {}
PLUGIN.Votes = {}
PLUGIN.Voters = {}
tmpGlobalMap = ""
-- Initialization
function PLUGIN:Initialize()
	CreateConVar("ev_votemap_percent","0.6") --How many percent of the players that have to vote for the same map
	CreateConVar("ev_votemap_delay","10") --How many seconds after a voted mapchange have started that it still can be stopped
	self:GetMaps()
end
-- Get map list from the map list plugin
function PLUGIN:GetMaps()
	local files = file.Find( "maps/*.bsp", "GAME" )
	local temp = ""
	local i = 0;
	for _, filename in pairs( files ) do
		temp = string.sub(filename,1,string.len(filename)-4)
		table.insert( PLUGIN.Maps, temp)
	end
end

-- Does the map exist on the server?
function PLUGIN:MapExists( map )
	for index, name in pairs( self.Maps ) do
		if (index == tonumber(map) or name == map) then
			return true, index
		end
	end
	return false, 0
end


function PLUGIN:Call( ply, args )
	if (ply:EV_HasPrivilege( "Votemap" )) then
		if (args[1] and args[1] != "") then
			if (!timer.Exists( "evolve_votemap" )) then
				local map = args[1]
				local exists, index = PLUGIN:MapExists( map )
				if (!exists) then
					evolve:Notify( ply, evolve.colors.red, "That map does not exist." )
				else
					--No need to remove a vote if the player have not voted for anything
					if (self.Voters[ply]) then
						self:RemoveVote( self.Voters[ply] )
					end
					
					local votesLeft = self:GetVotesNeeded() - self:GetVotes(index) - 1
					evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " voted for ", evolve.colors.red, self.Maps[index], evolve.colors.white, ". It needs ", evolve.colors.red, tostring(votesLeft), evolve.colors.white, " more." )
					
					self:AddVote( index )
					
					--Set what map the player have voted for so we can remove a vote from it if player change his mind
					self.Voters[ply] = index
				end
			else
				evolve:Notify( ply, evolve.colors.red, "Already changing to a map." )
			end
		else
			--print maps to console
			evolve:Notify( ply, evolve.colors.red, "Printed a list of the maps in console." )
			for index, name in pairs( self.Maps ) do
				ply:PrintMessage( HUD_PRINTCONSOLE, index .. ": " .. name )
			end
		end
	end
end

function PLUGIN:AddVote( index )
	if (!self.Votes[index]) then
		self.Votes[index] = 0
	end
	
	self.Votes[index] = self.Votes[index] + 1
	
	--As we added a vote for the map, we should check if it has enough votes
	self:CheckVote( index )
end

function PLUGIN:RemoveVote( index )
	if (!self.Votes[index]) then
		self.Votes[index] = 0
	end
	
	self.Votes[index] = self.Votes[index] - 1
end

function PLUGIN:GetVotes( index )
	if (!self.Votes[index]) then
		self.Votes[index] = 0
	end
	
	return self.Votes[index]
end

function PLUGIN:GetVotesNeeded( )
	return math.ceil(#player.GetAll() * tonumber(GetConVarString("ev_votemap_percent")))
end

function PLUGIN:CheckVote( index )
	if (self.Votes[index] >= PLUGIN:GetVotesNeeded( )) then
		local map = self.Maps[index]
		tmpGlobalMap = map
		local delay = tonumber(GetConVarString("ev_votemap_delay"))
		evolve:Notify( evolve.colors.red, "Warning:", evolve.colors.white, " changing map to ", evolve.colors.red, map, evolve.colors.white, " in ", evolve.colors.red, tostring(delay), evolve.colors.white, " seconds." )
		timer.Create( "evolve_votemap", delay, 1, function( )
			game.ConsoleCommand( "changelevel " .. tmpGlobalMap .. "\n" )
		end)
	end
end

evolve:RegisterPlugin( PLUGIN )