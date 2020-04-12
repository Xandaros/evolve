/*-------------------------------------------------------------------------------------------------------------------------
	ESP a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "ESP"
PLUGIN.Description = "Give a player ESP."
PLUGIN.Author = "Grey"
PLUGIN.ChatCommand = "esp"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "ESP" }
function PLUGIN:ESP_RandomString( len, numbers, special )
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"..(numbers == true && "1234567890" or "")..(special == true && "!?@#$%^&*[](),.-+={}:;'\"<>|\\" or ""); --You can change the list if you like
	local result = "";
	
	if (len < 1) then
		len = math.random( 10, 20 );
	end
	
	for i = 1, len do
		result = result..string.char( string.byte( chars, math.random( 1, string.len( chars ) ) ) );
	end
	
	return tostring( result );
end
function Func_ESP_RandomString( len, numbers, special )
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"..(numbers == true && "1234567890" or "")..(special == true && "!?@#$%^&*[](),.-+={}:;'\"<>|\\" or ""); --You can change the list if you like
	local result = "";
	
	if (len < 1) then
		len = math.random( 10, 20 );
	end
	
	for i = 1, len do
		result = result..string.char( string.byte( chars, math.random( 1, string.len( chars ) ) ) );
	end
	
	return tostring( result );
end
if !ESP_Mat then
	if !SERVER then
		ESP_Mat = CreateMaterial( string.lower( Func_ESP_RandomString( math.random( 5, 8 ), false, false ) ), "VertexLitGeneric", { ["$basetexture"] = "models/debug/debugwhite", ["$model"] = 1, ["$ignorez"] = 1 } ); --Last minute change
	end
end
if !ESP_Font then
	if !SERVER then
		ESP_Font = "MyEspFont"
		surface.CreateFont( ESP_Font, { font = "Arial", size = 18, weight = 750, antialias = false, outline = true } );
	end
end
function PLUGIN:AddToColor( color, add )
	return color + add <= 255 and color + add or color + add - 255
end
function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "ESP" ) ) then
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
			pl:SetNWBool( "EV_ESPed", enabled )
		end
		
		if ( #players > 0 ) then
			if ( enabled ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has given ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " ESP." )
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has taken ESP from ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, "." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end
function PLUGIN:HUDPaint()
	if ( LocalPlayer():GetNWBool( "EV_ESPed", false ) ) then
		for _, ply in pairs( player.GetAll() ) do
			if (ply != LocalPlayer() && IsValid( ply ) && ply:Alive() && ply:Health() > 0 && ply:Team() != TEAM_SPECTATOR) then
				local min2, max2 = ply:GetRenderBounds();
				local pos = ply:GetPos() + Vector( 0, 0, ( min2.z + max2.z ) );
				local color = Color( 50, 255, 50, 255 );
				
				if ( ply:Health() <= 10 ) then color = Color( 255, 0, 0, 255 );
				elseif ( ply:Health() <= 20 ) then color = Color( 255, 50, 50, 255 );
				elseif ( ply:Health() <= 40 ) then color = Color( 250, 250, 50, 255 );
				elseif ( ply:Health() <= 60 ) then color = Color( 150, 250, 50, 255 ); 
				elseif ( ply:Health() <= 80 ) then color = Color( 100, 255, 50, 255 ); end
				
				pos = ( pos + Vector( 0, 0, 10 ) ):ToScreen();
				cam.Start3D( LocalPlayer():EyePos(), LocalPlayer():EyeAngles() );
					render.SuppressEngineLighting( true );
					render.SetColorModulation( color.r/255, color.g/255, color.b/255, 1 );
					if ESP_Mat then
						render.MaterialOverride( ESP_Mat );
					else
						ESP_Mat = CreateMaterial( string.lower( "ASDFWTFBBQ" ), "VertexLitGeneric", { ["$basetexture"] = "models/debug/debugwhite", ["$model"] = 1, ["$ignorez"] = 1 } ); --Last minute change
						render.MaterialOverride( ESP_Mat );
					end
					ply:DrawModel();
					render.SetColorModulation( self:AddToColor( color.r, 150 )/255, self:AddToColor( color.g, 150 )/255, self:AddToColor( color.b, 150 )/255, 1 );
					
					if (IsValid( ply:GetActiveWeapon() )) then
						ply:GetActiveWeapon():DrawModel() 
					end
					
					render.SetColorModulation( 1, 1, 1, 1 );
					
					--render.MaterialOverride();
					render.SetModelLighting( 4, color.r/255, color.g/255, color.b/255 );
					ply:DrawModel();
					render.MaterialOverride();
					render.SuppressEngineLighting( false );
				cam.End3D();
				local color = team.GetColor( ply:Team( ) );
				local width, height = surface.GetTextSize( tostring( ply:Nick() ) ); -- I have to do tostring because sometimes errors would occur
				draw.DrawText( ply:Nick(), ESP_Font, pos.x, pos.y-height/2, color, 1 );
				if ( ply:GetNetworkedString( "UserGroup" ) != "user" ) then
					local width, height = surface.GetTextSize( ply:GetNetworkedString( "UserGroup" ) );
					draw.DrawText( ply:GetNetworkedString( "UserGroup" ), ESP_Font, pos.x, pos.y-height-14, Color( 255, 200, 50, 255 ), 1 );
				end
				if (IsValid( ply:GetActiveWeapon() )) then
					local width, height = surface.GetTextSize( ply:GetActiveWeapon():GetPrintName() or ply:GetActiveWeapon():GetClass() );
					draw.DrawText( ply:GetActiveWeapon():GetPrintName() or ply:GetActiveWeapon():GetClass(), ESP_Font, pos.x, pos.y+14, Color( 255, 200, 50 ), 1 );
				end
			end
		end
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "esp", unpack( players ) )
	else
		return "esp", evolve.category.punishment, { { "Enable", 1 }, { "Disable", 0 } }
	end
end

evolve:RegisterPlugin( PLUGIN )