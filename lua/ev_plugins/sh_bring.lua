/*-------------------------------------------------------------------------------------------------------------------------
	Bring a player to you
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Bring"
PLUGIN.Description = "Bring a player."
PLUGIN.Author = "Overv & Divran"
PLUGIN.ChatCommand = "bring"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Bring" }

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
	if ( ply:EV_HasPrivilege( "Bring" ) and ply:IsValid() ) then	
		local players = evolve:FindPlayer( args, ply )
		
		for i, pl in ipairs( players ) do
			if ( pl:InVehicle() ) then pl:ExitVehicle() end
			if ( pl:GetMoveType() == MOVETYPE_NOCLIP) then
				pl:SetPos( ply:GetPos() + ply:GetForward() * 45 )
			else
				local Pos = self:FindPosition( ply )
				if (Pos) then
					pl:SetPos( Pos )
				else
					--evolve:Notify( pl, evolve.colors.red, "No free position was found. You were forcefully teleported in front of the player instead." )
					pl:SetPos( ply:GetPos() + Vector(0,0,72 * i) )
				end
			end
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has brought ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to them." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "bring", unpack( players ) )
	else
		return "Bring", evolve.category.teleportation
	end
end

evolve:RegisterPlugin( PLUGIN )