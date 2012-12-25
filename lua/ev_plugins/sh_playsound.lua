/*-------------------------------------------------------------------------------------------------------------------------
	Play a sound
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Play"
PLUGIN.Description = "Play a sound or repeat the last one played."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "play"
PLUGIN.Usage = "[path=lastusedone]"
PLUGIN.Privileges = { "Play sound" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Play sound" ) ) then
		local sound = args[1] or self.LastSound
		
		if ( sound ) then
			if ( string.match( sound, "^[a-zA-Z0-9/]+.wav$" ) ) then
				if ( !file.Exists( "../sound/" .. sound ) ) then
					evolve:Notify( ply, evolve.colors.red, "Sound \"" .. sound .. "\" not found!" )
					return
				end
			end
			
			for _, pl in ipairs( player.GetAll() ) do
				pl:ConCommand( "play " .. sound )
			end
			
			self.LastSound = sound
		else
			evolve:Notify( ply, evolve.colors.red, "No sound was specified yet!" )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )