/*-------------------------------------------------------------------------------------------------------------------------
	Kill a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Twerk"
PLUGIN.Description = "Twerkify a player."
PLUGIN.Author = "[DARK]Grey"
PLUGIN.ChatCommand = "twerk"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Twerk", "Twerk Others" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Twerk" ) ) then
		local arg1 = tostring(args[ 1 ]) or ""
		if #args == 0 then
			arg1 = ""
		end
		if (tostring(args) == "") then
			arg1=""
		end
		local players = evolve:FindPlayer( args, ply )
		local enabled = false
		if ( arg1 == "" or !arg1) then
			players = evolve:FindPlayer( ply:Nick(), ply )
			enabled = true
		else
			if ply:EV_HasPrivilege( "Twerk Others" ) then
				enabled = true
			end
		end
		for _, pl in ipairs( players ) do
			if (enabled == true) then
				print("Made "..pl:Nick().." twerk.")
				pl:SendLua( "LocalPlayer():ConCommand( \"act muscle\" )" )
			end
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has made ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " twerk." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "twerk", unpack( players ) )
	else
		return "Twerk", evolve.category.punishment
	end
end

evolve:RegisterPlugin( PLUGIN )