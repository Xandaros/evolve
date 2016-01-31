local PLUGIN = {}
PLUGIN.Title = "Third Person"
PLUGIN.Description = "Allows players to toggle third person view."
PLUGIN.Author = "Alan Edwardes"
PLUGIN.ChatCommand = "thirdperson"
PLUGIN.Usage = "[1/0]"
PLUGIN.Privileges = { "Third Person" }
function PointDir( from, to)
	local ang = to - from
	return ang:Angle()
end
function PLUGIN:CalcView( ply, pos, angles, fov )
	if ply.EV_ThirdPerson then
			local tracev = ply:GetEyeTrace()
			ply.EV_TP_LookPos = tracev.HitPos
			tmporigin = pos-(angles:Forward()*50)+(angles:Right()*40)
			if angles.y>0 then
				origangle = Angle( angles.p, angles.y+39, angles.r)
			else
				origangle = Angle( angles.p, angles.y-39, angles.r)
			end
			tmpangles = PointDir(pos-(angles:Forward()*50)+(angles:Right()*40), ply.EV_TP_LookPos)
			if ply.EV_ViewAngle then
			
				if ply.EV_ViewAngle.p<0 and tmpangles.p>0 then
					ply.EV_ViewAngle.p=ply.EV_ViewAngle.p+360
				end
				if ply.EV_ViewAngle.p>0 and tmpangles.p<0 then
					ply.EV_ViewAngle.p=ply.EV_ViewAngle.p-360
				end
				if ply.EV_ViewAngle.y<0 and tmpangles.y>0 then
					ply.EV_ViewAngle.y=ply.EV_ViewAngle.y+360
				end
				if ply.EV_ViewAngle.y>0 and tmpangles.y<0 then
					ply.EV_ViewAngle.y=ply.EV_ViewAngle.y-360
				end
				if ply.EV_ViewAngle.r<0 and tmpangles.r>0 then
					ply.EV_ViewAngle.r=ply.EV_ViewAngle.r+360
				end
				if ply.EV_ViewAngle.r>0 and tmpangles.r<0 then
					ply.EV_ViewAngle.r=ply.EV_ViewAngle.r-360
				end
				tmpangles2 = ply.EV_ViewAngle
			else
				tmpangles2 = origangle
				ply.EV_ViewAngle = origangle
			end
			ply.EV_ViewAngle=tmpangles
		--if math.NormalizeAngle(angles.y) > 0 then
			if (math.abs(tmpangles2.y - tmpangles.y)<30 and math.abs(tmpangles2.p - tmpangles.p)<30 and math.abs(tmpangles2.r - tmpangles.r)<30 ) then
				return {
					origin = tmporigin,
					angles = Angle((tmpangles.p + tmpangles2.p)/2,(tmpangles.y + tmpangles2.y)/2,(tmpangles.r + tmpangles2.r)/2),
					fov = fov
					}
			else
				return {
					origin = tmporigin,
					angles = Angle((tmpangles.p),(tmpangles.y ),(tmpangles.r )),
					fov = fov
					}
			end
		--else
			--return {
			--	origin = pos-(angles:Forward()*50)+(angles:Right()*40),
			--	angles = angles:RotateAroundAxis(angles:Up(),-39),
			--	fov = fov
			--}
		--end
	end
end

function PLUGIN:ShouldDrawLocalPlayer( ply )
	if ply.EV_ThirdPerson then return true end
end

function PLUGIN:PlayerInitialSpawn( ply )
	timer.Create("SetThirdPersonViewLoadIn", 5, 1, function()
		--[[
			For some reason you can't add to the player
			table before the player has completely loaded
			in, so delay it 5 seconds.
		]]--
		if ply then
			self:SetThirdPersonView( ply, ply:GetProperty( "ThirdPersonView" ) )
		end
	end )
end

function PLUGIN:SetThirdPersonView( ply, setting )
	if setting ~= nill then
		ply:SendLua("LocalPlayer().EV_ThirdPerson = " .. tostring(setting) )
	end
end

function PLUGIN:Call( ply, args )
	if ply:EV_HasPrivilege( "Third Person" ) then
		if args[1] == "0" then
			ply:SetProperty( "ThirdPersonView", false )
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " switched to first person view." )
			self:SetThirdPersonView( ply, false )
		else
			ply:SetProperty( "ThirdPersonView", true )
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " switched to third person view." )
			self:SetThirdPersonView( ply, true )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )

local PLUGIN = {}
PLUGIN.Title = "First Person"
PLUGIN.Description = "So players can just type !firstperson to return to normal."
PLUGIN.Author = "Alan Edwardes"
PLUGIN.ChatCommand = "firstperson"

function PLUGIN:Call( ply, args )
	ply:SetProperty( "ThirdPersonView", false )
	evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " switched to first person view." )
	ply:SendLua( "LocalPlayer().EV_ThirdPerson = false" )
end

evolve:RegisterPlugin( PLUGIN )