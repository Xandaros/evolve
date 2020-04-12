-- Name: Size
-- Desc: Aw`llows you to see people at different sizes
-- Author: Lixquid

-- Heavily based on Overv's original Scale plugin

local PLUGIN = {}
PLUGIN.Title = "Size"
PLUGIN.Description = "Allows you to see people at different sizes"
PLUGIN.Author = "Lixquid"
PLUGIN.ChatCommand = "size"
PLUGIN.Usage = "<players> <scale>"
PLUGIN.Privileges = { "Size" }

function PLUGIN:RenderScene()
	for _, v in pairs( player.GetAll() ) do
		if v:GetModelScale() != v:GetNetworkedFloat("EV_Size",1) then
			v:SetModelScale( v:GetNetworkedFloat("EV_Size",1) , 0)
		end
	end
end

function PLUGIN:Call( ply, args )
	if ply:EV_HasPrivilege( "Size" ) then
		if #args >= 1 then
			local scale = tonumber( args[ #args ] )
			
			if scale then
				scale = math.Clamp( scale, 0.05, 20 )
				local players = evolve:FindPlayer( args, ply )				
				if #players > 0 then
					for _, pl in pairs( players ) do
						pl:SetNetworkedFloat( "EV_Size", scale )
						pl:SetHull( Vector( -16 * scale, -16 * scale, 0 ), Vector( 16 * scale, 16 * scale, 72 * scale ) )
						pl:SetHullDuck( Vector( -16 * scale, -16 * scale, 0 ), Vector( 16 * scale, 16 * scale, 36 * scale ) )
						pl:SetViewOffset( Vector( 0, 0, 68 * scale ) )
						pl:SetViewOffsetDucked( Vector( 0, 0, 32 * scale ) )
						pl:SetStepSize( scale * 16 ) -- Best Guess, anyone?
						pl:SetCollisionBounds( Vector( -16 * scale, -16 * scale, 0 ), Vector( 16 * scale, 16 * scale, 72 * scale ) )
						pl:SetWalkSpeed( 150 * ( scale + scale + scale ) * 0.33 + 100 )
						pl:SetRunSpeed( 100 * ( scale + scale + scale ) * 0.33 + 400 )
						pl:SetJumpPower( 160 * scale )
						--pl:SetGravity( 1 / scale )
					end
					evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the size of ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " to " .. scale .. "." )
				else
					evolve:Notify( plscale, evolve.colors.red, "No matching players found." )
				end
			else
				evolve:Notify( plscale, evolve.colors.red, "You must specify numeric size parameters!" )
			end
		else
			evolve:Notify( plscale, evolve.colors.red, "You need to specify at least one player and one size parameter!" )
		end
	else
		evolve:Notify( plscale, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:CalcView( ply, origin, angles, fov, nearZ, farZ )
	if ply:GetNetworkedFloat("EV_Size",1) == 1 then return end
	
	local scale = ply:GetNetworkedFloat("EV_Size",1)
	
	origin = origin + Vector( 0, 0, 64 * scale )
end

function PLUGIN:Menu( arg, players )
	if arg then
		table.insert( players, arg )
		RunConsoleCommand( "ev", "size", unpack( players ) )
	else
		return "Size", evolve.category.actions, {
			{ "Default", 1 },
			{ "Giant", 10 },
			{ "Small", 0.7 },
			{ "Tiny", 0.3}
		}
	end
end
evolve:RegisterPlugin( PLUGIN )