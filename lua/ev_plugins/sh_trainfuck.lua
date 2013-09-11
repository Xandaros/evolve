/*-------------------------------------------------------------------------------------------------------------------------
	Fuck a player with a train
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Trainfuck"
PLUGIN.Description = "Trainfuck a player."
PLUGIN.Author = "Divran"
PLUGIN.ChatCommand = "trainfuck"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "trainfuck" }
PLUGIN.Trains = 0

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "trainfuck" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			pl:SetMoveType( MOVETYPE_WALK )
			self:SpawnTrain( pl:GetPos() + pl:GetForward() * 1000 + Vector(0,0,120), pl:GetForward() * -1 )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has trainfucked ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, "No matching players found." )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

 
function PLUGIN:SpawnTrain( Pos, Direction )
        local train = ents.Create( "prop_physics" )
        train:SetModel("models/props_trainstation/train001.mdl")
        train:SetAngles( Direction:Angle() + Angle(0,270,0) )
        train:SetPos( Pos )
        train:Spawn()
        train:Activate()
        train:EmitSound( "ambient/alarms/train_horn2.wav", 100, 100 )
        train:GetPhysicsObject():SetVelocity( Direction * 100000 )
       
        --timer.Create( "TrainRemove_"..CurTime(), 5, 1, function( train ) train:Remove() end, train )
        timer.Simple( 5, function() train:Remove() end )
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "trainfuck", unpack( players ) )
	else
		return "Trainfuck", evolve.category.punishment
	end
end

evolve:RegisterPlugin( PLUGIN )
