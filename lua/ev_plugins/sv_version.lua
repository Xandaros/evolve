/*-------------------------------------------------------------------------------------------------------------------------
	Evolve version
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Version"
PLUGIN.Description = "Returns the version of Evolve."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = { "version", "about" }

function PLUGIN:Call( ply, args )
	evolve:Notify( ply, evolve.colors.white, "This server is running ", evolve.colors.red, "revision " .. evolve.version, evolve.colors.white, " of Evolve." )
end

function PLUGIN:PlayerInitialSpawn( ply )
	if ( ply:EV_IsOwner() ) then
		if ( !self.LatestVersion ) then
			http.Get( "http://code.google.com/p/evolvemod/source/list", "", function( src )
				self.LatestVersion = tonumber( src:match( "r([1-9]+)" ) )
				self:PlayerInitialSpawn( ply )
			end )
			return
		end
		
		if ( evolve.version < self.LatestVersion ) then
			evolve:Notify( ply, evolve.colors.red, "WARNING: Your Evolve SVN needs to be updated to revision " .. self.LatestVersion .. "!" )
		end
	end
end

evolve:RegisterPlugin( PLUGIN )