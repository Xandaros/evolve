/*-------------------------------------------------------------------------------------------------------------------------
	Tab with ban management
-------------------------------------------------------------------------------------------------------------------------*/

local TAB = {}
TAB.Title = "Bans"
TAB.Description = "Manage bans."
TAB.Icon = "gui/silkicons/exclamation"
TAB.Author = "Overv"
TAB.Width = 520
TAB.Privileges = { "Ban menu" }

function TAB:Initialize( pnl )
	self.BanList = vgui.Create( "DListView", pnl )
	self.BanList:SetSize( self.Width, pnl:GetParent():GetTall() - 58 )
	self.BanList:SetMultiSelect( false )
	self.BanList:AddColumn( "Name" ):SetFixedWidth( 100 )
	self.BanList:AddColumn( "SteamID" ):SetFixedWidth( 125 )
	self.BanList:AddColumn( "Reason" ):SetFixedWidth( 150 )
	self.BanList:AddColumn( "Time left" ):SetFixedWidth( 75 )
	self.BanList:AddColumn( "Banned by" ):SetFixedWidth( 70 )
	
	self.ButUnban = vgui.Create( "EvolveButton", pnl )
	self.ButUnban:SetSize( 80, 22 )
	self.ButUnban:SetPos( self.Width - 80, pnl:GetParent():GetTall() - 53 )
	self.ButUnban:SetButtonText( "Unban" )
	self.ButUnban:SetNotHighlightedColor( 50 )
	self.ButUnban:SetHighlightedColor( 90 )
	self.ButUnban.DoClick = function()
		if ( #self.BanList:GetLines() > 0 ) then
			local steamid = self.BanList:GetSelected()[1]:GetValue( 2 )
			RunConsoleCommand( "ev", "unban", steamid )
		end
	end
	
	self.ButTime = vgui.Create( "EvolveButton", pnl )
	self.ButTime:SetSize( 60, 22 )
	self.ButTime:SetPos( self.Width - 145, pnl:GetParent():GetTall() - 53 )
	self.ButTime:SetButtonText( "Time..." )
	self.ButTime.DoClick = function()
		if ( #self.BanList:GetLines() > 0 ) then
			local steamid = self.BanList:GetSelected()[1]:GetValue( 2 )
			local reason = self.BanList:GetSelected()[1]:GetValue( 3 )
			Derma_StringRequest( "Change the length of a ban", "Enter the remaining duration of the ban of " .. self.BanList:GetSelected()[1]:GetValue( 1 ) .. " in minutes:", "", function( time )
				if ( tonumber( time ) ) then
					RunConsoleCommand( "ev", "ban", steamid, time, reason )
				end
			end )
		end
	end
end

local function lineRightClick( line )
	local menu = DermaMenu()
	menu:AddOption( "Copy SteamID", function()
		SetClipboardText( line:GetValue( 2 ) )
	end )
	menu:Open()
end

function TAB:EV_BanAdded( id )
	local entry = evolve.bans[id]
	
	for _, line in ipairs( self.BanList:GetLines() ) do
		if ( line:GetValue( 2 ) == entry.SteamID ) then
			line:SetColumnText( 1, entry.Nick )
			line:SetColumnText( 3, entry.Reason )
			line:SetColumnText( 4, evolve:FormatTime( entry.End - os.time() ) )
			line:SetColumnText( 5, entry.Admin )
			return
		end
	end
	
	local line = self.BanList:AddLine( entry.Nick, entry.SteamID, entry.Reason, evolve:FormatTime( entry.End - os.time() ), entry.Admin )
	line.OnRightClick = lineRightClick
end

function TAB:EV_BanRemoved( id )
	for i, line in ipairs( self.BanList:GetLines() ) do
		if ( line:GetValue( 2 ) == evolve.bans[ id ].SteamID ) then
			self.BanList:RemoveLine( i )
			break
		end
	end
end

function TAB:Update()
	self.BanList:Clear()
	for _, entry in pairs( evolve.bans ) do
		if ( entry.End - os.time() > 0 or entry.End == 0 ) then
			local line = self.BanList:AddLine( entry.Nick, entry.SteamID, entry.Reason, evolve:FormatTime( entry.End - os.time() ), entry.Admin )
			line.OnRightClick = lineRightClick
		end
	end
	self.BanList:SelectFirstItem()
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Ban menu" )
end

evolve:RegisterTab( TAB )