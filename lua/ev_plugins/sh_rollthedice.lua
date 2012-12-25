/*-------------------------------------------------------------------------------------------------------------------------
	Roll the dice
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Roll the Dice"
PLUGIN.Description = "Roll a dice and see what happens!"
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "rtd"
PLUGIN.Privileges = { "Roll the Dice" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Roll the Dice" ) and ValidEntity( ply ) ) then			
		if ( ( ply.EV_NextDiceRoll or 0 ) < CurTime() ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has rolled the dice and ", evolve.colors.red, self:RollTheDice( ply ), evolve.colors.white, "!" )
			ply.EV_NextDiceRoll = CurTime() + 60
		else
			evolve:Notify( ply, evolve.colors.red, "Wait a little longer before rolling the dice again!" )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:RollTheDice( ply )
	local choice = math.random( 1, 7 )
	if ( choice == 1 ) then
		local hp = math.random( 5, 20 ) * 10
		ply:SetHealth( ply:Health() + hp )
		
		return "received " .. hp .. " health"
	elseif ( choice == 2 ) then
		ply:Kill()
		
		return "was killed by a mysterious virus"
	elseif ( choice == 3 ) then
		ply:SetHealth( ply:Health() * 0.1 )
		
		return "was struck by lightning"
	elseif ( choice == 4 ) then
		ply:StripWeapons()
		
		return "was robbed by a homeless guy"
	elseif ( choice == 5 ) then
		ply:Ignite( 20, 1 )
		
		return "was ignited by a pyromaniac"
	elseif ( choice == 6 ) then
		ply:GodEnable()
		timer.Simple( 10, function() ply:GodDisable() end )
		
		return "suddenly received invincibility for 10 seconds"
	elseif ( choice == 7 ) then
		ply:Lock()
		timer.Simple( math.random( 10, 15 ), function() ply:UnLock() end )
		
		return "lost the ability to move for some time"
	end
end

evolve:RegisterPlugin( PLUGIN )