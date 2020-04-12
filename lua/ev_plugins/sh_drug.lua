/*-------------------------------------------------------------------------------------------------------------------------
	Drug a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Drug"
PLUGIN.Description = "Drug a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "drug"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Drug" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Drug" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl:SetNWBool( "EV_Druged", enabled )
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has druged ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has undruged ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:HUDPaint()
	if ( LocalPlayer():GetNWBool( "EV_Druged", false ) ) then
		local tmpcolor = HSVToColor(math.random(0,255), 1, 1)
		surface.SetDrawColor( tmpcolor.r, tmpcolor.g, tmpcolor.b, 200 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "drug", unpack( players ) )
	else
		return "Drug", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )