/*-------------------------------------------------------------------------------------------------------------------------
	Clientside menu framework
-------------------------------------------------------------------------------------------------------------------------*/

evolve.MENU = {}
local MENU = evolve.MENU
MENU.Tabs = {}
MENU.Privileges = {}

function evolve:RegisterTab( tab )
	if ( tab.IsAllowed and !tab:IsAllowed() ) then return false end
	
	table.Add( MENU.Privileges, tab.Privileges or {} )
	
	tab.Panel = vgui.Create( "DPanel", MENU.TabContainer )
	tab.Panel.Tab = tab
	tab.Panel.Paint = function() surface.SetDrawColor( 171, 171, 171, 255 ) surface.DrawRect( 0, 0, tab.Panel:GetWide(), tab.Panel:GetTall() ) end
	
	tab:Initialize( tab.Panel )
	if tab.Update then tab:Update() end
	
	MENU.TabContainer:AddSheet( tab.Title, tab.Panel, "icon16/" .. tab.Icon .. ".png", false, false, tab.Description )
	table.insert( MENU.Tabs, tab )
end

function MENU:GetActiveTab()
	for _, sheet in ipairs( self.TabContainer.Items ) do
		if ( sheet.Tab == self.TabContainer:GetActiveTab() ) then
			return sheet.Panel.Tab
		end
	end
end

function MENU:TabSelected( tab )
	if ( tab and tab.Update ) then
		tab:Update()
	end
end

function MENU:Initialize()
	self.IsVisible = false

	self.Panel = vgui.Create( "DFrame" )
	self.Panel:SetSize( 260, 490 )
	self.Panel:SetPos( -self.Panel:GetWide(), ScrH() / 2 - self.Panel:GetTall() / 2 )
	self.Panel:ShowCloseButton( false )
	self.Panel:SetDraggable( false )
	self.Panel:SetTitle( "" )
	self.Panel.Paint = function() end
	
	self.TabContainer = vgui.Create( "DPropertySheet", self.Panel )
	self.TabContainer:SetPos( 0, 0 )
	self.TabContainer:SetSize( self.Panel:GetSize() )
	
	local tabs,_ = file.Find("ev_menu/tab_*.lua", "LUA")
	for _, file in ipairs( tabs ) do
		include( "ev_menu/" .. file )
	end
	
	self.Panel:MakePopup()
	self.Panel:SetKeyboardInputEnabled( false )
	
	timer.Create( "EV_MenuThink", 1/60, 0, function() MENU:Think() end )
end

function MENU:Destroy()
	if ( !self.Panel ) then return end
	self.Panel:Remove()
	self.Panel = nil
	self.Tabs = {}
end

function MENU:Think()
	if ( self.LastRank and self.LastRank != LocalPlayer():EV_GetRank() ) then
		self:Destroy()
		self.LastRank = LocalPlayer():EV_GetRank()
		return
	else
		self.LastRank = LocalPlayer():EV_GetRank()
	end
	
	if ( self.Panel ) then
		local activeTab = self:GetActiveTab()
		
		if ( self.ActiveTab != activeTab ) then
			self.ActiveTab = activeTab
			self:TabSelected( activeTab )
		end
		
		if ( activeTab ) then
			local w = self.TabContainer:GetWide() + ( ( activeTab.Width or 260 ) + 10 - self.TabContainer:GetWide() ) / 5
			if ( math.abs( w - ( activeTab.Width or 260 ) ) < 5 ) then w = ( activeTab.Width or 260 ) + 10 end
			self.Panel:SetWide( w )
			self.TabContainer:SetWide( w )
		end
	end
end

hook.Add( "EV_RankPrivilegeChange", "EV_MenuPrivUpdate", function( rank, privilege )
	if ( rank == LocalPlayer():EV_GetRank() and table.HasValue( MENU.Privileges, privilege ) ) then
		MENU:Destroy()
	end
end )

function MENU:Show()
	if ( !LocalPlayer():EV_HasPrivilege( "Menu" ) ) then return end
	if ( !self.Panel ) then MENU:Initialize() end
	
	for _, tab in ipairs( MENU.Tabs ) do
		if tab.Update then tab:Update() end
	end
	
	self.Panel:SetVisible( true )
	self.Panel:SetKeyboardInputEnabled( false )
	self.Panel:SetMouseInputEnabled( true )
	
	input.SetCursorPos( 50 + self.Panel:GetWide() / 2, ScrH() / 2 )
	
	timer.Create( "EV_MenuShow", 1/60, 0, function()
		self.Panel:SetPos( self.Panel:GetPos() + ( 110 - self.Panel:GetPos() ) / 7, ScrH() / 2 - self.Panel:GetTall() / 2 )
		
		if ( self.Panel:GetPos() > 50 ) then
			timer.Destroy( "EV_MenuShow" )
		end
	end )
	self.IsVisible = true
end

function MENU:Hide()
	if ( !self.Panel ) then return end
	
	self.Panel:SetKeyboardInputEnabled( false )
	self.Panel:SetMouseInputEnabled( false )
	
	timer.Create( "EV_MenuShow", 1/60, 0, function()
		self.Panel:SetPos( self.Panel:GetPos() - ( self.Panel:GetPos() + self.Panel:GetWide() + 10 ) / 5, ScrH() / 2 - self.Panel:GetTall() / 2 )
		
		if ( self.Panel:GetPos() < -self.Panel:GetWide() ) then
			self.Panel:SetVisible( false )
			timer.Destroy( "EV_MenuShow" )
		end
	end )
	self.IsVisible = false
end

function MENU:Toggle() 
	if self.IsVisible then
		self:Hide()	
	else
		self:Show()	
	end
end

concommand.Add( "+ev_menu", function() MENU:Show() end )
concommand.Add( "-ev_menu", function() MENU:Hide() end )
concommand.Add( "ev_menu", function() MENU:Toggle() end )
