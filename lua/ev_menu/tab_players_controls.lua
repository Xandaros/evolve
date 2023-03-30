/*-------------------------------------------------------------------------------------------------------------------------
	Stylish button
-------------------------------------------------------------------------------------------------------------------------*/

if ( CLIENT ) then

PANEL = {}

surface.CreateFont( "MenuItem", {
	font = "Verdana",
	size = 13,
	weight = 0,
	antialias = true,
	additive = false
})

function PANEL:Init()
	self:SetText( "" )
end

function PANEL:SetButtonText( txt )
	self.Text = txt
end

function PANEL:GetButtonText()
	return self.Text
end

function PANEL:Paint()
	local col = self.NotHighlightedColor or 81
	if ( self.Highlight ) then col = self.HighlightedColor or 120 end
	draw.RoundedBox( 2, 0, 0, self:GetWide(), self:GetTall(), Color( col, col, col, 255 ) )
	draw.SimpleText( self.Text or "", "MenuItem", self:GetWide() / 2, self:GetTall() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function PANEL:OnCursorEntered()
	self.Highlight = true
end

function PANEL:OnCursorExited()
	self.Highlight = false
end

function PANEL:SetHighlightedColor( col )
	self.HighlightedColor = col
end

function PANEL:SetNotHighlightedColor( col )
	self.NotHighlightedColor = col
end

derma.DefineControl( "EvolveButton", "Stylish menu button", PANEL, "DButton" )

/*-------------------------------------------------------------------------------------------------------------------------
	Modified combobox to show players
-------------------------------------------------------------------------------------------------------------------------*/

PANEL = {}

surface.CreateFont( "EvolvePlayerListEntry", {
	font = "coolvertica",
	size = 12,
	weight = 500,
	antialias = true,
	additive = false
})

local iconUser = surface.GetTextureID( "gui/silkicons/user" )

function PANEL:AddPlayer( ply )
	local item = self:AddLine( "" )
	
	item.Player = ply
	
	item.Avatar = vgui.Create( "AvatarImage", item )
	item.Avatar:SetPlayer( ply )
	item.Avatar:SetPos( 0, 0 )
	item.Avatar:SetSize( 17, 17 )
	
	item.PaintOver = function()
		if ( !IsValid( item.Player ) ) then
			if ( #self:GetSelected() == 0 ) then self:SelectFirstItem() end
			
			self:RemoveLine(item:GetID())
			return
		end
		
		if ( evolve.ranks[ ply:EV_GetRank() ] ) then
			surface.SetMaterial( evolve.ranks[ ply:EV_GetRank() ].IconTexture )
		else
			surface.SetMaterial( iconUser )
		end
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( item:GetWide() - 20, 0, 16, 16 )
		
		draw.SimpleText( ply:Nick() or "", "EvolvePlayerListEntry", 28, 2, Color( 0, 0, 0, 255 ) )
	end
	
	item.OnMousePressedOld = item.OnMousePressed
	item.OnMousePressed = function( self, button )
		if ( button == MOUSE_RIGHT ) then
			local menu = DermaMenu()
			menu:AddOption( "Copy SteamID", function() SetClipboardText( ply:SteamID() ) end )
			menu:Open()
		else
			return item.OnMousePressedOld( self, button )
		end
	end
	
	return item
end

function PANEL:SelectFirstItem()
	self:SelectItem( self:GetLines()[1] )
end

function PANEL:GetSelectedPlayers()
	local plys = {}
	for _, item in pairs( self:GetSelected() ) do if ( IsValid( item.Player ) ) then table.insert( plys, item.Player:Nick() ) end end
	return plys
end

function PANEL:Populate()
	local selectedPlayers = {}
	if ( #self:GetSelected() > 0 ) then
		for _, item in ipairs( self:GetSelected() ) do
			if ( IsValid( item.Player ) ) then table.insert( selectedPlayers, item.Player ) end
		end
	end
	
	self:Clear()
	
	local players = {}
	for _, pl in ipairs( player.GetAll() ) do table.insert( players, { Name = pl:Nick(), Ply = pl } ) end
	table.SortByMember( players, "Name", function( a, b ) return a > b end )
	
	for _, pl in ipairs( players ) do
		local item = self:AddPlayer( pl.Ply )
		
		item.DoClick= function( mc )
			if ( item.LastClick and os.clock() < item.LastClick + 0.3 and item.LastX == gui.MouseX() and item.LastY == gui.MouseY() ) then
				self:MoveTo( -self.Parent.Width, 0, 0.1 )
				self.Parent.PluginList:MoveTo( 0, 0, 0.1 )

				self.Parent.ButCancel:SetEnabled( true )
				self.Parent.ButCancel:AlphaTo(255, 0)
			end
			
			item.LastClick = os.clock()
			item.LastX, item.LastY = gui.MousePos()
		end
		
		if ( table.HasValue( selectedPlayers, pl.Ply ) ) then
			self:SelectItem( item )
		end
	end
	
	if ( #self:GetSelected() == 0 ) then
		self:SelectFirstItem()
	end
end

derma.DefineControl( "EvolvePlayerList", "Stylish player list", PANEL, "DListView" )

/*-------------------------------------------------------------------------------------------------------------------------
	Tool menu button
-------------------------------------------------------------------------------------------------------------------------*/

local ToolButtons = {}
local PANEL = {}

AccessorFunc( PANEL, "m_bAlt",                  "Alt" )
AccessorFunc( PANEL, "m_bSelected",     "Selected" )

function PANEL:Init()
        self:SetContentAlignment( 4 )
        self:SetTextInset( 5, 0 )
        self:SetTall( 15 )

        table.insert( ToolButtons, self )
end

function PANEL:RemoveEx()
	for k, v in pairs( ToolButtons ) do
		if ( v == self ) then
			table.remove( ToolButtons, k )
			break
		end
	end
	self:Remove()
end

function PANEL:Paint()
	if ( !self.m_bSelected ) then
		if ( !self.m_bAlt ) then return end
		surface.SetDrawColor( 255, 255, 255, 10 )
	else
		surface.SetDrawColor( 50, 150, 255, 250 )
	end
   
	self:DrawFilledRect()
end

function PANEL:OnMousePressed( mcode )
	if ( mcode == MOUSE_LEFT ) then
			self:OnSelect()
	end
end

function PANEL:OnCursorMoved( x, y )
	for _, b in pairs( ToolButtons ) do b.m_bSelected = false end
	self.m_bSelected = true
end

function PANEL:OnSelect()
end

function PANEL:PerformLayout()
	if ( self.Checkbox ) then
		self.Checkbox:AlignRight( 4 )
		self.Checkbox:CenterVertical()
	end
end

function PANEL:AddCheckBox( strConVar )
	if ( !self.Checkbox ) then
		self.Checkbox = vgui.Create( "DCheckBox", self )
	end
       
	self.Checkbox:SetConVar( strConVar )
	self:InvalidateLayout()
end

function PANEL:AddSubmenuIndicator()
	if ( !self.SubmenuInd ) then
		self.SubmenuInd = vgui.Create( "DLabel", self )
	end

	self.SubmenuInd:SetText(">")
	self.SubmenuInd:SetTextColor( Color( 80, 80, 80) )
	self.SubmenuInd:SetTall( 15 )
	self.SubmenuInd:SetPos(240,0)
	self:InvalidateLayout()
end

vgui.Register( "ToolMenuButton", PANEL, "DButton" )

/*-------------------------------------------------------------------------------------------------------------------------
	Plugin list
-------------------------------------------------------------------------------------------------------------------------*/

PANEL = {}
PANEL.Buttons = {}

function PANEL:Reset()
	for _, b in pairs( self.Submenu[1].Buttons ) do
		self.Submenu[1].Container:RemoveItem( b, true )
		b:RemoveEx()
	end
	self.Submenu[1].Buttons = {}
	
	self.Submenu[1]:SetPos( self:GetWide(), 0 )
	self.PluginContainer:SetPos( 1, 1 )
end

function PANEL:PopulateSubmenu( plugin, submenu, title )
	self.Submenu[1]:SetExpanded( false )
	self.Submenu[1]:Toggle()
	self.Submenu[1]:SetLabel( title or plugin:Menu() )
	
	local alt = true
	for _, value in pairs( submenu ) do
		if ( type( value ) != "table" ) then value = { value, value }
		elseif ( #value == 1 ) then value = { value[1], value[1] } end
		
		local button = vgui.Create( "ToolMenuButton" )
		button:SetText( value[1] )
		button.m_bAlt = alt
		alt = !alt
		
		button.OnSelect = function()
			RunConsoleCommand( "ev", plugin.ChatCommand, unpack( self:GetParent().Tab.PlayerList:GetSelectedPlayers() ), value[2] )
			
			self:GetParent().Tab.PluginList:MoveTo( self:GetParent():GetWide()/2, 0, 0.2 )

			self:GetParent().Tab.ButCancel:SetEnabled( false )
			self:GetParent().Tab.ButCancel:AlphaTo(0, 0)
			self:Reset()
		end
		
		table.insert( self.Submenu[1].Buttons, button )
		self.Submenu[1].Container:AddItem( button )
	end
end

function PANEL:OpenPluginMenu( plugin )
	local title, category, submenu, submenutitle = plugin:Menu()
	
	if ( submenu ) then
		self:PopulateSubmenu( plugin, submenu, submenutitle )

		self:GetParent().Tab.ButCancel:SetEnabled( true )
		self:GetParent().Tab.ButCancel:AlphaTo(255, 0)

		self.PluginContainer:MoveTo( -self:GetWide(), 0, 0.2 )
		self.Submenu[1]:MoveTo( 1, 1, 0.2 )
	else
		RunConsoleCommand( "ev", plugin.ChatCommand, unpack( self:GetParent().Tab.PlayerList:GetSelectedPlayers() ) )
		
		self:GetParent().Tab.PluginList:MoveTo( self:GetParent():GetWide()/2, 0, 0.2 )

		self:GetParent().Tab.ButCancel:SetEnabled( false )
		self:GetParent().Tab.ButCancel:AlphaTo(0, 0)
	end
end

function PANEL:AddButton( plugin, cat, highlight )
	if ( !plugin.Menu ) then return highlight end
	
	local button = vgui.Create( "ToolMenuButton" )
	button.title, button.category, button.submenu, button.submenutitle = plugin:Menu()
	
	if ( button.category.id != cat ) then button:RemoveEx() return highlight end
	
	button.plugin = plugin
	button.m_bAlt = highlight

	if(button.submenu ~= nil)then
		button:AddSubmenuIndicator()
	end

	button:SetText( button.title )
	
	button.OnSelect = function()
		self:OpenPluginMenu( plugin )
	end
	
	if(self.Categories[ button.category.id ] ~= nil) then
		self.Categories[ button.category.id ].Container:AddItem( button )
	end
	
	table.insert( self.Buttons, button )
	
	return !highlight
end

function PANEL:CreateSubmenu()
	self.Submenu = {}
	
	self.Submenu[1] = vgui.Create( "DCollapsibleCategory", self )
	self.Submenu[1]:SetPos( self:GetWide(), 1 )
	self.Submenu[1]:SetSize( self:GetWide() - 2, 22 )
	self.Submenu[1]:SetExpanded( false )
	self.Submenu[1]:SetAnimTime( 0.0 )
	self.Submenu[1].Buttons = {}
	
	self.Submenu[1].Container = vgui.Create( "DPanelList", self.Submenu[1] )
	self.Submenu[1].Container:SetAutoSize( true )
	self.Submenu[1].Container:SetSpacing( 0 )
    self.Submenu[1].Container:EnableHorizontal( false )
    self.Submenu[1].Container:EnableVerticalScrollbar( true )
	self.Submenu[1]:SetContents( self.Submenu[1].Container )
end

function PANEL:CreatePluginsPage()
	self.PluginContainer = vgui.Create( "DPanelList", self )
	self.PluginContainer:SetPos( 1, 1 )
	self.PluginContainer:SetSize( self:GetWide() - 2, self:GetTall() - 2 )
	self.PluginContainer:SetPadding( 1 )
	self.PluginContainer:SetSpacing( 1 )
	
	self.Categories = {}
	for key,cat in pairs(evolve.category) do 
		local categoryGui = vgui.Create( "DCollapsibleCategory", self.PluginContainer )
		categoryGui:SetTall( 22 )
		categoryGui:SetExpanded( 0 )
		categoryGui:SetLabel( cat.label )
		categoryGui.Header.OnMousePressed = function()
			for _,cat in pairs(self.Categories) do
				if ( cat:GetExpanded() ) then cat:Toggle() end
			end
			categoryGui:SetExpanded( false )
			categoryGui:Toggle()
		end
		
		categoryGui.Container = vgui.Create( "DPanelList", categoryGui )
		categoryGui.Container:SetAutoSize( true )
		categoryGui.Container:SetSpacing( 0 )
		categoryGui.Container:EnableHorizontal( false )
		categoryGui.Container:EnableVerticalScrollbar( true )
		categoryGui:SetContents( categoryGui.Container )
		
		self.Categories[cat.id]=categoryGui
		self.PluginContainer:AddItem( categoryGui )

		local highlight = true
		for _, v in pairs( evolve.plugins ) do
			highlight = self:AddButton( v, cat.id, highlight )
		end


	end
	
	self:CreateSubmenu()
	
	self.Categories[evolve.category.actions.id].Header.OnMousePressed()
end

derma.DefineControl( "EvolvePluginList", "Plugin list", PANEL, "DPanelList" )

end