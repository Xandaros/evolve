/*-------------------------------------------------------------------------------------------------------------------------
	Clean up the map
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Cleanup"
PLUGIN.Description = "Clean up the map."
PLUGIN.Author = "Overv, MadDog896, Divran"
PLUGIN.ChatCommand = "cleanup"
PLUGIN.Usage = "[player]"
PLUGIN.Privileges = { "Cleanup" }
PLUGIN.ignore_classes = {}

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Cleanup" ) ) then
		if ( #args == 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has cleaned up the map." )
			game.CleanUpMap( false, self.ignore_classes )
		else
			local players = evolve:FindPlayer( args )
			
			if ( #players > 0 ) then
				for _, ent in ipairs( ents.GetAll() ) do
					for _, ply in ipairs( players ) do
						if ( ent:EV_GetOwner() == ply:UniqueID() ) then ent:Remove() end
					end
				end
				
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has cleaned up the entities of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
			end
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:InitPostEntity()
	local lookup = {}
	local entities = ents.GetAll()
	for i=1,#entities do
		local class = entities[i]:GetClass()
		if not lookup[class] then
			lookup[class] = true
			self.ignore_classes[#self.ignore_classes+1] = class
		end
	end
end


evolve:RegisterPlugin( PLUGIN )