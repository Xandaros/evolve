/*-------------------------------------------------------------------------------------------------------------------------
	Rank colors
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Rank colors"
PLUGIN.Description = "Displays rank colors in chat."
PLUGIN.Author = "Overv"
PLUGIN.Privileges = { "See chat tags" }

function PLUGIN:OnPlayerChat( ply, txt, teamchat, dead )
	if ( table.Count( evolve.ranks ) > 0 and GAMEMODE.IsSandboxDerived ) then
		local tab = {}

		if ( dead ) then
			table.insert( tab, Color( 255, 30, 40 ) )
			table.insert( tab, "*DEAD* " )
		end

		if ( teamchat ) then
			table.insert( tab, Color( 30, 160, 40 ) )
			table.insert( tab, "(TEAM) " )
		end

		if ( LocalPlayer():EV_HasPrivilege( "See chat tags" ) and ply:EV_GetRank() != "guest" ) then
			table.insert( tab, color_white )
			table.insert( tab, "(" .. evolve.ranks[ ply:EV_GetRank() ].Title .. ") " )
		end

		if ( IsValid( ply ) ) then
			table.insert( tab, evolve.ranks[ ply:EV_GetRank() ].Color or team.GetColor( ply:Team() ) )
			table.insert( tab, ply:Nick() )
		else
			table.insert( tab, "Console" )
		end

		table.insert( tab, Color( 255, 255, 255 ) )
		table.insert( tab, ": " .. txt )

		chat.AddText( unpack( tab ) )

		return true
	end
end

evolve:RegisterPlugin( PLUGIN )