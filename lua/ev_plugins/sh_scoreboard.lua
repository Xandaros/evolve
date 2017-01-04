/*-------------------------------------------------------------------------------------------------------------------------
	TKZ Custom Scoreboard - ONLY FOR USE ON TheKillzone SERVERS
-------------------------------------------------------------------------------------------------------------------------*/

resource.AddFile( "materials/gui_tkz/scoreboard_header.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_header.vmt" )
resource.AddFile( "materials/gui_tkz/scoreboard_middle.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_middle.vmt" )
resource.AddFile( "materials/gui_tkz/scoreboard_bottom.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_bottom.vmt" )
resource.AddFile( "materials/gui_tkz/scoreboard_ping.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_ping.vmt" )
resource.AddFile( "materials/gui_tkz/scoreboard_frags.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_frags.vmt" )
resource.AddFile( "materials/gui_tkz/scoreboard_skull.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_skull.vmt" )
resource.AddFile( "materials/gui_tkz/scoreboard_playtime.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_playtime.vmt" )
resource.AddFile( "materials/gui_tkz/scoreboard_propbrick.vtf" )
resource.AddFile( "materials/gui_tkz/scoreboard_propbrick.vmt" )

local PLUGIN = {}
PLUGIN.Title = "TKZ Scoreboard"
PLUGIN.Description = "TKZ Custom Scoreboard."
PLUGIN.Author = "Overv, bellum128"

if ( CLIENT ) then
	PLUGIN.TexHeader = surface.GetTextureID( "gui_tkz/scoreboard_header" )
	PLUGIN.TexMiddle = surface.GetTextureID( "gui_tkz/scoreboard_middle" )
	PLUGIN.TexBottom = surface.GetTextureID( "gui_tkz/scoreboard_bottom" )
	PLUGIN.TexPing = surface.GetTextureID( "gui_tkz/scoreboard_ping" )
	PLUGIN.TexFrags = surface.GetTextureID( "gui_tkz/scoreboard_frags" )
	PLUGIN.TexDeaths = surface.GetTextureID( "gui_tkz/scoreboard_skull" )
	PLUGIN.TexPlaytime = surface.GetTextureID( "gui_tkz/scoreboard_playtime" )
	PLUGIN.TexProps = surface.GetTextureID( "gui_tkz/scoreboard_propbrick" )
	
	PLUGIN.Width = 687
	
	surface.CreateFont("EvolveScoreboardHeader", {
		font = "coolvertica",
		size = 22,
		weight = 400,
		antialias = true,
		additive = false,
	})
	
	surface.CreateFont( "ScoreboardText", {
		font = "coolvertica",
		size = 12,
		weight = 500,
		antialias = true,
		additive = false
	})
end

if SERVER then
	timer.Simple(1, function()
		PLUGIN.GetCount = _R.Player.GetCount
		function _R.Player:GetCount(limit, minus)
			if limit == "props" then
				timer.Simple(.1, function() PLUGIN.GetCount(self, limit, 0) end)
			end
			return PLUGIN.GetCount(self, limit, minus)
		end
	end)
end

function PLUGIN:ScoreboardShow()
	if ( GAMEMODE.IsSandboxDerived and evolve.installed ) then
		self.DrawScoreboard = true
		return true
	end
end

function PLUGIN:ScoreboardHide()
	if ( self.DrawScoreboard ) then
		self.DrawScoreboard = false
		return true
	end
end

function PLUGIN:DrawTexturedRect( tex, x, y, w, h )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( tex )
	surface.DrawTexturedRect( x, y, w, h )
end

function PLUGIN:QuickTextSize( font, text )
	surface.SetFont( font )
	return surface.GetTextSize( text )
end

function PLUGIN:FormatTime( raw )
	if ( raw < 60 ) then
		return math.floor( raw ) .. " secs"
	elseif ( raw < 3600 ) then
		if ( raw < 120 ) then return "1 min" else return math.floor( raw / 60 ) .. " mins" end
	elseif ( raw < 3600*24 ) then
		if ( raw < 7200 ) then return "1 hour" else return math.floor( raw / 3600 ) .. " hours" end
	else
		if ( raw < 3600*48 ) then return "1 day" else return math.floor( raw / 3600 / 24 ) .. " days" end
	end
end

function PLUGIN:DrawInfoBar()
	// Background
	self.Y = self.Y + 10
	surface.SetDrawColor( 192, 220, 221, 255 )
	surface.DrawRect( self.X + 15, self.Y + 120, self.Width - 30, 18 )
	
	surface.SetDrawColor( 198, 212, 213, 255 )
	surface.DrawOutlinedRect( self.X + 15, self.Y + 120, self.Width - 30, 18 )
	
	// Content
	local x = self.X + 24
	local y = self.Y + 122
	draw.SimpleText( "Currently playing ", "Default", x, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	x = x + self:QuickTextSize( "Default", "Currently playing " )
	draw.SimpleText( GAMEMODE.Name, "DefaultBold", x, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	x = x + self:QuickTextSize( "DefaultBold", GAMEMODE.Name )
	draw.SimpleText( " on the map ", "Default", x, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	x = x + self:QuickTextSize( "Default", " on the map " )
	draw.SimpleText( game.GetMap(), "DefaultBold", x, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	x = x + self:QuickTextSize( "DefaultBold", game.GetMap() )
	draw.SimpleText( ", with ", "Default", x, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	x = x + self:QuickTextSize( "Default", ", with " )
	draw.SimpleText( #player.GetAll(), "DefaultBold", x, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	x = x + self:QuickTextSize( "DefaultBold", #player.GetAll() )
	local s = ""
	if ( #player.GetAll() > 1 ) then s = "s" end
	draw.SimpleText( " player" .. s .. ".", "Default", x, y, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	self.Y = self.Y - 10
end

function PLUGIN:DrawUsergroup( playerinfo, usergroup, title, icon, y )
	local playersFound = false
	for _, pl in ipairs( playerinfo ) do
		if ( pl.Usergroup == usergroup ) then
			playersFound = true
			break
		end
	end
	if ( !playersFound ) then return y end
	
	surface.SetDrawColor( 198, 212, 213, 255 )
	surface.DrawRect( self.X + 7, y, self.Width - 14, 22 )
	surface.SetMaterial( icon )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( self.X + 15, y + 4, 14, 14 )
	draw.SimpleText( title, "DefaultBold", self.X + 40, y + 4, Color( 39, 39, 39, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
	self:DrawTexturedRect( self.TexPing, self.X + self.Width - 50, y + 4, 14, 14 )
	self:DrawTexturedRect( self.TexPlaytime, self.X + self.Width - 100,  y + 4, 14, 14 )
	self:DrawTexturedRect( self.TexDeaths, self.X + self.Width - 150.5, y + 4, 14, 14 )
	self:DrawTexturedRect( self.TexFrags, self.X + self.Width - 190.5,  y + 4, 14, 14 )
	self:DrawTexturedRect( self.TexProps, self.X + self.Width - 230.5,  y + 4, 14, 14 )
	
	y = y + 26
	
	for _, pl in ipairs( playerinfo ) do
		if ( pl.Usergroup == usergroup ) then
			draw.SimpleText( pl.Nick, "ScoreboardText", self.X + 40, y, Color( 39, 39, 39, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( pl.Frags, "ScoreboardText", self.X + self.Width - 187, y, Color( 39, 39, 39, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( pl.Deaths, "ScoreboardText", self.X + self.Width - 147, y, Color( 39, 39, 39, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( pl.Ping, "ScoreboardText", self.X + self.Width - 50, y, Color( 39, 39, 39, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( pl.Propcount, "ScoreboardText", self.X + self.Width - 223, y, Color( 39, 39, 39, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			draw.SimpleText( self:FormatTime( pl.PlayTime ), "ScoreboardText", self.X + self.Width - 92, y, Color( 39, 39, 39, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			
			y = y + 20
		end
	end
	
	return y
end

function PLUGIN:DrawPlayers()
	local playerInfo = {}
	for _, v in pairs( player.GetAll() ) do
		table.insert( playerInfo, { Nick = v:Nick(), Usergroup = v:EV_GetRank(), Frags = v:Frags(), Deaths = v:Deaths(), Ping = v:Ping(), PlayTime = evolve:Time() - v:GetNWInt( "EV_JoinTime" ) + v:GetNWInt( "EV_PlayTime" )
		, Propcount = v:GetNetworkedInt("Count.props") or 0
		} )
	end
	table.SortByMember( playerInfo, "Frags" )
	
	local y = self.Y + 155
	
	local sortedRanks = {}
	for id, rank in pairs( evolve.ranks ) do
		table.insert( sortedRanks, { ID = id, Title = rank.Title, Immunity = rank.Immunity, Icon = rank.IconTexture } )
	end
	table.SortByMember( sortedRanks, "Immunity" )
	
	for _, rank in ipairs( sortedRanks ) do
		if( string.Right( rank.Title, 2 ) != "ed" ) then
			y = self:DrawUsergroup( playerInfo, rank.ID, rank.Title .. "s", rank.Icon, y )
		else
			y = self:DrawUsergroup( playerInfo, rank.ID, rank.Title, rank.Icon, y )
		end
	end
	
	return y
end

function PLUGIN:HUDDrawScoreBoard()
	if ( !self.DrawScoreboard ) then return end
	if ( !self.Height ) then self.Height = 139 end
	
	// Update position
	self.X = ScrW() / 2 - self.Width / 2
	self.Y = ScrH() / 2 - ( self.Height ) / 2
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	surface.SetTexture( self.TexHeader )
	surface.DrawTexturedRect( self.X, self.Y, self.Width, 122 )
	draw.SimpleText( GetHostName(), "EvolveScoreboardHeader", self.X + 133, self.Y + 51, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( GetHostName(), "EvolveScoreboardHeader", self.X + 132, self.Y + 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( self.TexMiddle )
	surface.DrawTexturedRect( self.X, self.Y + 122, self.Width, self.Height - 122 - 37 )
	surface.SetTexture( self.TexBottom )
	surface.DrawTexturedRect( self.X, self.Y + self.Height - 37, self.Width, 37 )
	
	self:DrawInfoBar()
	
	local y = self:DrawPlayers()
	
	self.Height = y - self.Y + 5
end

evolve:RegisterPlugin( PLUGIN )