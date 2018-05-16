
local IsTTTOverride = false -- Force true if gamemode is not the same name.

local function IsTTT()
    return IsTTTOverride or gmod.GetGamemode().Name == "Trouble in Terrorist Town" 
end

if IsTTT then
local TAB = {}
TAB.Title = "TTT"
TAB.Description = "Manage the Terror Town Game mode."
TAB.Icon = "group"
TAB.Author = "Staz.IO"
TAB.Width = 640
TAB.Privileges = { "TTT Menu", "TTT Actions" }
local its = {}

-- This determines if the second privilege list column toggles all privileges on or off
TAB.AllToggle = true
local OPTIONS = {
    {'ttt_roundtime_minutes', 'time', 'Number of minutes a round should take'},
    {'ttt_firstpreptime', 'time', 'Number of minutes first round should take'},
    -- {'ttt_round_limit', 'time', 'M'},
    {'ttt_minimum_players', 'num', 25, 'Minimum number of players needs to start round'},
    {'ttt_haste_starting_minutes', 'time', 'Starting time when in haste mode'},
    {'ttt_haste', 'toggle', 'Toggle Haste Mode'},
    {'ttt_postround_dm', 'toggle', 'Allow PvP post-round'},
    {'ttt_posttime_seconds', 'time', 'Length of the post-round'},
    {'ttt_round_limit', 'num', 15, 'Max number of rounds allowed on map'},
    {'ttt_idle_limit', 'time', 'Max amonut of time before player is kicked'},
    {'ttt_traitor_pct', 'pct', 'Percentage of people who are traitors'},
    {'ttt_traitor_max', 'pct', 'Max number of traitors'},
    {'ttt_detective_max', 'num', 10, 'Max number of detectives'},
    {'ttt_detective_min_players', 'num', 25, 'Number of players needed for detective to start'},
    -- {'ttt_karma', 'toggle'},
}

local PANEL_OPTIONS = {
    x_offset = 10,
    width = TAB.Width - 20,
    height = 10
}

function BuildNumPanel(PNL)
    local pnl = vgui.Create("DNumSlider", PNL)
    pnl.Label:SetColor(Color(0,0,0))
    
    function pnl:SetPosition(i)
        pnl:SetPos( PANEL_OPTIONS.x_offset,  (PANEL_OPTIONS.height + 10) * i )
    end

    function pnl:SetVar(var)
        self.var = var
    end

    function pnl:SetLabel(text)
        pnl:SetText(text)
    end

    function pnl:OnValueChanged(newVal)
        if self.var then
            local dec = self:GetDecimals()
            local val = math.floor (newVal * 10^dec) / 10^dec
            local convar = GetConVar(self.var)
            if not convar or convar:GetInt() ~= val then
                print("Running ev_ttt " .. self.var .. " " .. val)
                RunConsoleCommand("ev_ttt", self.var, val)
            end
        end
    end

    function pnl:DoUpdate()
        if self.var then
            local convar = GetConVar(self.var)
            if convar then
                self:SetValue(convar:GetInt())
            end
        end
    end 
    return pnl
end

function BuildCheckboxPanel(PNL)
    pnl = vgui.Create("DCheckBox", PNL)
    pnl.l = vgui.Create("DLabel", PNL)
    pnl.l:SetColor(Color(0,0,0))
    
    
    function pnl:SetPosition(i)
        pnl:SetPos(PANEL_OPTIONS.x_offset + 3*(TAB.Width / 4.5), (PANEL_OPTIONS.height + 10) * i )
        pnl.l:SetPos(PANEL_OPTIONS.x_offset, (PANEL_OPTIONS.height + 10) * i)
        pnl.l:SetSize(TAB.Width , PANEL_OPTIONS.height)
        pnl.l:SetContentAlignment(4)
    end

    function pnl:SetVar(var)
        self.var = var
    end

    function pnl:SetLabel(text)
        pnl.l:SetText(text)
    end

    function pnl:OnChange(newVal)
        if newVal then
            newVal = 1
        else
            newVal = 0
        end
        if self.var then
            --convar = GetConVar(self.var):SetInt(newVal)
            print("Running ev_ttt " .. self.var .. " " .. newVal)
            RunConsoleCommand("ev_ttt", self.var, newVal)
        end
    end 

    function pnl:DoUpdate()
        if self.var then
            convar = GetConVar(self.var)
            if convar then
                self:SetValue(convar:GetInt())
            end
        end
    end
    return pnl
end


function TAB:Initialize( pnl )
    for _,v in pairs(OPTIONS) do
        local convar = v[1]
        local typ = v[2] or "num"
        local max = v[3]
        local desc = v[4] or convar
        if typ == "pct" or typ == "toggle" then
            desc = v[3] or convar
        end

        if typ == "pct" then
            typ = "num"
            desc = max
            max = 1
        elseif typ == "time" then
           typ = "num"
           desc = max
            max =  1500 
        end

        local var = 0

        if typ == "toggle" then
            var = BuildCheckboxPanel(pnl)            
        --var:SetSize(30, PANEL_OPTIONS.height)
        else 
            var = BuildNumPanel(pnl)
            var:SetMin(0)
            var:SetMax(max)
            var:SetSize(PANEL_OPTIONS.width, PANEL_OPTIONS.height)
        end
        var:SetPosition(#its+1)
        var:SetVar(convar)
        
        if desc then
            var:SetLabel(desc)
        else
            var:SetLabel(convar)
        end
        its[#its + 1] = var
        print(#its)
    end
end

function TAB:Update()	 
    for _,v in pairs(its) do
        v:DoUpdate()
    end
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "TTT Menu" )
end

evolve:RegisterTab( TAB )

if SERVER then
    concommand.Add('ev_ttt', function(ply, cmd, args, argStr)
        if #args == 0 then return false end

        if ply:EV_HasPrivilege("TTT Actions") then
            GetConVar(args[1]):SetInt(args[2])
        end
    end)
end
end