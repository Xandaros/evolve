/*-------------------------------------------------------------------------------------------------------------------------
	Teleport a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Teleport"
PLUGIN.Description = "Teleport a player."
PLUGIN.Author = "Overv & Divran"
PLUGIN.ChatCommand = "tp"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Teleport" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Teleport" ) and ply:IsValid() ) then	
		local players = evolve:FindPlayer( args, ply )
		
		if (#players > 0) then			
			local size = Vector( 32, 32, 72 )
			
			local tr = {}
			tr.start = ply:GetShootPos()
			tr.endpos = ply:GetShootPos() + ply:GetAimVector() * 100000000
			tr.filter = ply
			local trace = util.TraceEntity( tr, ply )
			
			local EyeTrace = ply:GetEyeTraceNoCursor()
			if (trace.HitPos:Distance(EyeTrace.HitPos) > size:Length()) then -- It seems the player wants to teleport through a narrow spot... Force them there even if there is something in the way.
				trace = EyeTrace
				trace.HitPos = trace.HitPos + trace.HitNormal * size * 1.2
			end
			
			size = size * 1.5
			
			for i, pl in ipairs( players ) do
				if ( pl:InVehicle() ) then pl:ExitVehicle() end
				
				pl:SetPos( trace.HitPos + trace.HitNormal * ( i - 1 ) * size )
				pl:SetLocalVelocity( Vector( 0, 0, 0 ) )
			end
			
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has teleported ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "tp", unpack( players ) )
	else
		return "Teleport", evolve.category.teleportation
	end
end

evolve:RegisterPlugin( PLUGIN )