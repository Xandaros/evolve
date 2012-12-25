/*-------------------------------------------------------------------------------------------------------------------------
	Goto a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Goto"
PLUGIN.Description = "Go to a player."
PLUGIN.Author = "Overv & Divran"
PLUGIN.ChatCommand = "goto"
PLUGIN.Usage = "[player]"
PLUGIN.Privileges = { "Goto" }

PLUGIN.Positions = {}
for i=0,360,45 do table.insert( PLUGIN.Positions, Vector(math.cos(i),math.sin(i),0) ) end -- Around
table.insert( PLUGIN.Positions, Vector(0,0,1) ) -- Above

function PLUGIN:FindPosition( ply )
	local size = Vector( 32, 32, 72 )
	
	local StartPos = ply:GetPos() + Vector(0,0,size.z/2)
	
	for _,v in ipairs( self.Positions ) do
		local Pos = StartPos + v * size * 1.5
		
		local tr = {}
		tr.start = Pos
		tr.endpos = Pos
		tr.mins = size / 2 * -1
		tr.maxs = size / 2
		local trace = util.TraceHull( tr )
		
		if (!trace.Hit) then
			return Pos - Vector(0,0,size.z/2)
		end
	end
	
	return false
end

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Goto" ) and ply:IsValid() ) then	
		local players = evolve:FindPlayer( args, ply, false, true )
		
		if ( #players < 2 ) then			
			if ( #players > 0 ) then
				if ( ply:InVehicle() ) then ply:ExitVehicle() end
				if ( ply:GetMoveType() == MOVETYPE_NOCLIP) then
					ply:SetPos( players[1]:GetPos() + players[1]:GetForward() * 45 )
				else
					local Pos = self:FindPosition( players[1] )
					if (Pos) then
						ply:SetPos( Pos )
					else
						--evolve:Notify( ply, evolve.colors.red, "No free position was found. You were forcefully teleported in front of the player instead." )
						ply:SetPos( players[1]:GetPos() + Vector(0,0,72) )
					end
				end
				
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has gone to ", evolve.colors.red, players[1]:Nick(), evolve.colors.white, "." )
			else
				evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
			end
		else
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( players, true ), evolve.colors.white, "?" )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "goto", unpack( players ) )
	else
		return "Goto", evolve.category.teleportation
	end
end

evolve:RegisterPlugin( PLUGIN )