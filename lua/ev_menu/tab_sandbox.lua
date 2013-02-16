/*-------------------------------------------------------------------------------------------------------------------------
	Tab with sandbox settings
-------------------------------------------------------------------------------------------------------------------------*/

local TAB = {}
TAB.Title = "Sandbox"
TAB.Description = "Manage sandbox settings."
TAB.Icon = "world"
TAB.Author = "Overv"
TAB.Width = 520
TAB.Privileges = { "Sandbox menu" }

TAB.Limits = {
	{ "sbox_maxprops", "Props" },
	{ "sbox_maxragdolls", "Ragdolls" },
	{ "sbox_maxvehicles", "Vehicles" },
	{ "sbox_maxeffects", "Effects" },
	{ "sbox_maxballoons", "Balloons" },
	{ "sbox_maxnpcs", "NPCs" },
	{ "sbox_maxdynamite", "Dynamite" },
	{ "sbox_maxlamps", "Lamps" },
	{ "sbox_maxlights", "Lights" },
	{ "sbox_maxwheels", "Wheels" },
	{ "sbox_maxthrusters", "Thrusters" },
	{ "sbox_maxhoverballs", "Hoverballs" },
	{ "sbox_maxbuttons", "Buttons" },
	{ "sbox_maxemitters", "Emitters" },
	{ "sbox_maxspawners", "Spawners" },
	{ "sbox_maxturrets", "Turrets" }
}
TAB.ConVars = {
	{ "sbox_godmode", "Godmode" },
	{ "sbox_noclip", "Noclip" },
	{ "sbox_playershurtplayers", "PvP" },
	{ "sbox_weapons", "Weapons" },
	{ "g_ragdoll_maxcount", "Keep NPC bodies", 8 }
}
TAB.ConVarSliders = {}
TAB.ConVarCheckboxes = {}

local function round(n)
	if n % 1 < 0.5 then
		return math.floor(n)
	else
		return math.ceil(n)
	end
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Sandbox menu" )
end

function TAB:Initialize( pnl )	
	self.LimitsContainer = vgui.Create( "DPanelList", pnl )
	self.LimitsContainer:SetPos( 2, 2 )
	self.LimitsContainer:SetSize( self.Width - 164, pnl:GetParent():GetTall() - 32 )
	self.LimitsContainer:SetSpacing( -5 )
	self.LimitsContainer:SetPadding( 10 )
	self.LimitsContainer:EnableHorizontal( true )
	self.LimitsContainer:EnableVerticalScrollbar( true )
	self.LimitsContainer.Paint = function( self )
		draw.RoundedBox( 4, 2, 2, self:GetWide() - 6, self:GetTall() - 12, Color( 230, 230, 230, 255 ) )
	end
	
	for i, cv in pairs( self.Limits ) do
		if ( ConVarExists( cv[1] ) ) then
			local cvSlider = vgui.Create( "DNumSlider", pnl )
			cvSlider:SetText( cv[2] )
			cvSlider:SetWide( self.LimitsContainer:GetWide() - 7 )
			cvSlider:SetMin( 0 )
			cvSlider:SetMax( 200 )
			cvSlider:SetDecimals( 0 )
			cvSlider:SetValue( GetConVar( cv[1] ):GetInt() )
			cvSlider.ConVar = cv[1]
			
			local scratch_released = cvSlider.Scratch.OnMouseReleased
			local slider_released = cvSlider.Slider.OnMouseReleased
			local knob_released = cvSlider.Slider.Knob.OnMouseReleased

			local function mousereleased(mousecode)
				RunConsoleCommand("ev", "convar", cv[1], round(cvSlider:GetValue()))
			end

			function cvSlider.Scratch:OnMouseReleased(mousecode)
				mousereleased(mousecode)
				scratch_released(cvSlider.Scratch, mousecode)
			end

			function cvSlider.Slider:OnMouseReleased(mousecode)
				mousereleased(mousecode)
				slider_released(cvSlider.Slider, mousecode)
			end

			function cvSlider.Slider.Knob:OnMouseReleased(mousecode)
				mousereleased(mousecode)
				knob_released(cvSlider.Slider.Knob, mousecode)
			end
			
			cvSlider.Label:SetDark(true)
			self.LimitsContainer:AddItem( cvSlider )
		
			table.insert( self.ConVarSliders, cvSlider )
		end
	end
	
	self.Settings = vgui.Create( "DPanelList", pnl )
	self.Settings:SetPos( self.Width - 165, 2 )
	self.Settings:SetSize( 166, pnl:GetParent():GetTall() - 32 )
	self.Settings:SetSpacing( 9 )
	self.Settings:SetPadding( 10 )
	self.Settings:EnableHorizontal( true )
	self.Settings:EnableVerticalScrollbar( true )
	self.Settings.Paint = function( self )
		draw.RoundedBox( 4, 4, 2, self:GetWide() - 16, self:GetTall() - 12, Color( 230, 230, 230, 255 ) )
	end
	
	for i, cv in pairs( self.ConVars ) do
		if ( ConVarExists( cv[1] ) ) then
			local cvCheckbox = vgui.Create( "DCheckBoxLabel", self.Settings )
			cvCheckbox:SetText( cv[2] )
			cvCheckbox:SetWide( self.Settings:GetWide() - 15 )
			cvCheckbox:SetValue( GetConVar( cv[1] ):GetInt() > 0 )
			cvCheckbox.ConVar = cv[1]
			cvCheckbox.OnChange = function( self, val )
				RunConsoleCommand( "ev", "convar", cv[1], evolve:BoolToInt( val ) * ( cv[3] or 1 ) )
			end
			cvCheckbox.Label:SetDark(true)
			self.Settings:AddItem( cvCheckbox )
			
			table.insert( self.ConVarCheckboxes, cvCheckbox )
		end
	end
end

if ( CLIENT and GAMEMODE.IsSandboxDerived ) then
	evolve:RegisterTab( TAB )
elseif ( SERVER ) then
	evolve:RegisterTab( TAB )
end
