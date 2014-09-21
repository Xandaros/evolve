
local TAB = {}
TAB.Title = "Maps"
TAB.Description = "Used to change maps."
TAB.Icon = "arrow_refresh"
TAB.Author = "MDave" --Edited by MadDog, GeneralWrex and X-Coder
TAB.Width = 500
TAB.Privileges = { "Maps Menu" }
TAB.ToUpdate = nil

if ( SERVER ) then
	TAB.Maplist = file.Find( "maps/*.bsp", "GAME" )

	local function StreamMaps( ply , command , args )
		for _,v in ipairs( TAB.Maplist ) do
			umsg.Start( "EV_AvalibleMap" , ply )
				umsg.String( v )
			umsg.End()
		end
	end
	concommand.Add( "ea_streammaps"  , StreamMaps)

else
	TAB.Maplist = {}

	local function GetMaps( um )
	local map = um:ReadString()
		if ( !table.HasValue( TAB.Maplist , map) ) then
			table.insert( TAB.Maplist , map )
			TAB.ToUpdate = map
			TAB:Update()
		end
	end
	usermessage.Hook( "EV_AvalibleMap" , GetMaps )

end


function TAB:SetCurrentMapicon( map )
	if ( map == nil ) then
		map = game.GetMap()	
	end
	
	
	self.MapIcon:SetImage("maps/"..map..".png")
	self.MapIcon:SizeToContents()
	self.MapIcon.mappath = map	

	self.MapLabel:SetText( map )
	self.MapLabel:SizeToContents()

	local i_x , i_y = self.MapIcon:GetSize()
	self.MapIconBckg:SetSize( i_x +4 , i_y )
	self.MapIconBckg:Center()
	self.MapIcon:SetSize( i_x , i_y -25 )

	local l_x , l_y = self.MapLabel:GetSize()
	self.MapLabel:SetPos( i_x/2 - l_x/2 , i_y -20  )

end

function TAB:AddMapCategory( name )
	for _,v in ipairs( self.Maps.CatPanels ) do
		if ( v.name == name )then return v.Container end
	end

	--Copy paste from player controls :)
	i = #self.Maps.CatPanels +1

	self.Maps.CatPanels[i] = vgui.Create( "DCollapsibleCategory", self.Maps )
		self.Maps.CatPanels[i]:SetTall( 22 )
		self.Maps.CatPanels[i]:SetExpanded( 0 )
		self.Maps.CatPanels[i]:SetLabel( name )

		self.Maps.CatPanels[i].Container = vgui.Create( "DPanelList", self.Maps.CatPanels[i] )
		self.Maps.CatPanels[i].Container:SetAutoSize( true )
		self.Maps.CatPanels[i].Container:SetSpacing( 5 )
		self.Maps.CatPanels[i].Container:SetPadding( 5 )
		self.Maps.CatPanels[i].Container:EnableHorizontal( true )
		self.Maps.CatPanels[i].Container:EnableVerticalScrollbar( true )
		self.Maps.CatPanels[i]:SetContents( self.Maps.CatPanels[i].Container )

		self.Maps.CatPanels[i].name = name
		self.Maps:AddItem( self.Maps.CatPanels[i] )
	return self.Maps.CatPanels[i].Container
end


function TAB:Initialize( pnl )
	RunConsoleCommand( "ea_streammaps" )

	self.IconPanel = vgui.Create( "DPanel" , pnl )
		self.IconPanel:SetPos( 2 , 2 )
		self.IconPanel:SetSize( self.Width -10 , pnl:GetParent():GetTall()*.23 -20 )
		self.IconPanel.m_bgColor = Color(80 , 80 , 80 , 255)

	self.MapIconBckg = vgui.Create( "DPanel" , self.IconPanel )
	self.MapIconBckg.m_bgColor = Color( 255 , 155 , 20 , 255 )

	self.MapIcon = vgui.Create( "DImageButton", self.MapIconBckg )
	self.MapIcon:SetPos( 2, 2 )
	self.MapIcon:SetKeepAspect( true )
	self.MapIcon.DoClick = function()
		if ( LocalPlayer():EV_HasPrivilege( "Map changing" ) ) then
			RunConsoleCommand( "ev" , "map" , self.MapIcon.mappath )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		end
	end

	self.MapLabel = vgui.Create( "DLabel" , self.MapIconBckg )
	self.MapLabel.m_colText = Color( 255 , 255, 255 , 255)

	self:SetCurrentMapicon( nil )

	self.Maps = vgui.Create( "DPanelList", pnl )
	self.Maps:SetPos(2, pnl:GetParent():GetTall()*.3 )
	self.Maps:SetSize( self.Width -10 , pnl:GetParent():GetTall()*.7 - 10 )

	self.Maps:EnableVerticalScrollbar(true)
	self.Maps:EnableHorizontal(false)
	self.Maps:SetPadding( 1 )
	self.Maps:SetSpacing( 1 )
	self.Maps.CatPanels = {}

	--Map categorysing:
	self.Hidden = { "credits" }

	self.Cats = {
			{ name = "hidden" , patterns = { "background", "^test_", "^styleguide", "^devtest" , "intro" } },
			{ name = "Garrysmod" , patterns = {"^gm_"} },
			{ name = "Portal" , patterns = {"^escape_" , "^testchmb_"} },
			{ name = "Portal 2" , patterns = {"^mp_coop_" , "^sp_"} },
			{ name = "Half life 2" , patterns = {"^d1_","^d2_","^d3_"} },
			{ name = "Half life 2 Epsiode 1" , patterns = {"^ep1_"} },
			{ name = "Half life 2 Epsiode 2" , patterns = {"^ep2_"} },
			{ name = "Counter Strike Source" , patterns = {"^de_" , "^cs_" , "^es_" } },
			{ name = "Team Fortress 2" , patterns = {"^arena_" , "^cp_" , "ctf_" , "pl_" , "plr_" , "tc_" , "koth_" , "tr_"} },
			{ name = "Half life 2 Deatmatch" , patterns = {"^dm_"}},
			{ name = "Spacebuild" , patterns = {"^sb_","^gm_space"}},
			{ name = "Stargate" , patterns = {"^sg_","^sg1_"}}
		}



-- Make the buttons--
function MakeMapButton(text)
	local noadd = false
	local btn = vgui.Create( "DButton" )
	btn:SetSize( self.Maps:GetWide()/2-20, 20 )
	btn:SetText( text )

	btn.mappath = string.sub( text , 1 , string.len(text)-4 )
	btn.category = nil

	btn.DoClick = function()
		TAB:SetCurrentMapicon( btn.mappath )
	end

	--Categorize the button.
	for _,v in ipairs( self.Cats ) do
		local exploded = string.Explode( "_" , btn.mappath )
		if ( !table.HasValue( self.Hidden , btn.mappath ) ) then
			if ( v.patterns != nil )then
				for _,patt in ipairs( v.patterns ) do
					if ( string.find( btn.mappath, patt ) ) then
						btn.category = v.name
						noadd = ( v.name == "invalid" ) or ( v.name == "hidden" )
						break
					end
				end
			end
		else
			noadd = true
		end
	end

	if ( !noadd ) then
		if ( btn.category == nil )
			then btn.category = "Misc"
		end		
		local container = self:AddMapCategory( btn.category )
		btn:SetParent( container )
		container:AddItem( btn )
	else
		btn:Remove()
	end
end

end

function TAB:Update()
	if ( self.ToUpdate != nil ) then
		MakeMapButton( self.ToUpdate )
		self.ToUpdate = nil
	end
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Map changing" )
end

evolve:RegisterTab( TAB )
