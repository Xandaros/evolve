/*-------------------------------------------------------------------------------------------------------------------------
	Goto a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "TPDeny"
PLUGIN.Description = "Deny TPA Request"
PLUGIN.Author = "[DARK]Grey"
PLUGIN.ChatCommand = "tpdeny"
PLUGIN.Usage = ""
PLUGIN.Privileges = { "Teleport Deny" }

PLUGIN.Positions = {}

if Evolve_TPA_Table then
	print ("TPA Table Exists.")
else
	print ("Creating TPA Table.")
	Evolve_TPA_Table = {}
	Evolve_TPA_Table_Num = 0
end
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
	if ( ply:EV_HasPrivilege( "Teleport Deny" ) and ply:IsValid() ) then	
		local numiterations = 0;
		for k,v in pairs(Evolve_TPA_Table) do
			local tmptable = v;
			if tmptable then
				local frompl = tmptable[1]
				local topl = tmptable[2]
				if (topl == ply) then
					numiterations = numiterations + 1
					table.remove(tmptable,k)
					evolve:Notify(frompl, evolve.colors.white, "TPA declined by ",evolve.colors.red,topl:Nick(),evolve.colors.white,"." )
				end
			else
				print("No data received for TPA temp table.")
			end
		end
		if numiterations < 1 then
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
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