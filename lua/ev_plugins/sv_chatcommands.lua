/*-------------------------------------------------------------------------------------------------------------------------
	Provides chat commands
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Chat Commands"
PLUGIN.Description = "Provides chat commands to run plugins."
PLUGIN.Author = "Overv"

// Thank you http://lua-users.org/lists/lua-l/2009-07/msg00461.html
function PLUGIN:Levenshtein( s, t )
	local d, sn, tn = {}, #s, #t
	local byte, min = string.byte, math.min
	for i = 0, sn do d[i * tn] = i end
	for j = 0, tn do d[j] = j end
	for i = 1, sn do
		local si = byte(s, i)
		for j = 1, tn do
d[i*tn+j] = min(d[(i-1)*tn+j]+1, d[i*tn+j-1]+1, d[(i-1)*tn+j-1]+(si == byte(t,j) and 0 or 1))
		end
	end
	return d[#d]
end

function PLUGIN:GetCommand( msg )
	return ( string.match( msg, "%w+" ) or "" ):lower()
end

function PLUGIN:GetArguments( msg )
	local args = {}
	local first = true
	
	for match in string.gmatch( msg, "[^ ]+" ) do
		if ( first ) then first = false else
			table.insert( args, match )
		end
	end
	
	return args
end

function PLUGIN:PlayerSay( ply, msg )
	if ( ( GAMEMODE.Name == "Sandbox" and string.Left( msg, 1 ) == "/" ) or string.Left( msg, 1 ) == "!" or string.Left( msg, 1 ) == "@" ) then
		local command = self:GetCommand( msg )
		local args = self:GetArguments( msg )
		local closest = { dist = 99, plugin = "" }
		
		if ( #command > 0 ) then
			evolve:Log( evolve:PlayerLogStr( ply ) .. " ran command '" .. command .. "' with arguments '" .. table.concat( args, " " ) .. "' via chat." )
			
			for _, plugin in ipairs( evolve.plugins ) do
				if ( plugin.ChatCommand == command or ( type( plugin.ChatCommand ) == "table" and table.HasValue( plugin.ChatCommand, command ) ) ) then
					evolve.SilentNotify = string.Left( msg, 1 ) == "@"			
						res, ret = pcall( plugin.Call, plugin, ply, args, string.sub( msg, #command + 3 ), command )
					evolve.SilentNotify = false				
					
					if ( !res ) then
						evolve:Notify( evolve.colors.red, "Plugin '" .. plugin.Title .. "' failed with error:" )
						evolve:Notify( evolve.colors.red, ret )
					end
					
					return ""
				elseif ( plugin.ChatCommand ) then					
					local dist = self:Levenshtein( command, type( plugin.ChatCommand ) == "table" and plugin.ChatCommand[1] or plugin.ChatCommand )
					if ( dist < closest.dist ) then
						closest.dist = dist
						closest.plugin = plugin
					end
				end
			end
			
			if ( ply.EV_Gagged ) then
				return ""
			else
				if ( closest.dist <= 0.25 * #closest.plugin.ChatCommand ) then
					res, ret = pcall( closest.plugin.Call, closest.plugin, ply, args )
					
					if ( !res ) then
						evolve:Notify( evolve.colors.red, "Plugin '" .. closest.plugin.Title .. "' failed with error:" )
						evolve:Notify( evolve.colors.red, ret )
					end
					
					return ""
				end
			end
		end
		end
end

evolve:RegisterPlugin( PLUGIN )