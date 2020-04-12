local PLUGIN = {}
PLUGIN.Title = "Advert3"
PLUGIN.Description = "Add, remove, modify adverts."
PLUGIN.Author = "SariaFace"
PLUGIN.ChatCommand = "advert3"
PLUGIN.Usage = "[add;remove;list;toggle][advert id][r][g][b][interval][message]"
PLUGIN.Privileges = { "Advert 3" }

if (SERVER) then
	local adFileName= "ev_adverts.txt"
	local function writeToFile(data)
		file.Write(adFileName, von.serialize(data))
	end

	adverts = {}
	adverts.Stored = {}
	if (#file.Find(adFileName,"DATA") > 0) then
		adverts.Stored = von.deserialize(file.Read(adFileName,"DATA"))
		for k,v in pairs(adverts.Stored) do
			timer.Create("Advert_"..k, v.Time, 0, function() 
				if (#player.GetAll() > 0) then
					evolve:Notify(v.Colour, v.Msg) 
				end
			end)				
			if (v.OnState == false) then
				timer.Pause("Advert_"..k)
			end
		end
	end


	------------------------------------------------------------------------------------
	function adverts.add(info)
		info[1] = info[1]:lower()
		if #info > 6 then 
			info[6] = table.concat(info, " ", 6, #info)
		elseif #info < 6 then 
			return "Advert: Incorrect arguements for Add" 
		end
		local ow
		if adverts.Stored[info[1]] then 
			ow = "Overwriting advert \""..adverts.Stored[info[1]].."\"." 
		end
		
		adverts.Stored[info[1]] = {
			["Colour"] = Color(tonumber(info[2]),tonumber(info[3]),tonumber(info[4])),
			["Time"] = info[5],
			["Msg"] = info[6],
			["OnState"] = true
		}
		timer.Create("Advert_"..info[1], adverts.Stored[info[1]].Time, 0, function()
			if (#player.GetAll() > 0) then
				evolve:Notify(adverts.Stored[info[1]].Colour, adverts.Stored[info[1]].Msg)
			end
		end)
		writeToFile(adverts.Stored)
		return ow or "Advert created."
	end
	----------------------------------------------------------------------------------------
	function adverts.remove(info)
		if adverts.Stored[info[1]] then
			adverts.Stored[info[1]] = nil
			timer.Remove("Advert_"..info[1])
		else
			return "Advert: ID not found."
		end
		writeToFile(adverts.Stored)
		return "Advert: "..info[1].." has been removed."
	end
	-------------------------------------------------------------------------------------------
	function adverts.list()
		local str = "Registered adverts: "
		for k,v in pairs(adverts.Stored) do
			str = str..k.." On-"..tostring(v.OnState)..". "
		end
		return str or "No adverts loaded."
	end
	--------------------------------------------------------------------------------------------
	function adverts.toggle(args)
		if #args > 2 then return "Advert: Incorrect arguements for toggling" end
		if adverts.Stored[args[1]:lower()] then
			if !args[2] then
				adverts.Stored[args[1]].OnState= !adverts.Stored[args[1]].OnState
				timer.Toggle("Advert_"..args[1])
			elseif (args[2]=="1") then
				adverts.Stored[args[1]].OnState = true
				timer.UnPause("Advert_"..args[1])
			else
				adverts.Stored[args[1]].OnState = false
				timer.Pause("Advert_"..args[1])
			end
			return "Advert "..args[1].."'s On-State has been set to "..tostring(adverts.Stored[args[1]].OnState)
		else
			return "Advert: ID not found."
		end
	end
end		

--===================================================================================--
function PLUGIN:Call( ply, args )
	if (SERVER) then
		if (ply:EV_HasPrivilege( "Advert 3" )) then
			local retStr
			if #args == 0 then
				evolve:Notify(ply, evolve.colors.red, "Advert Error: No arguements")
				return
			end
			local command = args[1]:lower()
			table.remove(args, 1)
			if adverts[command] then
				retStr = adverts[command](args)
			else
				retStr = "Advert: Incorrect command specified"
			end
			
			evolve:Notify(ply, evolve.colors.red, "Advert: "..retStr)
		else
			evolve:Notify(ply, evolve.colors.red, "You don't not have access to this command")
		end
	end
end
evolve:RegisterPlugin( PLUGIN )