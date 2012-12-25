/*-------------------------------------------------------------------------------------------------------------------------
	Display player names above heads
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Player Names"
PLUGIN.Description = "Displays player names above heads."
PLUGIN.Author = "Overv"
PLUGIN.Privileges = { "Player names" }

if ( SERVER ) then
	resource.AddFile( "materials/gui/silkicons/comments.vtf" )
	resource.AddFile( "materials/gui/silkicons/comments.vmt" )
	resource.AddFile( "materials/gui/silkicons/user_add.vtf" )
	resource.AddFile( "materials/gui/silkicons/user_add.vmt" )
	resource.AddFile( "materials/gui/silkicons/shield_add.vtf" )
	resource.AddFile( "materials/gui/silkicons/shield_add.vmt" )
	resource.AddFile( "materials/gui/silkicons/key.vtf" )
	resource.AddFile( "materials/gui/silkicons/key.vmt" )
	
	concommand.Add( "EV_SetChatState", function( ply, cmd, args )
		if ( tonumber( args[1] ) ) then
			ply:SetNWBool( "EV_Chatting", tonumber( args[1] ) > 0 )
		end
	end )
	
	function PLUGIN:PlayerSpawn( ply ) ply.EV_AFKTimer = CurTime() end
	function PLUGIN:KeyPress( ply ) ply.EV_AFKTimer = CurTime() end
	function PLUGIN:PlayerSay( ply ) ply.EV_AFKTimer = CurTime() end
	function PLUGIN:Think()
		if ( self.NextAFKCheck and self.NextAFKCheck > CurTime() ) then return end
		self.NextAFKCheck = CurTime() + 1
		
		for _, ply in ipairs( player.GetAll() ) do
			if ( ply:EyeAngles() != ply.EV_AFKAngles ) then
				ply.EV_AFKTimer = CurTime()
				ply.EV_AFKAngles = ply:EyeAngles()
			end
			
			local b = ply.EV_AFKTimer < CurTime() - 300
			if ( ply:GetNWBool( "EV_AFK" ) != b ) then
				ply:SetNWBool( "EV_AFK", b )
			end
		end
	end
else
	PLUGIN.iconUser = surface.GetTextureID( "gui/silkicons/user" )
	PLUGIN.iconChat = surface.GetTextureID( "gui/silkicons/comments" )
	PLUGIN.iconDeveloper = surface.GetTextureID( "gui/silkicons/emoticon_smile" )
	PLUGIN.iconAFK = surface.GetTextureID( "gui/silkicons/arrow_refresh" )

	function PLUGIN:HUDPaint()
		if ( !evolve.installed or !LocalPlayer():EV_HasPrivilege( "Player names" ) or ( GAMEMODE.IsSandboxDerived ) ) then return end
		
		for _, pl in ipairs( player.GetAll() ) do
			if ( pl != LocalPlayer() and pl:Health() > 0 ) then
				local visible = hook.Call( "EV_ShowPlayerName", nil, pl )
				
				if ( visible != false ) then				
					local td = {}
					td.start = LocalPlayer():GetShootPos()
					td.endpos = pl:GetShootPos()
					local trace = util.TraceLine( td )
					
					if ( !trace.HitWorld ) then				
						surface.SetFont( "DefaultBold" )
						local w = surface.GetTextSize( pl:Nick() ) + 32
						local h = 24
						
						local pos = pl:GetShootPos()
						local bone = pl:LookupBone( "ValveBiped.Bip01_Head1" )
						if ( bone ) then
							pos = pl:GetBonePosition( bone )
						end						
						
						local drawPos = pl:GetShootPos():ToScreen()
						local distance = LocalPlayer():GetShootPos():Distance( pos )
						drawPos.x = drawPos.x - w / 2
						drawPos.y = drawPos.y - h - 25
						
						local alpha = 255
						if ( distance > 512 ) then
							alpha = 255 - math.Clamp( ( distance - 512 ) / ( 2048 - 512 ) * 255, 0, 255 )
						end
						
						surface.SetDrawColor( 62, 62, 62, alpha )
						surface.DrawRect( drawPos.x, drawPos.y, w, h )
						surface.SetDrawColor( 129, 129, 129, alpha )
						surface.DrawOutlinedRect( drawPos.x, drawPos.y, w, h )
						
						if ( pl:GetNWBool( "EV_Chatting", false ) ) then
							surface.SetTexture( self.iconChat )
						elseif ( pl:GetNWBool( "EV_AFK", false ) ) then
							surface.SetTexture( self.iconAFK )
						elseif ( pl:SteamID() == "STEAM_0:1:11956651" ) then
								surface.SetTexture( self.iconDeveloper )
						elseif ( evolve.ranks[ pl:EV_GetRank() ] ) then
							surface.SetTexture( evolve.ranks[ pl:EV_GetRank() ].IconTexture )
						else
							surface.SetTexture( self.iconUser )
						end
						
						surface.SetDrawColor( 255, 255, 255, math.Clamp( alpha * 2, 0, 255 ) )
						surface.DrawTexturedRect( drawPos.x + 5, drawPos.y + 5, 14, 14 )
						
						local col = evolve.ranks[ pl:EV_GetRank() ].Color or team.GetColor( pl:Team() )
						col.a = math.Clamp( alpha * 2, 0, 255 )
						draw.DrawText( pl:Nick(), "DefaultBold", drawPos.x + 28, drawPos.y + 5, col, 0 )
					end
				end
			end
		end
	end

	function PLUGIN:StartChat()
		self.ChatboxOpen = true
		RunConsoleCommand( "EV_SetChatState", 1 )
	end
	
	function PLUGIN:FinishChat()
		if ( self.ChatboxOpen ) then
			RunConsoleCommand( "EV_SetChatState", 0 )
			self.ChatboxOpen = false
		end
	end
end

evolve:RegisterPlugin( PLUGIN )