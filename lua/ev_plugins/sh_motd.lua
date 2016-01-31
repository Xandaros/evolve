-- Remember to create the ev_motd.txt in the data folder and add the contents!!

local PLUGIN = {}
PLUGIN.Title = "MOTD2"
PLUGIN.Description = "Better MOTD"
PLUGIN.Author = "Grey"
PLUGIN.ChatCommand = "motd"
PLUGIN.Usage = nil
PLUGIN.Privileges = { "Skip MOTD" }
MOTD_ENABLED = true;
MOTD_ACCEPT_WAIT = 5;
MOTD_DECLINE_CONFIRMATION = true;
_window = nil

if SERVER then
	util.AddNetworkString( "MOTD2Packet" )
else
	ReceivedMOTD = false
end
function PLUGIN:Call( ply, args )
	self:OpenMotd2( ply )

end

function MOTDPlayerInitialSpawn( ply )
	if (file.Exists("evolve_motd/ev_motd.txt", "DATA")) then
		timer.Create("MOTD2TimerFor"..ply:Nick(),3,3,function() 
		net.Start( "MOTD2Packet" )
		local tmpstr = file.Read("evolve_motd/ev_motd.txt", "DATA")
		if tmpstr then
			net.WriteString( tmpstr )
		else
			net.WriteString( "Bad MOTD" )
		end
		net.Send( ply)
		end)
	else 
		Msg("\n")
		Msg("====================== \n")
		Msg("Missing MOTD file! \n")
		Msg("Make sure the file exists as: ev_motd.txt in data/evolve_motd/! \n")
		Msg("====================== \n")
		Msg("\n")
	end
	--timer.Simple( 7, function() ply:ConCommand("ev_motd2") end)
end
if SERVER then
	hook.Add("PlayerInitialSpawn", "playerInitialSpawn", MOTDPlayerInitialSpawn)
end
function PLUGIN:OpenMotd2( ply )
	if (SERVER) then
		ply:ConCommand("ev_motd2")
	else
		LocalPlayer():ConCommand("ev_motd2")
	end
end
if (SERVER) then 
	if (file.Exists("evolve_motd/ev_motd.txt", "DATA")) then
		print("Received Valid MOTD2")
	else
		Msg("\n")
		Msg("====================== \n")
		Msg("Missing MOTD file! \n")
		Msg("Make sure the file exists as: ev_motd.txt in data/evolve_motd/! \n")
		Msg("====================== \n")
		Msg("\n")
	end
end


if (CLIENT) then
	net.Receive( "MOTD2Packet" , function( length )
		local motdstr = net.ReadString()
		if (ReceivedMOTD == true) then
		return;
		end
		ReceivedMOTD = true
		local MOTD_HTML = ""
		if (tonumber(length)>0) then
			MOTD_HTML = motdstr
			print("Valid MOTD Received in MOTD2 Plugin")
		else
			print("No MOTD Given.")
			MOTD_HTML = ""
		end
		if ( !MOTD_ENABLED ) then return; end
			local _w = ScrW( );
			local _h = ScrH( );

			_window = vgui.Create( "DPanel" );
			local _html = vgui.Create( "HTML", _window );

			local _accept = vgui.Create( "DButton", _window );
			_accept:SetText( "#Accept " .. " ( " .. MOTD_ACCEPT_WAIT .. " ) " )
			_accept:SetWide( _accept:GetWide( ) * 1.5 )
			_accept:SetTooltip( "I agree to the terms and conditions." )
			_accept.DoClick = function()
				print("Accepted MOTD")
				_window:ClosePanel( );
			end

			local _decline = vgui.Create( "DButton", _window );
			_decline:SetText( "#Decline" )
			_decline:SetWide( _decline:GetWide( ) * 1.5 )
			_decline:SetTooltip( "I do not agree to the terms and conditions and I agree to remove any and all content and associated files of this game-mode from my PC." )
			_decline.DoClick = function()
				RunConsoleCommand( "disconnect" );
			end
			
			//
			// Hack to fix ClosePanel
			//
			_window.ClosePanel = function( )
				--_decline:Remove( );
				--_decline = nil;
				--_accept:Remove( );
				--_accept = nil;
				--_html:Remove( );
				--_html = nil;
				_window:SetVisible( false );
				--_window:Remove( );
				--_window = nil;
			end


			_window:SetSize( _w - _w / 3, _h - _h / 3 );
			_window:Center( );
			-- _window:SetPos( _w / 2, -_h )
			-- _window:MoveTo( _w / 2, _h / 4, 1 );

			_html:SetPos( 0, 0 );
			_html:SetSize( _window:GetWide( ), _window:GetTall( ) - 30 )

			_accept:SetPos( ( _window:GetWide( ) / 2 ) - _accept:GetWide( ), _window:GetTall( ) - 25 );
			_decline:SetPos( ( _window:GetWide( ) / 2 ) + _decline:GetWide( ), _window:GetTall( ) - 25 );

			_html:SetHTML( MOTD_HTML );
			
			if ( MOTD_ACCEPT_WAIT && MOTD_ACCEPT_WAIT > 0 ) then
				_accept:SetDisabled( true );
				for i = 1, MOTD_ACCEPT_WAIT do
					timer.Simple( i, function( )
						if ( MOTD_ACCEPT_WAIT - i == 0 ) then
							_accept:SetText( "#Accept" )
						else
							_accept:SetText( "#Accept" .. " ( " .. MOTD_ACCEPT_WAIT - i .. " ) " )
						end
					end )
				end
				timer.Simple( MOTD_ACCEPT_WAIT, function( )
					_accept:SetDisabled( false );
				end )
			end
			_window:SetVisible( true );
			_window:MakePopup( );
			if LocalPlayer():EV_HasPrivilege( "Skip MOTD" ) then
				_window:ClosePanel( )
			end

	end)
	concommand.Add("ev_motd2",function(ply,cmd,args)
	if _window then
		_window:SetVisible( true )
	end
	end)
	function MOTDHook()
		ply2=LocalPlayer()
		ply2:ConCommand("ev_motd2")
	end
	hook.Add( "MOTD", "MOTD", MOTDHook)
	concommand.Add( "motd", function( ) hook.Call( "MOTD", GAMEMODE ); end );
	concommand.Add( "rules", function( ) hook.Call( "MOTD", GAMEMODE ); end );
	concommand.Add( "tos", function( ) hook.Call( "MOTD", GAMEMODE ); end );
	concommand.Add( "eula", function( ) hook.Call( "MOTD", GAMEMODE ); end );
	concommand.Add( "terms", function( ) hook.Call( "MOTD", GAMEMODE ); end );
end

evolve:RegisterPlugin( PLUGIN )