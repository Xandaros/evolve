/*-------------------------------------------------------------------------------------------------------------------------
	NoRecoil a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Recoil Control"
PLUGIN.Description = "Disable recoil for a player."
PLUGIN.Author = "Grey"
PLUGIN.ChatCommand = "norecoil"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Recoil Control" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "NoRecoil" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl:SetNWBool( "EV_NoRecoiled", enabled )
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has disabled recoil for ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has made ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " have recoil." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:CalcView( ply, pos, angles, fov )
	if ply:GetNWBool( "EV_NoRecoiled", false ) then
		return {
			origin = ply:EyePos(),
			angles = ply:EyeAngles(),
			fov = fov
		}
	end
end
function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "norecoil", unpack( players ) )
	else
		return "NoRecoil", evolve.category.actions, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )