/*-------------------------------------------------------------------------------------------------------------------------
	Display all chat commands
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Chatcommands"
PLUGIN.Description = "Display all available chat commands."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "commands"

function PLUGIN:Initialize()
	util.AddNetworkString( "EV_Command" )
end

function PLUGIN:Call( ply, args )
	local commands = {}
	--table.SortByMember( commands, "ChatCommand", function( a, b ) return a > b end )
	
	if ( ply:IsValid() ) then
		for _, plug in ipairs( evolve.plugins ) do
			if ( plug.ChatCommand ) then
				if type(plug.ChatCommand) == "string" then
					table.insert(commands, {plug.ChatCommand, plug.Usage, plug.Description})
				else
					for k, ChatCommand in ipairs( plug.ChatCommand ) do
						local usage
						
						if (type(plug.Usage) == "table") then
							usage = plug.Usage[k]
						else
							usage = plug.Usage
						end
						
						table.insert(commands, {ChatCommand, tostring(usage), plug.Description})
					end
				end
			end
		end
		
		table.SortByMember(commands, 1, function(a,b) return a > b end)
		
		net.Start( "EV_Command" )
			net.WriteBit( false )
			net.WriteString( "\n============ Available chat commands for Evolve ============\n" )
		net.Send( ply )
		
		for k,cmd in pairs(commands) do
			net.Start( "EV_Command" )
				net.WriteBit( true )
				net.WriteString( cmd[1] or "" )
				net.WriteString( cmd[2] or "" )
				net.WriteString( cmd[3] or "" )
			net.Send( ply )
		end
		
		net.Start( "EV_Command" )
			net.WriteBit( false )
			net.WriteString( "" )
		net.Send( ply )
		
		evolve:Notify( ply, evolve.colors.white, "All chat commands have been printed to your console." )
	else
		for _, plugin in ipairs( commands ) do
			if ( plugin.ChatCommand ) then
				if ( plugin.Usage ) then
					print( "!" .. plugin.ChatCommand .. " " .. plugin.Usage .. " - " .. plugin.Description )
				else
					print( "!" .. plugin.ChatCommand .. " - " .. plugin.Description )
				end
			end
		end
	end
end

if CLIENT then
	net.Receive( "EV_Command", function( len )
		if net.ReadBit() == 1 then
			local com   = net.ReadString()
			local usage = net.ReadString()
			local desc  = net.ReadString()
			
			if usage != "nil" then
				print( "!" .. com .. " " .. usage .. " - " .. desc )
			else
				print( "!" .. com .. " - " .. desc )
			end
		else
			print( net.ReadString() )
		end
	end)
end

evolve:RegisterPlugin( PLUGIN )
