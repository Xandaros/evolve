/*-------------------------------------------------------------------------------------------------------------------------
	Tab with player commands
-------------------------------------------------------------------------------------------------------------------------*/

include( "tab_players_controls.lua" )


local TAB = {}
TAB.Title = "Players"
TAB.Description = "Manage players on the server."
TAB.Icon = "user"
TAB.Author = "Overv"
TAB.Privileges = { "Player menu" }
TAB.Width = 520

function TAB:Initialize( pnl )
	// Create the player list
	self.PlayerList = vgui.Create( "EvolvePlayerList", pnl )
	self.PlayerList:AddColumn("Connected Players")
	self.PlayerList:SetPos( 0, 0 )
	self.PlayerList:SetSize( (self.Width/2) - 6, pnl:GetParent():GetTall() - 58 )
	
	// Create the plugin buttons	
	self.ButKick = vgui.Create( "EvolveButton", pnl )
	self.ButKick:SetPos( 0, pnl:GetParent():GetTall() - 58 )
	self.ButKick:SetSize( 56, 27 )
	self.ButKick:SetButtonText( "Kick" )

	self.ButKick.DoClick = function()
		if ( self.ButPlugins:GetButtonText() == "Cancel" ) then
			self.PluginList:Reset()
		end
		
		self.PluginList:OpenPluginMenu( evolve:FindPlugin( "Kick" ) )
		
		self.PluginList:MoveTo( self.Width/2, 0, 0.1 )

		self.ButPlugins:SetEnabled( false )
		self.ButPlugins:AlphaTo(255, 0)
	end
	
	self.ButBan = vgui.Create( "EvolveButton", pnl )
	self.ButBan:SetPos( self.ButKick:GetWide() + 5, pnl:GetParent():GetTall() - 58 )
	self.ButBan:SetSize( 64, 27 )
	self.ButBan:SetButtonText( "Ban" )
	self.ButBan.DoClick = function()
		self.PluginList:OpenPluginMenu( evolve:FindPlugin( "Ban" ) )
		self.PluginList:MoveTo( self.Width/2, 0, 0.1 )

		self.ButPlugins:SetEnabled( false )
		self.ButPlugins:AlphaTo(255, 0)
	end
	
	self.ButPlugins = vgui.Create( "EvolveButton", pnl )
	self.ButPlugins:SetSize( 64, 27 )
	self.ButPlugins:SetPos( self.Width/2 ,pnl:GetParent():GetTall() - 58 )

	self.ButPlugins:SetButtonText( "Cancel" )
	
	self.ButPlugins:SetEnabled( false )
	self.ButPlugins:AlphaTo(0, 0)

	self.ButPlugins:SetNotHighlightedColor( 50 )
	self.ButPlugins:SetHighlightedColor( 90 )
	self.ButPlugins.DoClick = function()
		if ( self.ButPlugins:GetButtonText() == "Plugins" ) then

		else
			self.PluginList:MoveTo( self.Width/2, 0, 0.1 )
			self.PluginList:Reset()
			self.ButPlugins:SetEnabled( false )
			self.ButPlugins:AlphaTo(0, 0)
		end
	end
	
	// Create the plugin list
	self.PluginList = vgui.Create( "EvolvePluginList", pnl )
	self.PluginList:SetPos( self.Width/2, 0 )
	self.PluginList:SetSize( self.Width/2, pnl:GetParent():GetTall() - 58 )
	self.PluginList:CreatePluginsPage()
	
	self.PlayerList.Parent = self
end

function TAB:Update()
	self.PlayerList:Populate()
	
	if ( self.ButPlugins:GetButtonText() != "" ) then
		self.PluginList:SetPos( self.Width/2, 0 )
		self.PluginList:Reset()

		self.ButPlugins:AlphaTo(0, 0)
		self.ButPlugins:SetEnabled( false )
	end
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Player menu" )
end

evolve:RegisterTab( TAB )