local PLUGIN = {}
PLUGIN.Title = "Reloadplugin"
PLUGIN.Description = "Reload a plugin at runtime."
PLUGIN.Author = "Xandaros"
PLUGIN.ChatCommand = "reloadplugin"
PLUGIN.Usage = "<plugin>"
PLUGIN.Privileges = { "Plugin reload" }

function PLUGIN:Initialize()
	util.AddNetworkString( "EV_Command" )
end

function PLUGIN:Call( ply, args )
	if ply:IsValid() then
		if !ply:EV_HasPrivilege("Plugin reload") then
			evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
			return
		end
	end
	
	local arg = table.concat(args, " ")

	if ( arg ) then
		local found
		
		for k, plugin in ipairs( evolve.plugins ) do
			if ( string.lower( plugin.Title ) == string.lower( arg ) ) then
				found = k
				break
			end
		end
		
		if ( found ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has reloaded plugin ", evolve.colors.red, evolve.plugins[found].Title, evolve.colors.white, "." )
			
			local plugin = evolve.plugins[found].File
			local title = evolve.plugins[found].Title
			local prefix = string.Left( plugin, string.find( plugin, "_" ) - 1 )
			
			if ( prefix != "cl" ) then
				table.remove( evolve.plugins, found )
				evolve.pluginFile = plugin
				include( "ev_plugins/" .. plugin )
				evolve:ResolveDependencies()
			end
			
			if ( prefix == "sh" or prefix == "cl" ) then
				net.Start("EV_PluginFile")
					net.WriteString(title)
					net.WriteString(file.Read( "ev_plugins/" .. plugin, "LUA" ))
				net.Broadcast()
			end
		else
			if ply:IsValid() then
				evolve:Notify(ply, evolve.colors.red, "Plugin '" .. tostring(arg) .. "' not found!")
			else
				print( "[EV] Plugin '" .. tostring( arg ) .. "' not found!" )
			end
		end
	end
end

if CLIENT then
	net.Receive( "EV_PluginFile", function( length )
		local title = net.ReadString()
		local contents = net.ReadString()
		
		for k, plugin in ipairs( evolve.plugins ) do
			if ( string.lower( plugin.Title ) == string.lower( title ) ) then
				found = k
				table.remove( evolve.plugins, k )
			end
		end
		
		RunString( contents )
	end )
end

evolve:RegisterPlugin(PLUGIN)
