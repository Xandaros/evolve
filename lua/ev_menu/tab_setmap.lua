local TAB = {}
TAB.Title = "Maps"
TAB.Description = "Change Map."
TAB.Author = "Divran"
TAB.Width = 520
TAB.Icon = "map"

local w,h 
local maps = {}

function TAB:RenderMaps()
    maps, _ = evolve:MapPlugin_GetMaps()
    for _, filename in pairs(maps) do
        self.MapList:AddLine( filename )
    end
    self.MapList:SelectFirstItem()

    return maps
end

function TAB:RenderGameModes()
    local gamemodes, _ = evolve:MapPlugin_GetGamemodes()
    for _, foldername in pairs(gamemodes) do
        self.GamemodeList:AddLine( foldername )
    end
    self.GamemodeList:SelectFirstItem()

    return gamemodes
end

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
       
    w,h = self.Width, pnl:GetParent():GetTall()

    self.MapList = vgui.Create( "DListView", pnl )
    self.MapList:SetPos( 0, 2 )
    self.MapList:SetSize( w / 2 - 2, h - 58 )
    self.MapList:SetMultiSelect( false )
    self.MapList:AddColumn("Maps")
    TAB:RenderMaps()

    self.GamemodeList = vgui.Create("DListView", pnl)
    self.GamemodeList:SetPos( w / 2 + 2, 2 )
    self.GamemodeList:SetSize( w / 2 - 4, h - 58 )
    self.GamemodeList:SetMultiSelect( false )
    self.GamemodeList:AddColumn("Gamemodes")
    TAB:RenderGameModes()

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
           
        draw.SimpleText( "Waiting on map list..", "ScoreboardText", self.Block:GetWide() / 2, self.Block:GetTall() / 2 - 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
        draw.SimpleText( "You need the Maps List Plugin ('sh_mapslist.lua') for this tab to work. ", "ScoreboardText", self.Block:GetWide() / 2, self.Block:GetTall() / 2 , Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
        draw.SimpleText( "If you have the plugin, please wait a few seconds.", "ScoreboardText", self.Block:GetWide() / 2, self.Block:GetTall() / 2 + 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    end

    timer.Create("mapCheckTimer", 1, 0, function()
        if(table.IsEmpty(maps))then
            evolve:MapPlugin_RequestMaps()
            timer.Simple(0.5, function()
                self.MapList:Clear()
                TAB:RenderMaps()
        
                self.GamemodeList:Clear()
                TAB:RenderGameModes()
            end)
        else
            self.Block:SetPos( self.Block:GetWide(), 0 )
            timer.Remove("mapCheckTimer")
        end
        
    end)
end



function TAB:Update()
end

evolve:RegisterTab( TAB )
