/*-------------------------------------------------------------------------------------------------------------------------
	Blind a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Blind"
PLUGIN.Description = "Blind a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "blind"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Blind" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Blind" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl:SetNWBool( "EV_Blinded", enabled )
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has blinded ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has unblinded ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:HUDPaint()
	if ( LocalPlayer():GetNWBool( "EV_Blinded", false ) ) then
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "blind", unpack( players ) )
	else
		return "Blind", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )