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
		self.PluginList:Reset()

		self.PluginList:OpenPluginMenu( evolve:FindPlugin( "Kick" ) )
		
		self.PluginList:MoveTo( self.Width/2, 0, 0.1 )

		self.ButCancel:SetEnabled( true )
		self.ButCancel:AlphaTo(255, 0)
	end
	
	self.ButBan = vgui.Create( "EvolveButton", pnl )
	self.ButBan:SetPos( self.ButKick:GetWide() + 5, pnl:GetParent():GetTall() - 58 )
	self.ButBan:SetSize( 64, 27 )
	self.ButBan:SetButtonText( "Ban" )
	self.ButBan.DoClick = function()

		self.PluginList:OpenPluginMenu( evolve:FindPlugin( "Ban" ) )
		self.PluginList:MoveTo( self.Width/2, 0, 0.1 )

		self.ButCancel:SetEnabled( true )
		self.ButCancel:AlphaTo(255, 0)
	end
	
	self.ButCancel = vgui.Create( "EvolveButton", pnl )
	self.ButCancel:SetSize( 64, 27 )
	self.ButCancel:SetPos( self.Width/2 ,pnl:GetParent():GetTall() - 58 )

	self.ButCancel:SetButtonText( "Cancel" )
	
	self.ButCancel:SetEnabled( false )
	self.ButCancel:AlphaTo(0, 0)

	self.ButCancel:SetNotHighlightedColor( 50 )
	self.ButCancel:SetHighlightedColor( 90 )
	self.ButCancel.DoClick = function()
		self.PluginList:MoveTo( self.Width/2, 0, 0.1 )
		self.PluginList:Reset()
		self.ButCancel:SetEnabled( false )
		self.ButCancel:AlphaTo(0, 0)
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
	self.PluginList:SetPos( self.Width/2, 0 )
	self.PluginList:Reset()

	self.ButCancel:AlphaTo(0, 0)
	self.ButCancel:SetEnabled( false )
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Player menu" )
end

evolve:RegisterTab( TAB )