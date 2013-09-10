/*-------------------------------------------------------------------------------------------------------------------------
	Message of the Day
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "MOTD"
PLUGIN.Description = "Message of the Day."
PLUGIN.Author = "Divran"
PLUGIN.ChatCommand = "motd"
PLUGIN.Usage = nil
PLUGIN.Privileges = nil

function PLUGIN:Call(ply, args)
	self:OpenMotd(ply)
end

function PLUGIN:PlayerInitialSpawn(ply)
	timer.Simple(1, function() ply:ConCommand("evolve_startmotd") end)
end

function PLUGIN:OpenMotd(ply)
	if (SERVER) then
		ply:ConCommand("evolve_motd")
	end
end

if (SERVER) then 
	if file.Exists("evolvemotd.txt", "DATA") then
		resource.AddFile("data/evolvemotd.txt")
	end

	for k,v in pairs(player.GetAll()) do
		v:ConCommand("evolve_startmotd")
	end
end


if (CLIENT) then
	function PLUGIN:CreateMenu()
		self.StartPanel = vgui.Create("DFrame")
		local w,h = 150,50
		self.StartPanel:Center()
		self.StartPanel:SetSize(w, h)
		self.StartPanel:SetTitle("Welcome!")
		self.StartPanel:SetVisible(false)
		self.StartPanel:SetDraggable(true)
		self.StartPanel:ShowCloseButton(false)
		self.StartPanel:SetDeleteOnClose(false)
		self.StartPanel:SetScreenLock(true)
		self.StartPanel:MakePopup()
		
		self.OpenButton = vgui.Create("DButton", self.StartPanel)
		self.OpenButton:SetSize(150 / 2 - 4, 20)
		self.OpenButton:SetPos(2, 25)
		self.OpenButton:SetText("Open MOTD")
		self.OpenButton.DoClick = function()
			PLUGIN.MotdPanel:SetVisible(true)
			PLUGIN.StartPanel:SetVisible(false) 
		end
		
		self.CloseButton = vgui.Create("DButton",self.StartPanel)
		self.CloseButton:SetSize(150 / 2 - 6, 20)
		self.CloseButton:SetPos(150 / 2 + 4, 25)
		self.CloseButton:SetText("Close")
		self.CloseButton.DoClick = function() 
			PLUGIN.StartPanel:SetVisible(false) 
		end
		
		self.MotdPanel = vgui.Create("DFrame")
		local w,h = ScrW() - 200,ScrH() - 200
		self.MotdPanel:SetPos(100, 100)
		self.MotdPanel:SetSize(w, h)
		self.MotdPanel:SetTitle("MOTD")
		self.MotdPanel:SetVisible(false)
		self.MotdPanel:SetDraggable(false)
		self.MotdPanel:ShowCloseButton(true)
		self.MotdPanel:SetDeleteOnClose(false)
		self.MotdPanel:SetScreenLock(true)
		self.MotdPanel:MakePopup()
		
		self.MotdBox = vgui.Create("HTML", self.MotdPanel)
		self.MotdBox:StretchToParent(4, 25, 4, 4)
		self.MotdBox:SetHTML(file.Read("evolvemotd.txt"))
	end
	
	concommand.Add("evolve_motd", function(ply,cmd,args)
		if file.Exists("evolvemotd.txt", "DATA") then
			PLUGIN.MotdPanel:SetVisible(true)
		end
	end)
	
	concommand.Add("evolve_startmotd", function(ply,cmd,args)
		if file.Exists("evolvemotd.txt", "DATA") then
			if not PLUGIN.StartPanel then PLUGIN:CreateMenu() end
			PLUGIN.StartPanel:SetVisible(true)
		end
	end)
	
end

evolve:RegisterPlugin(PLUGIN)