/*-------------------------------------------------------------------------------------------------------------------------
	Tab with rank management
-------------------------------------------------------------------------------------------------------------------------*/

local TAB = {}
TAB.Title = "Ranks"
TAB.Description = "Manage ranks."
TAB.Icon = "icon16/user.png"
TAB.Author = "Overv, MadDog, General Wrex, Mors Quaedam" -- Colour changer fix by Mors Quaedam
TAB.Width = 680
TAB.Privileges = { "Rank menu" }
TAB.AllToggle = true // This determines if the second privilege list column toggles all privileges on or off
TAB.Sort = 1

function TAB:Initialize( pnl )
	// Create the rank list
	self.RankList = vgui.Create( "DListView", pnl )
	self.RankList:SetPos( 0, 0 )
	self.RankList:SetSize( 340, 125 ) --self.Width,125
	self.RankList:SetMultiSelect( false )
	self.RankList:AddColumn("Ranks")
	//self.RankList:SetDataHeight( 20 )
	self.RankList.Think = function()
		if ( self.LastRank != self.RankList:GetSelected()[1].Rank ) then self.LastRank = self.RankList:GetSelected()[1].Rank else return end
		
		self.AllToggle = true

		self.Immunity:SetVisible( self.LastRank != "owner" )
		self.Usergroup:SetVisible( self.LastRank != "owner" )
		self.PrivList:SetVisible( self.LastRank != "owner" )
		self.RemoveButton:SetVisible( self.LastRank != "owner" )
		self.PrivFilter:SetVisible( self.LastRank != "owner" )

		if ( self.LastRank == "owner" ) then
			self.PropertyContainer:SetSize( 340, pnl:GetParent():GetTall() - 208 )
			self.ColourContainer:SetSize( 340, 470 )
			self.ColorPicker:SetSize( 325,440 )
			self.RenameButton:SetPos( self.Width - self.RenameButton:GetWide(), pnl:GetParent():GetTall() - 58 )
		else
			self.PropertyContainer:SetSize( 340, 74 )
			self.ColourContainer:SetSize( 340, 470 )
			self.ColorPicker:SetSize( 325,440 )
			self.RenameButton:SetPos( self.Width - self.RenameButton:GetWide() - self.NewButton:GetWide() - 5, pnl:GetParent():GetTall() - 58 )
		end

		self.ColorPicker:SetColor( evolve.ranks[ self.LastRank ].Color or color_white )
		self.Immunity:SetValue( evolve.ranks[ self.LastRank ].Immunity or 0 )
		self.Usergroup:SetText( evolve.ranks[ self.LastRank ].UserGroup or "unknown" )
		self.Usergroup.Selected = evolve.ranks[ self.LastRank ].UserGroup or "unknown"
	end

	// Create the privilege filter
	self.PrivFilter = vgui.Create( "DComboBox", pnl )
	self.PrivFilter:SetPos( 0, self.RankList:GetTall() + 84 )
	self.PrivFilter:SetSize( 340-20, 20 )
	--self.PrivFilter:SetEditable( false )
	self.PrivFilter:AddChoice( "Privileges" )
	self.PrivFilter:AddChoice( "Weapons" )
	self.PrivFilter:AddChoice( "Entities" )
	self.PrivFilter:AddChoice( "Tools" )
	self.PrivFilter:ChooseOptionID( 1 )
	self.PrivFilter.OnSelect = function( id, value, data )
		self.AllToggle = true
	
		self.PrivFilter.Selected = data
		self:UpdatePrivileges()
	end

	// Create the privilege list
	self.PrivList = vgui.Create( "DListView", pnl )
	self.PrivList:SetPos( 0, self.RankList:GetTall() + 84 + 20 + 5 )
	self.PrivList:SetSize( 340-10, pnl:GetParent():GetTall() - 267 - 20 - 5 )
	local col = self.PrivList:AddColumn( "Privilege" )
	col:SetFixedWidth( 340 * 0.8 )

	// Make the privilege enabled column toggle all on/all off
	col = self.PrivList:AddColumn( "" )
	col.DoClick = function()
		local filter
		if ( self.PrivFilter.Selected == "Weapons" ) then filter = "@"
		elseif ( self.PrivFilter.Selected == "Entities" ) then filter = ":"
		elseif ( self.PrivFilter.Selected == "Tools" ) then filter = "#"
		end
		
		RunConsoleCommand( "ev_setrank", self.RankList:GetSelected()[1].Rank, self.AllToggle and 1 or 0, filter )
		self.AllToggle = !self.AllToggle
	end

	self.PropertyContainer = vgui.Create( "DPanelList", pnl )
	self.PropertyContainer:SetPos( 0, 130 )
	self.PropertyContainer:SetSize( 340, 74 )	
	
	self.ColourContainer = vgui.Create( "DPanelList", pnl )
	self.ColourContainer:SetPos( 345, 0 )
	self.ColourContainer:SetSize( 340, 470 )

	// Rank color
	self.ColorPicker = vgui.Create( "DColorMixer", self.ColourContainer) --.PropertyContainer
	self.ColorPicker:SetPos( 5, 5 )
	self.ColorPicker:SetSize( 325, 440 )
	--self.ColorPicker.HSV.OldRelease = self.ColorPicker.HSV.OnMouseReleased
	self.ColorPicker.Think = function( mcode )
		if ( input.IsMouseDown( MOUSE_LEFT ) ) then
			self.ApplySettings = true
		elseif (!input.IsMouseDown( MOUSE_LEFT ) and self.ApplySettings) then
			self.ApplySettings = false
			local color = self.ColorPicker:GetColor()
			RunConsoleCommand( "ev_setrankp", self.RankList:GetSelected()[1].Rank, self.Immunity:GetValue(), self.Usergroup.Selected, color.r, color.g, color.b )
			self.ColorPicker:SetColor(color)
		end
	end
	self.ColorPicker:SetColor( color_white )

	// Immunity
	self.Immunity = vgui.Create( "DNumSlider", self.PropertyContainer )
	self.Immunity:SetPos( 84, 5 )
	self.Immunity:SetWide( 340 - 92 )
	self.Immunity:SetDecimals( 0 )
	self.Immunity:SetMin( 0 )
	self.Immunity:SetMax( 99 )
	self.Immunity:SetText( "Immunity" )
	self.Immunity.Think = function()
		if ( input.IsMouseDown( MOUSE_LEFT ) ) then
			self.applySettings = true
		elseif ( !input.IsMouseDown( MOUSE_LEFT ) and self.applySettings ) then
			local rank = self.RankList:GetSelected()[1].Rank
			if ( evolve.ranks[ rank ].Immunity != self.Immunity:GetValue() ) then
				local color = self.ColorPicker:GetColor()
				RunConsoleCommand( "ev_setrankp", self.RankList:GetSelected()[1].Rank, self.Immunity:GetValue(), self.Usergroup.Selected, color.r, color.g, color.b )
			end
			self.applySettings = false
		end
	end

	// User group
	self.Usergroup = vgui.Create( "DComboBox", self.PropertyContainer )
	self.Usergroup:SetPos( 80, 49 )
	self.Usergroup:SetSize( 340 - 89, 20 )
	--self.Usergroup:SetEditable( false )
	self.Usergroup:AddChoice( "guest" )
	self.Usergroup:AddChoice( "admin" )
	self.Usergroup:AddChoice( "superadmin" )
	self.Usergroup:ChooseOptionID( 1 )
	self.Usergroup.OnSelect = function( id, value, data )
		self.Usergroup.Selected = data
		local color = self.ColorPicker:GetColor()
		RunConsoleCommand( "ev_setrankp", self.RankList:GetSelected()[1].Rank, self.Immunity:GetValue(), data, color.r, color.g, color.b )
	end

	// SelectAll
	self.SelectAllButton = vgui.Create( "EvolveButton", pnl )
	self.SelectAllButton:SetPos( 340 - 260, pnl:GetParent():GetTall() - 58 )
	self.SelectAllButton:SetSize( 100, 22 )
	self.SelectAllButton:SetButtonText( "Mode: Select One" )
	self.SelectAllButton:SetNotHighlightedColor( 50 )
	self.SelectAllButton:SetHighlightedColor( 90 )
	self.SelectAllButton.DoClick = function()
		if(self.SelectAllButton:GetButtonText() == "Mode: Select All") then
			self.SelectAllButton:SetButtonText("Mode: Select One")
		else
			self.SelectAllButton:SetButtonText("Mode: Select All")
		end
	end
	// New button
	self.NewButton = vgui.Create( "EvolveButton", pnl )
	self.NewButton:SetPos( 0, pnl:GetParent():GetTall() - 58 )
	self.NewButton:SetSize( 60, 22 )
	self.NewButton:SetButtonText( "New" )
	self.NewButton:SetNotHighlightedColor( 50 )
	self.NewButton:SetHighlightedColor( 90 )
	self.NewButton.DoClick = function()
		Derma_StringRequest( "Create a rank", "Enter the title of your rank (e.g. Noob):", "", function( title )
			Derma_StringRequest( "Create a rank", "Enter the id of your rank (e.g. noob):", string.gsub( string.lower( title ), " ", "" ), function( id )
				if ( string.find( id, " " ) or string.lower( id ) != id or evolve.ranks[ id ] ) then
					chat.AddText( evolve.colors.red, "You specified an invalid identifier. Make sure it doesn't exist yet and does not contain spaces or capitalized characters." )
				else
					local curRank = self.RankList:GetSelected()[1].Rank
					Derma_Query( "Do you want to derive the settings and privileges of the currently selected rank, " .. evolve.ranks[ curRank ].Title .. "?", "Rank inheritance",
					
						"Yes",
						function()
							RunConsoleCommand( "ev_createrank", id, title, curRank )
						end,
						
						"No",
						function()
							RunConsoleCommand( "ev_createrank", id, title )
						end
					)
				end
			end )
		end )
	end

	// Remove button
	self.RemoveButton = vgui.Create( "EvolveButton", pnl )
	self.RemoveButton:SetPos( 340 - 60, pnl:GetParent():GetTall() - 58 )
	self.RemoveButton:SetSize( 60, 22 )
	self.RemoveButton:SetButtonText( "Remove" )
	self.RemoveButton.DoClick = function()
		local id = self.RankList:GetSelected()[1].Rank
		local rank = evolve.ranks[ id ].Title

		if ( id == "guest" ) then
			Derma_Message( "You can't remove the guest rank.", "Removing rank guest", "Ok" )
		else
			Derma_Query( "Are you sure you want to remove the rank " .. rank .. "?", "Removing rank " .. rank, "Yes", function() RunConsoleCommand( "ev_Removerank", id ) end, "No", function() end )
		end
	end

	// Rename button
	self.RenameButton = vgui.Create( "EvolveButton", pnl )
	self.RenameButton:SetPos( 340 - self.RemoveButton:GetWide() - 27, pnl:GetParent():GetTall() - 58 )
	self.RenameButton:SetSize( 60, 22 )
	self.RenameButton:SetButtonText( "Rename" )
	self.RenameButton.DoClick = function()
			local rank = self.RankList:GetSelected()[1].Rank
			Derma_StringRequest( "Rename rank " .. evolve.ranks[ rank ].Title, "Enter a new name:", evolve.ranks[ rank ].Title, function( name )
				RunConsoleCommand( "ev_Renamerank", rank, name )
			end )
	end

	self.ColorPicker:SetColor( evolve.ranks.guest.Color or color_white )
	self.Immunity:SetValue( evolve.ranks.guest.Immunity or 0 )
	self.Usergroup:SetText( evolve.ranks.guest.UserGroup or "unknown" )
	self.Usergroup.Selected = evolve.ranks.guest.UserGroup or "unknown"
end

TAB.HL2Weps = {
	weapon_crowbar = "Crowbar",
	weapon_pistol = "Pistol",
	weapon_smg1 = "SMG",
	weapon_frag = "Frag grenade",
	weapon_physcannon = "Gravity gun",
	weapon_crossbow = "Crossbow",
	weapon_shotgun = "Shotgun",
	weapon_357 = ".357",
	weapon_rpg = "RPG",
	weapon_ar2 = "AR2",
	weapon_physgun = "Physgun",
}

TAB.SEnts = {
	grenade_helicopter = "Helicopter Grenade",
	prop_thumper = "Combine Thumper",
}

function TAB:PrintNameByClass( class )
	if ( self.HL2Weps[ class ] ) then
		return self.HL2Weps[ class ]
	else
		for _, wep in ipairs( weapons.GetList() ) do
			if ( wep.ClassName == class ) then
				return wep.PrintName or class
			end
		end

		for c, ent in pairs( scripted_ents.GetList() ) do
			if ( c == class ) then
				return ent.t.PrintName or class
			end
		end
		
		for _, val in ipairs( file.Find( "entities/weapons/gmod_tool/stools/*.lua", "LUA" )  ) do
			local _, __, c = string.find( val, "([%w_]*).lua" )

			if ( c == class ) then
				// Load the tool to find the name
				TOOL = {}
				include( "../" .. GAMEMODE.Folder .. "/entities/weapons/gmod_tool/stools/" .. val )

				local name = TOOL.Name
				TOOL = nil

				return name or class
			end
		end

		return class
	end
end

function TAB:UpdatePrivileges()
	self.PrivList:Clear()
	for _, privilege in ipairs( evolve.privileges ) do
		// Get first character to determine what kind of privilege this is.
		local prefix = string.Left( privilege, 1 )

		if ( ( prefix == "@" and self.PrivFilter.Selected == "Weapons" ) or ( prefix == ":" and self.PrivFilter.Selected == "Entities" ) or ( prefix == "#" and self.PrivFilter.Selected == "Tools" ) or ( !string.match( prefix, "[@:#]" ) and ( self.PrivFilter.Selected or "Privileges" ) == "Privileges" ) ) then
			local line
			if ( string.match( prefix, "[@:]" ) ) then
				line = self.PrivList:AddLine( self:PrintNameByClass( string.sub( privilege, 2 ) ), "" )
			else
				line = self.PrivList:AddLine( privilege, "" )
			end
			line.Privilege = privilege

			line.State = vgui.Create( "DImage", line )
			line.State:SetImage( "icon16/accept.png" )
			line.State:SetSize( 16, 16 )
			line.State:SetPos( 340 * 0.875 - 12, 1 )
			
			line.Think = function()
				if ( line.LastRank != self.RankList:GetSelected()[1].Rank ) then line.LastRank = self.RankList:GetSelected()[1].Rank else return end
				
				line.State:SetVisible( line.LastRank == "owner" or table.HasValue( evolve.ranks[ line.LastRank ].Privileges, privilege ) )
			end

			line.OnPress = line.OnMousePressed
			line.LastPress = os.clock()
			line.OnMousePressed = function( )
				if self.SelectAllButton:GetButtonText() == "Mode: Select One" then
					if ( line.LastPress + 0.3 > os.clock() and LocalPlayer():EV_HasPrivilege( "Rank modification" ) ) then
						if ( line.State:IsVisible() ) then
							RunConsoleCommand( "ev_setrank", line.LastRank, privilege, 0 )
						else
							RunConsoleCommand( "ev_setrank", line.LastRank, privilege, 1 )
						end

						line.State:SetVisible( !line.State:IsVisible() )
					end
				else
					if ( line.LastPress + 0.3 > os.clock() and LocalPlayer():EV_HasPrivilege( "Rank modification" ) ) then
						for _, privilege in ipairs( evolve.privileges ) do
							local entprefix = string.Left( privilege, 1 )

							if ( ( entprefix == "@" and self.PrivFilter.Selected == "Weapons" ) or ( entprefix == ":" and self.PrivFilter.Selected == "Entities" ) or ( entprefix == "#" and self.PrivFilter.Selected == "Tools" ) or ( !string.match( entprefix, "[@:#]" ) and ( self.PrivFilter.Selected or "Privileges" ) == "Privileges" ) ) then
								if line.State:IsVisible() then
									RunConsoleCommand( "ev_setrank", line.LastRank, privilege, 0 )
								else
									RunConsoleCommand( "ev_setrank", line.LastRank, privilege, 1 )
								end
							end
						end
					end
				end
				line.LastPress = os.clock()
				line:OnPress()
			end
		end
	end
	self.PrivList:SortByColumn( 1 )
	self.PrivList:SelectFirstItem()
end

function TAB:Update()
	// Sort ranks by immunity
	local ranks = {}
	for id, rank in pairs( evolve.ranks ) do
		table.insert( ranks, { ID = id, Icon = rank.Icon, Title = rank.Title, Immunity = rank.Immunity } )
	end
	table.SortByMember( ranks, "Immunity" )
	
	if ( #self.RankList:GetLines() == 0 ) then
		self.RankList:Clear()
		for _, rank in ipairs( ranks ) do
			local item = self.RankList:AddLine( "" )
			item.Rank = rank.ID

			item.Icon = vgui.Create( "DImage", item )
			item.Icon:SetImage( "icon16/" .. rank.Icon ..".png" )
			item.Icon:SetPos( 4, 2 )
			item.Icon:SetSize( 14, 14 )
			item.PaintOver = function()
				draw.SimpleText( rank.Title, "DermaDefault", 28, 2, Color( 0, 0, 0, 255 ) )
			end

			if ( _ % 2 == 1 ) then
			--	item:SetAltLine( true )
			end
		end
		self.RankList:SelectItem( self.RankList:GetLines()[#self.RankList:GetLines()] )
	end
	
	self:UpdatePrivileges()
end

function TAB:EV_RankRemoved( rank )
	for _, rankitem in pairs( self.RankList:GetLines() ) do
		if ( rankitem.Rank == rank ) then
			self.RankList:RemoveLine( rankitem:GetID() )
			break
		end
	end
	
	self.RankList:SelectItem( self.RankList:GetLines()[1] )
	self.LastRank = "owner"
end

function TAB:EV_RankRenamed( rank, title )
	for _, rankitem in pairs( self.RankList:GetLines() ) do
		if ( rankitem.Rank == rank ) then
			rankitem.PaintOver = function()
				draw.SimpleText( title, "DermaDefault", 28, 2, Color( 0, 0, 0, 255 ) )
			end

			break
		end
	end
end

		

function TAB:EV_RankPrivilegeChange( rank, privilege, enabled )
	if ( rank == self.RankList:GetSelected()[1].Rank ) then
		for _, line in pairs( self.PrivList:GetLines() ) do
			if ( line.Privilege == privilege ) then
				line.State:SetVisible( enabled )
				break
			end
		end
	end
end

function TAB:EV_RankCreated( id )
	local rank = evolve.ranks[ id ]
	local item = self.RankList:AddLine( "" )
	
	//item:SetTall( 20 )
	item.Rank = id

	item.Icon = vgui.Create( "DImage", item )
	item.Icon:SetImage( "icon16/" .. rank.Icon ..".png" )
	item.Icon:SetPos( 4, 2 )
	item.Icon:SetSize( 14, 14 )
	item.PaintOver = function()
		draw.SimpleText( rank.Title, "DermaDefault", 28, 5, Color( 0, 0, 0, 255 ) )
	end
end

function TAB:EV_RankUpdated( id )
	if ( id == self.RankList:GetSelected()[1].Rank ) then
		self.ColorPicker:SetColor( evolve.ranks[ id ].Color or color_white )
		self.Immunity:SetValue( evolve.ranks[ id ].Immunity or 0 )
		self.Usergroup:SetText( evolve.ranks[ id ].UserGroup or "unknown" )
		self.Usergroup.Selected = evolve.ranks[ id ].UserGroup or "unknown"
	end
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Rank menu" )
end

evolve:RegisterTab( TAB )
