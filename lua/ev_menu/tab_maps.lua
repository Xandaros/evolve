local TAB = {}
TAB.Title = "Maps"
TAB.Description = "Change Map."
TAB.Author = "Divran"
TAB.Width = 520
TAB.Icon = "world"

function TAB:Update() end

function TAB:ChangeLevel( what )
    local map = self.MapList:GetLine(self.MapList:GetSelectedLine()):GetValue(1)
    local gamemode = self.GamemodeList:GetLine(self.GamemodeList:GetSelectedLine()):GetValue(1)
    if (map != "" and gamemode != "") then
        if (what == "both") then                        
            RunConsoleCommand( "ev_changemapandgamemode", map, gamemode )
        elseif (what == "map") then
            RunConsoleCommand( "ev_changemapandgamemode", map, GAMEMODE.Name)
        elseif (what == "gamemode") then
            RunConsoleCommand( "ev_changemapandgamemode", game.GetMap(), gamemode )
        end
    end
end

function TAB:Initialize( pnl )
       
        local w,h = self.Width, pnl:GetParent():GetTall()

        self.MapList = vgui.Create( "DListView", pnl )
        self.MapList:SetPos( 0, 2 )
        self.MapList:SetSize( w / 2 - 2, h - 58 )
        self.MapList:SetMultiSelect( false )
        self.MapList:AddColumn("Maps")
        local maps, _ = evolve:MapPlugin_GetMaps()
        for _, filename in pairs(maps) do
                self.MapList:AddLine( filename )
        end
        self.MapList:SelectFirstItem()
       
        self.GamemodeList = vgui.Create("DListView", pnl)
        self.GamemodeList:SetPos( w / 2 + 2, 2 )
        self.GamemodeList:SetSize( w / 2 - 4, h - 58 )
        self.GamemodeList:SetMultiSelect( false )
        self.GamemodeList:AddColumn("Gamemodes")
        local gamemodes, _ = evolve:MapPlugin_GetGamemodes()
        for _, foldername in pairs(gamemodes) do
                self.GamemodeList:AddLine( foldername )
        end
        self.GamemodeList:SelectFirstItem()
       
        self.BothButton = vgui.Create("DButton", pnl )
        self.BothButton:SetWide( w / 3 - 2 )
        self.BothButton:SetTall( 20 )
        self.BothButton:SetPos( w * (1/3) , h - 52 )
        self.BothButton:SetText( "Change Map And Gamemode" )
        function self.BothButton:DoClick()
                TAB:ChangeLevel( "both" )
        end
       
        self.MapButton = vgui.Create("DButton", pnl )
        self.MapButton:SetWide( w / 3 - 2 )
        self.MapButton:SetTall( 20 )
        self.MapButton:SetPos( 0 , h - 52 )
        self.MapButton:SetText( "Change Map" )
        function self.MapButton:DoClick()
                TAB:ChangeLevel( "map" )
        end
       
        self.GamemodeButton = vgui.Create("DButton", pnl )
        self.GamemodeButton:SetWide( w / 3 - 2 )
        self.GamemodeButton:SetTall( 20 )
        self.GamemodeButton:SetPos( w * (2/3) , h - 52 )
        self.GamemodeButton:SetText( "Change Gamemode" )
        function self.GamemodeButton:DoClick()
                TAB:ChangeLevel( "gamemode" )
        end
       
       
        self.Block = vgui.Create( "DFrame", pnl )
        self.Block:SetDraggable( false )
        self.Block:SetTitle( "" )
        self.Block:ShowCloseButton( false )
        self.Block:SetPos( 0, 0 )
        self.Block:SetSize( w, h )
        self.Block.Paint = function()
                surface.SetDrawColor( 46, 46, 46, 255 )
                surface.DrawRect( 0, 0, self.Block:GetWide(), self.Block:GetTall() )
               
                draw.SimpleText( "You need the Maps List Plugin ('sh_mapslist.lua') for this tab to work.", "ScoreboardText", self.Block:GetWide() / 2, self.Block:GetTall() / 2 - 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
        end
       
        if ( table.Count(maps) ) then self.Block:SetPos( self.Block:GetWide(), 0 ) end
end

evolve:RegisterTab( TAB )
