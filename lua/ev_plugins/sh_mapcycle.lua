/*-------------------------------------------------------------------------------------------------------------------------
        Automatic map cycle
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Map Cycle"
PLUGIN.Description = "Automatically cycle maps."
PLUGIN.Author = "Divran"
PLUGIN.ChatCommand = "mapcycle"
PLUGIN.Usage = "[add/remove/toggle/moveup/movedown/interval] [mapname/interval]"
PLUGIN.Privileges = { "Map Cycle" }

PLUGIN.Enabled = false
PLUGIN.Maps = {}
PLUGIN.Interval = -1
PLUGIN.ChangeAt = -1

if (SERVER) then
       
        ----------------------------
        -- Call
        ----------------------------

        local funcs = { ["add"] = true, ["remove"] = true, ["toggle"] = true, ["moveup"] = true, ["movedown"] = true, ["interval"] = true }
        function PLUGIN:Call( ply, args )
       
                -- Error checking
                if (!ply:EV_HasPrivilege( "Map Cycle" )) then
                        evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
                        return
                end
                if (!args[1] or args[1] == "") then
                        evolve:Notify( ply, evolve.colors.red, "You must specify an action (add/remove/toggle/moveup/movedown/interval)" )
                        return
                end
                if (!funcs[args[1]]) then
                        evolve:Notify( ply, evolve.colors.red, "Invalid action ('"..args[1].."')." )
                        return
                end
               
                if (!self[args[1]]( self, ply, args )) then return end -- If the function ran alright, call it client side...
               
                umsg.Start( "ev_mapcycle_clientside_cmd" )
                        umsg.Char( #args )
                        for i=1,#args do
                                umsg.String( args[i] )
                        end
                umsg.End()
        end
       
        util.AddNetworkString("ev_mapcycle_datastream")
end

function PLUGIN:Notify( ... ) -- Helper function to block messages running on the client (potentially making it print twice)
        if (CLIENT) then return end
        evolve:Notify( ... )
end

if (CLIENT) then
        usermessage.Hook( "ev_mapcycle_clientside_cmd", function( um )
                local n = um:ReadChar()
                local args = {}
                for i=1,n do
                        args[i] = um:ReadString()
                end
               
                PLUGIN[args[1]]( PLUGIN, { Nick = function() end }, args )
        end)
end

----------------------------
-- Add
----------------------------

function PLUGIN:add( ply, args )
        if (!args[2] or args[2] == "") then
                self:Notify( ply, evolve.colors.red, "You must specify a map to add." )
                return
        end
        self:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " added the map ", evolve.colors.red, args[2], evolve.colors.white, " to the map cycle list." )
        self.Maps[#self.Maps+1] = args[2]
        self:Save()
        if (CLIENT) then evolve:MapCyclePlugin_UpdateTab() end
       
        return true
end

----------------------------
-- remove
----------------------------

function PLUGIN:remove( ply, args )
        if (!args[2] or args[2] == "") then
                self:Notify( ply, evolve.colors.red, "You must specify a map." )
                return
        end
       
        local nr = tonumber(args[2])
        if (!nr or nr == 0) then
                self:Notify( ply, evolve.colors.red, "The specified map must be the number index of the map." )
                return
        end
       
        if (!self.Maps[nr]) then
                self:Notify( ply, evolve.colors.red, "That map is not on the cycle list." )
                return
        end
       
        self:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " removed the map ", evolve.colors.red, self.Maps[nr], evolve.colors.white, " from the map cycle list." )
        table.remove( self.Maps, nr )
        self:Save()
        if (CLIENT) then evolve:MapCyclePlugin_UpdateTab() end
       
        return true
end

----------------------------
-- Toggle
----------------------------

function PLUGIN:toggle( ply, args )
        if (CLIENT) then return end
       
        self.Enabled = !self.Enabled
       
        self.ChangeAt = RealTime() + self.Interval * 60
        self:Update()
       
        self:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " toggled the map cycle. It is now ", evolve.colors.red, self.Enabled and "enabled" or "disabled", evolve.colors.white, "." )
        self:Save()
end

----------------------------
-- Move Up
----------------------------

function PLUGIN:moveup( ply, args )
        if (!args[2] or args[2] == "") then
                self:Notify( ply, evolve.colors.red, "You must specify a map." )
                return
        end

        local nr = tonumber(args[2])
        if (!nr or nr == 0) then
                self:Notify( ply, evolve.colors.red, "The specified map must be the number index of the map." )
                return
        end
       
        if (nr == 1) then
                self:Notify( ply, evolve.colors.red, "The specified map is already at the top of the list." )
                return
        end
       
        if (!self.Maps[nr]) then
                self:Notify( ply, evolve.colors.red, "That map is not on the cycle list." )
                return
        end
       
        self:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " moved the map ", evolve.colors.red, self.Maps[nr], evolve.colors.white, " one step up in the map cycle list." )
       
        local temp = self.Maps[nr-1]
        self.Maps[nr-1] = self.Maps[nr]
        self.Maps[nr] = temp
       
        self:Save()
        if (CLIENT) then evolve:MapCyclePlugin_UpdateTab() end
       
        return true
end

----------------------------
-- Move Down
----------------------------

function PLUGIN:movedown( ply, args )
        if (!args[2] or args[2] == "") then
                self:Notify( ply, evolve.colors.red, "You must specify a map." )
                return
        end

        local nr = tonumber(args[2])
        if (!nr or nr == 0) then
                self:Notify( ply, evolve.colors.red, "The specified map must be the number index of the map." )
                return
        end
       
        if (nr == #self.Maps) then
                self:Notify( ply, evolve.colors.red, "The specified map is already at the bottom of the list." )
                return
        end
       
        if (!self.Maps[nr]) then
                self:Notify( ply, evolve.colors.red, "That map is not on the cycle list." )
                return
        end
       
        self:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " moved the map ", evolve.colors.red, self.Maps[nr], evolve.colors.white, " one step down in the map cycle list." )
       
        local temp = self.Maps[nr+1]
        self.Maps[nr+1] = self.Maps[nr]
        self.Maps[nr] = temp
       
        self:Save()
        if (CLIENT) then evolve:MapCyclePlugin_UpdateTab() end
       
        return true
end

----------------------------
-- Interval
----------------------------

function PLUGIN:interval( ply, args )
        if (CLIENT) then return end
       
        if (!args[2] or args[2] == "") then    
                self:Notify( ply, evolve.colors.red, "You must specify an interval." )
                return
        end
       
        local nr = tonumber( args[2] )
        if (!nr or nr == 0) then
                self:Notify( ply, evolve.colors.red, "Invalid interval specified." )
                return
        end
       
        self.Interval = nr
        self.ChangeAt = RealTime() + self.Interval * 60
       
        self:Update()
        self:Save()
       
        if (args[3]) then
                self:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " changed the map cycle interval to ", evolve.colors.red, tostring(self.Interval), evolve.colors.white, " minutes.", evolve.colors.red, " (" .. args[3] .. ")" )
        else
                self:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " changed the map cycle interval to ", evolve.colors.red, tostring(self.Interval), evolve.colors.white, " minutes." )
        end
       
        return true
end

----------------------------
-- Interval
-- Update all changes on all clients
----------------------------
if (CLIENT) then
        net.Receive( "ev_mapcycle_datastream", function( len, ply )
                local decoded = net.ReadTable()
                for k,v in pairs( decoded ) do
                        if (PLUGIN[k] != nil) then
                                PLUGIN[k] = v
                        end
                end
               
                if (decoded.TimeDifference) then
                        PLUGIN.ChangeAt = RealTime() + decoded.TimeDifference
                end
               
                if evolve.MapCyclePlugin_UpdateTab then
                        evolve:MapCyclePlugin_UpdateTab()
                end
        end)
end

local old_changeat = 0
function PLUGIN:Update( ply, Send_Maps )
        if (CLIENT) then return end

        local recipients = ply
        local data = {}

        if (Send_Maps) then
                data.Maps = self.Maps
        end

        data.Interval = self.Interval
        data.Enabled = self.Enabled
        data.TimeDifference = self.ChangeAt - RealTime()
       
        timer.Adjust( "Evolve_UpdateMapCycle", math.max( self.Interval/100, 300 ), 0, function() self:Update() end, self )
       
        net.Start( "ev_mapcycle_datastream" )
                net.WriteTable( data )
               
        if recipients then
                net.Send( recipients )
        else
                net.Broadcast()
        end
end

----------------------------
-- Save
-- Save the map cycle and other data to a file
----------------------------

function PLUGIN:Save()
        if (CLIENT) then return end
        file.Write( "evolve/ev_mapcycle.txt", von.serialize( { self.Enabled, self.Interval, self.Maps } ) )
end

----------------------------
-- Load
-- Load the map cycle and other data from the file
----------------------------

function PLUGIN:Load()
        if (CLIENT) then return end
        if (file.Exists( "evolve/ev_mapcycle.txt", "DATA")) then
                local data = file.Read( "evolve/ev_mapcycle.txt", "DATA" )
                if (data and data != "") then
                        data = von.deserialize( data )
                        if (next(data)) then
                                self.Enabled = data[1]
                                self.Interval = data[2]
                                self.Maps = data[3]
                                self.ChangeAt = RealTime() + self.Interval * 60
                                self:Update( nil, true )
                        else
                                evolve:Notify( evolve.colors.red, "Error loading map cycle file: Data table is empty" )
                        end
                else
                        evolve:Notify( evolve.colors.red, "Error loading map cycle file: File is empty" )
                end
        else
                self.Enabled = false
                self.Interval = 0
                self.Maps = {}
        end
end

----------------------------
-- Think
-- Change map at the right time
----------------------------
PLUGIN.NextUpdate = RealTime() + 60
function PLUGIN:Think()
        -- Check if enabled
        if (!self.Enabled) then return end
       
        -- Don't run on client
        if (CLIENT) then return end
       
        -- Check if the next map is valid
        local NextMap = self.Maps[1]
        if (!NextMap or NextMap == "") then return end
       
        -- Check if we want to send an update to the client
        if self.NextUpdate < RealTime() then
                self.NextUpdate = RealTime() + 60
                self:Update()
        end
       
        -- Check if the timer has run out
        if (RealTime() > self.ChangeAt and self.ChangeAt != -1) then
                local _, maps_inverted = evolve:MapPlugin_GetMaps()
                if (!maps_inverted[NextMap]) then
                        evolve:Notify( evolve.colors.red, "MAP CYCLE ERROR: Next map is not a valid map! Map cycle disabled." )
                        self.Enabled = false
                        self:Update()
                        return
                end
               
                table.remove( self.Maps, 1 )
                self.Maps[#self.Maps+1] = NextMap
                self:Update()
                self:Save()
               
                evolve:Notify( evolve.colors.red, "Map changing!" )
                self.ChangeAt = -1
                timer.Simple( 0.5, function() RunConsoleCommand( "changelevel", NextMap ) end )
        end
end
       
-- Send the info when the player spawns
function PLUGIN:PlayerInitialSpawn( ply )
        timer.Simple( 3, function()
                if IsValid(ply) then
                        self:Update( ply, true )
                end
        end)
end

-- Initialization
timer.Simple( 1, function()
        if (!evolve.MapPlugin_GetMaps) then
                evolve:Notify( evolve.colors.red, "YOU MUST HAVE THE MAP LIST PLUGIN ('sh_mapslist.lua') TO USE THIS PLUGIN!" )
                return
        end
        PLUGIN:Load()
end)

-- Update the time for all players every 10 minutes
timer.Create( "Evolve_UpdateMapCycle", 600, 0, function() PLUGIN:Update() end )

if (CLIENT) then
        surface.CreateFont( "Trebuchet36", {
                font = "Trebuchet18",
                size = 36,
                weight = 500,
                blursize = 0,
                scanlines = 0,
                antialias = true,
                underline = false,
                italic = false,
                strikeout = false,
                symbol = false,
                rotary = false,
                shadow = false,
                additive = false,
                outline = false
        } )

        function PLUGIN:HUDPaint()
                if (self.Enabled) then
                        local nextmap = self.Maps[1]
                        if (nextmap and nextmap != "" and self.ChangeAt and self.ChangeAt != -1) then

                               
                                local t = math.max(self.ChangeAt-RealTime(),0)
                                local hour = math.floor(t/3600)
                                local minute = math.floor(t/60)-(60*hour)
                                local second = math.floor(t - hour * 3600 - minute*60)
                               
                                local r = 0
                               
                               
                                if (t < 300) then
                                        r = 127.5 + math.cos(RealTime() * 3) * 127.5
                                       
                                        if t < 60 then
                                                surface.SetDrawColor( Color(255, 0, 0, 150 + math.sin( RealTime() * 4 ) * 80) )
                                                surface.DrawRect( 0, 0, ScrW(), ScrH() )
                                                surface.SetFont( "Trebuchet36" )
                                                surface.SetTextColor( Color(0,0,0,255) )
                                                local str = string.format( "MAP WILL CHANGE IN %02d! SAVE YOUR STUFF", second )
                                                local w,h = surface.GetTextSize( str )
                                                surface.SetTextPos( ScrW()/2 - w/2, ScrH()/2 - h/2 - 40 )
                                                surface.DrawText( str )
                                                if not self.Warned then
                                                        surface.PlaySound( "ambient/alarms/alarm_citizen_loop1.wav" )
                                                        self.Warned = true
                                                end
                                        elseif self.Warned then
                                                self.Warned = nil
                                        end
                                end
                               
                                surface.SetFont( "ScoreboardText" )
                               
                                local str1 = "Next map: " .. nextmap
                                local str2 = string.format( "Time left: %02d:%02d:%02d",hour,minute,second)
                               
                                local w1, h1 = surface.GetTextSize( str1 )
                                local w2, h2 = surface.GetTextSize( str2 )
                               
                                local w, h = math.max( w1, w2 ) + 24, h1+h2+6
                                local x, y = ScrW() / 2 - w / 2, 44 - h / 2
                               
                                draw.RoundedBox( 6, x, y, w, h, Color(r, 0, 0, 200) )
                               
                                surface.SetTextColor( Color(255,255,255,255) )
                                surface.SetTextPos( x + w/2 - w1/2, y + 2 )
                                surface.DrawText( str1 )
                                surface.SetTextPos( x + w/2 - w2/2, y + 4 + h1 )
                                surface.DrawText( str2 )
                        end
                end
        end
end

function evolve:MapCyclePlugin_GetMaps()
        return PLUGIN.Maps
end

evolve:RegisterPlugin( PLUGIN )

