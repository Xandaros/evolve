/*-------------------------------------------------------------------------------------------------------------------------
	Explode a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Explode"
PLUGIN.Description = "Explode a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "explode"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Explode" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Explode" ) ) then
		local players = evolve:FindPlayer( args, ply )
		
		for _, pl in ipairs( players ) do
			local explosive = ents.Create( "env_explosion" )
			explosive:SetPos( pl:GetPos() )
			explosive:SetOwner( pl )
			explosive:Spawn()
			explosive:SetKeyValue( "iMagnitude", "1" )
			explosive:Fire( "Explode", 0, 0 )
			explosive:EmitSound( "ambient/explosions/explode_4.wav", 500, 500 )
			
			pl:SetVelocity( Vector( 0, 0, 400 ) )
			pl:Kill()
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has exploded ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "explode", unpack( players ) )
	else
		return "Explode", evolve.category.punishment
	end
end

evolve:RegisterPlugin( PLUGIN )