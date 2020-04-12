/*-------------------------------------------------------------------------------------------------------------------------
	THE HAAAAAAAAAAAAAAAAAAAX!
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Hax"
PLUGIN.Description = "The HAAAAAAAAAAAX!"
PLUGIN.Author = "Divran"
PLUGIN.ChatCommand = "hax"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "throw monitor hax" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "throw monitor hax" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			pl:SetMoveType( MOVETYPE_WALK )
			self:SpawnTrain( pl:GetPos() + pl:GetForward() * 1000 + Vector(0,0,50), pl:GetForward() * -1 )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.white, "HERE COME THE HAX, ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, "No matching players found." )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:SpawnTrain( Pos, Direction )
	local train = ents.Create( "prop_physics" )
	train:SetModel("models/props_lab/monitor02.mdl")
	train:SetAngles( Direction:Angle() )
	train:SetPos( Pos )
	train:Spawn()
	train:Activate()
	train:EmitSound( "vo/npc/male01/hacks01.wav", 100, 100 )
	train:GetPhysicsObject():SetVelocity( Direction * 50000 )
	
        --timer.Create( "TrainRemove_"..CurTime(), 5, 1, function( train ) train:Remove() end, train )
        timer.Simple( 5, function() train:Remove() end )
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "hax", unpack( players ) )
	else
		return "Hax", evolve.category.punishment
	end
end

evolve:RegisterPlugin( PLUGIN )