/*-------------------------------------------------------------------------------------------------------------------------
        Get maps and gamemodes for use in the maps tab
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Get Maps"
PLUGIN.Description = "Gets all maps on the server and sends them to the client for use in other plugins."
PLUGIN.Author = "Divran"
PLUGIN.ChatCommand = nil
PLUGIN.Usage = nil
PLUGIN.Maps = {}
PLUGIN.Maps_Inverted = {}
PLUGIN.Gamemodes = {}
PLUGIN.Gamemodes_Inverted = {}

if (SERVER) then
        function PLUGIN:GetMaps()
                self.Maps = {}
                self.Gamemodes = {}
               
                local files, _ = file.Find( "maps/*.bsp", "GAME" )
                for k, filename in pairs( files ) do
                        self.Maps[k] = filename:gsub( "%.bsp$", "" )
                        self.Maps_Inverted[self.Maps[k]] = k
                end
               
                local _, folders = file.Find( "gamemodes/*", "GAME" )
                for k, foldername in pairs( folders ) do
                        self.Gamemodes[k] = foldername
                        self.Gamemodes_Inverted[foldername] = k
                end
        end
        PLUGIN:GetMaps()
       
        util.AddNetworkString("ev_sendmaps")

        function PLUGIN:PlayerInitialSpawn( ply )
                timer.Simple( 2, function()
                        if IsValid(ply) then
                                net.Start( "ev_sendmaps" )
                                        net.WriteTable( self.Maps )
                                        net.WriteTable( self.Gamemodes )
                                net.Send( ply )
                        end
                end)
        end
			concommand.Add( "ev_changemapandgamemode", function( ply, command, args )
			if ( ply:EV_HasPrivilege("Map changing") ) then
				local mapc = args[1]
				local gamemodec = args[2]
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has changed the map to ", evolve.colors.red, mapc, evolve.colors.white, " and gamemode to ", evolve.colors.red, gamemodec, evolve.colors.white, "." )
				timer.Simple( 0.5, function() RunConsoleCommand("gamemode", gamemodec) end)
				timer.Simple( 0.55, function() RunConsoleCommand("changelevel", mapc) end)
			else
				evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
			end
		end)
else
        function PLUGIN.RecieveMaps( len )
                PLUGIN.Maps = net.ReadTable()
                PLUGIN.Gamemodes = net.ReadTable()
        end
        net.Receive("ev_sendmaps", PLUGIN.RecieveMaps)
end

function evolve:MapPlugin_GetMaps()
        return PLUGIN.Maps, PLUGIN.Maps_Inverted
end

function evolve:MapPlugin_GetGamemodes()
        return PLUGIN.Gamemodes, PLUGIN.Gamemodes_Inverted
end
       

evolve:RegisterPlugin( PLUGIN )

