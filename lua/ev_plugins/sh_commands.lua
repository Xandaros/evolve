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
	local commands = table.Copy( evolve.plugins )
	--table.SortByMember( commands, "ChatCommand", function( a, b ) return a > b end )
	
	if ( ply:IsValid() ) then
		net.Start( "EV_Command" )
			net.WriteBit( false )
			net.WriteString( "\n============ Available chat commands for Evolve ============\n" )
		net.Send( ply )
		
		for _, plug in ipairs( commands ) do
			if ( plug.ChatCommand ) then
				if type(plug.ChatCommand) == "string" then plug.ChatCommand = { plug.ChatCommand } end
				for __, ChatCommand in ipairs( plug.ChatCommand ) do
					net.Start( "EV_Command" )
						net.WriteBit( true )
						net.WriteString( ChatCommand )
						net.WriteString( tostring( plug.Usage ) )
						net.WriteString( plug.Description )
					net.Send( ply )
				end

			end
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

evolve:RegisterPlugin( PLUGIN )