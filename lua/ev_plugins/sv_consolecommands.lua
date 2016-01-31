/*-------------------------------------------------------------------------------------------------------------------------
	Provides console commands
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Console Commands"
PLUGIN.Description = "Provides console commands to run plugins."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = nil
PLUGIN.Usage = nil

function PLUGIN:GetArguments( allargs )
	local newargs = {}
	for i = 2, #allargs do
		table.insert( newargs, allargs[i] )
	end
	return newargs
end

function PLUGIN:CCommand( ply, com, cargs )
	if ( #cargs == 0 ) then return end
	
	local command = cargs[1]
	local args = self:GetArguments( cargs )
	
	evolve:Log( evolve:PlayerLogStr( ply ) .. " ran command '" .. command .. "' with arguments '" .. table.concat( args, " " ) .. "' via console." )
	
	for _, plugin in ipairs( evolve.plugins ) do
		if ( plugin.ChatCommand == command or ( type( plugin.ChatCommand ) == "table" and table.HasValue( plugin.ChatCommand, command ) ) ) then
			res, ret = pcall( plugin.Call, plugin, ply, args, string.sub( com, #command + 3 ), command )
			evolve.SilentNotify = false

			if ( !res ) then
				evolve:Notify( evolve.colors.red, "Plugin '" .. plugin.Title .. "' failed with error:" )
				evolve:Notify( evolve.colors.red, ret )
			end
			return ""
		end
	end
	
	evolve:Message( "Unknown command '" .. command .. "'" )
end
concommand.Add( "ev", function( ply, com, args ) PLUGIN:CCommand( ply, com, args ) end )
concommand.Add( "evs", function( ply, com, args ) evolve.SilentNotify = true PLUGIN:CCommand( ply, com, args ) evolve.SilentNotify = false end )

evolve:RegisterPlugin( PLUGIN )
