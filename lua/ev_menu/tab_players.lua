/*-------------------------------------------------------------------------------------------------------------------------
	Tab with player commands
-------------------------------------------------------------------------------------------------------------------------*/

include( "tab_players_controls.lua" )

local TAB = {}
TAB.Title = "Players"
TAB.Description = "Manage players on the server."
TAB.Icon = "gui/silkicons/user"
TAB.Author = "Overv"
TAB.Privileges = { "Player menu" }
TAB.Width = 260

function TAB:Initialize( pnl )
	// Create the player list
	self.PlayerList = vgui.Create( "EvolvePlayerList", pnl )
	self.PlayerList:SetPos( 0, 0 )
	self.PlayerList:SetSize( self.Width, pnl:GetParent():GetTall() - 58 )
	self.PlayerList:SetMultiple( true )
	
	// Create the plugin buttons	
	self.ButKick = vgui.Create( "EvolveButton", pnl )
	self.ButKick:SetPos( 0, pnl:GetParent():GetTall() - 53 )
	self.ButKick:SetSize( 56, 22 )
	self.ButKick:SetButtonText( "Kick" )
	self.ButKick.DoClick = function()
		if ( self.ButPlugins:GetButtonText() == "Players" ) then
			self.PluginList:Reset()
		end
		
		self.PluginList:OpenPluginMenu( evolve:FindPlugin( "Kick" ) )
		
		self.PlayerList:MoveTo( -self.Width, 0, 0.1 )
		self.PluginList:MoveTo( 0, 0, 0.1 )
		self.ButPlugins:SetButtonText( "Players" )
	end
	
	self.ButBan = vgui.Create( "EvolveButton", pnl )
	self.ButBan:SetPos( self.ButKick:GetWide() + 5, pnl:GetParent():GetTall() - 53 )
	self.ButBan:SetSize( 64, 22 )
	self.ButBan:SetButtonText( "Ban" )
	self.ButBan.DoClick = function()
		if ( self.ButPlugins:GetButtonText() == "Players" ) then
			self.PluginList:Reset()
		end
		
		self.PluginList:OpenPluginMenu( evolve:FindPlugin( "Ban" ) )
		
		self.PlayerList:MoveTo( -self.Width, 0, 0.1 )
		self.PluginList:MoveTo( 0, 0, 0.1 )
		self.ButPlugins:SetButtonText( "Players" )
	end
	
	self.ButPlugins = vgui.Create( "EvolveButton", pnl )
	self.ButPlugins:SetPos( self.ButKick:GetWide() + self.ButPlugins:GetWide() + 10, pnl:GetParent():GetTall() - 53 )
	self.ButPlugins:SetSize( self.Width - 10 - self.ButKick:GetWide() - self.ButPlugins:GetWide(), 22 )
	self.ButPlugins:SetButtonText( "Plugins" )
	self.ButPlugins:SetNotHighlightedColor( 50 )
	self.ButPlugins:SetHighlightedColor( 90 )
	self.ButPlugins.DoClick = function()
		if ( self.ButPlugins:GetButtonText() == "Plugins" ) then
			self.PlayerList:MoveTo( -self.Width, 0, 0.1 )
			self.PluginList:MoveTo( 0, 0, 0.1 )
			self.ButPlugins:SetButtonText( "Players" )
		else
			self.PlayerList:MoveTo( 0, 0, 0.1 )
			self.PluginList:MoveTo( self.Width, 0, 0.1 )
			self.PluginList:Reset()
			self.ButPlugins:SetButtonText( "Plugins" )
		end
	end
	
	// Create the plugin list
	self.PluginList = vgui.Create( "EvolvePluginList", pnl )
	self.PluginList:SetPos( self.Width, 0 )
	self.PluginList:SetSize( self.Width, pnl:GetParent():GetTall() - 58 )
	self.PluginList:CreatePluginsPage()
	
	self.PlayerList.Parent = self
end

function TAB:Update()
	self.PlayerList:Populate()
	
	if ( self.ButPlugins:GetButtonText() != "Plugins" ) then
		self.PlayerList:SetPos( 0, 0 )
		self.PluginList:SetPos( self.Width, 0 )
		self.PluginList:Reset()
		self.ButPlugins:SetButtonText( "Plugins" )
	end
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Player menu" )
end

evolve:RegisterTab( TAB )