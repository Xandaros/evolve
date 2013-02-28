/*-------------------------------------------------------------------------------------------------------------------------
	Prints a message to console whenever someone spawns something
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = { }
PLUGIN.Title = "Message Print"
PLUGIN.Description = "Prints a message to console whenever someone spawns something."
PLUGIN.Author = "Divran"
PLUGIN.ChatCommand = "conmsg"
PLUGIN.Usage = "1/0"

if ( SERVER ) then
	-- Precache the net message
	util.AddNetworkString("Evolve conmsg")
	
	-- Enable/Disable
	function PLUGIN:Call( ply, args )
		ply.EV_ConmsgEnabled = !ply.EV_ConmsgEnabled
		evolve:Notify( ply, evolve.colors.blue, "Conmsg Print ", evolve.colors.white, "set to: ", evolve.colors.red, tostring(ply.EV_ConmsgEnabled) )
	end
	
	function PLUGIN:SendData( ply, obj )
		local targets = {}
		for _,v in pairs( player.GetAll() ) do
			if ( v.EV_ConmsgEnabled == true ) then
				targets[ table.Count( targets ) + 1 ] = v
			end
		end
		
		local String = "[EV] " .. ply:Nick() .. " (" .. ply:SteamID() .. ") spawned (" .. obj:GetClass() .. ") " .. obj:GetModel()
		
		if ( #targets > 0 ) then
			-- Send to targets
			for _, v in pairs( targets ) do
				net.Start( "Evolve conmsg" )
					net.WriteString( String )
				net.Send( v )
			end
		end
		
		-- Print to server's console
		print( String )
	end

	-- Check for spawns
	function PLUGIN:PlayerSpawnedProp( ply, mdl, obj ) self:SendData( ply, obj ) end
	function PLUGIN:PlayerSpawnedVehicle( ply, obj ) self:SendData( ply, obj ) end
	function PLUGIN:PlayerSpawnedNPC( ply, npc ) self:SendData( ply, npc ) end
	function PLUGIN:PlayerSpawnedEffect( ply, mdl, obj ) self:SendData( ply, obj ) end
	function PLUGIN:PlayerSpawnedRagdoll( ply, mdl, obj ) self:SendData( ply, obj ) end
	function PLUGIN:PlayerSpawnedSENT( ply, obj ) self:SendData( ply, obj ) end
	
	-- Enabled by default
	function PLUGIN:PlayerInitialSpawn( ply )
		ply.EV_ConmsgEnabled = true
	end
else
	net.Receive( "Evolve conmsg", function( length, client )
		local String = net.ReadString()
		-- Print
		print( String )
	end )
end

evolve:RegisterPlugin( PLUGIN )