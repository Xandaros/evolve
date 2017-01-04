/*-------------------------------------------------------------------------------------------------------------------------
	Goto a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "TPA"
PLUGIN.Description = "Go to a player if they accept."
PLUGIN.Author = "[DARK]Grey"
PLUGIN.ChatCommand = "tpa"
PLUGIN.Usage = "[player]"
PLUGIN.Privileges = { "TPA" }
Evolve_TPA_Table = {}
Evolve_TPA_Table_Num = 1
function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "TPA" ) and ply:IsValid() ) then	
		local players = evolve:FindPlayer( args, ply, false, true )
		
		if ( #players < 2 ) then			
			if ( #players > 0 ) then
				evolve:Notify(players[1], evolve.colors.blue, ply:Nick(), evolve.colors.white, " wants to teleport to you.  !tpaccept to accept. " )
				evolve:Notify(ply, evolve.colors.white, "TPA sent to ",evolve.colors.red,players[1]:Nick(),evolve.colors.white,"." )
				Evolve_TPA_Table[Evolve_TPA_Table_Num] = {}
				Evolve_TPA_Table[Evolve_TPA_Table_Num][1] = ply
				Evolve_TPA_Table[Evolve_TPA_Table_Num][2] = players[1]
				Evolve_TPA_Table_Num=Evolve_TPA_Table_Num+1
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

evolve:RegisterPlugin( PLUGIN )