/*
Requires that sh_advert.lua be installed. 
Usage of the menu requires both "Advert 3" and "Advert 3 Menu" privileges be set to your rank.
ReSync button allows for variations from the server's advert list and the client's advert list.

Any problems, let me know! thatcutekiwi@gmail.com . Thanks! Saria Parkar <3

local TAB = {}
TAB.Title = "Adverts"
TAB.Description = "Add, remove, modify adverts."
TAB.Icon = "gui/silkicons/page_white_wrench"
TAB.Author = "SariaFace"
TAB.Width = 520
TAB.Privileges = { "Advert 3 Menu" }

if (SERVER) then
	function SendAdvertsList(target, cmd, args)
		if (target) then
			if (adverts and #adverts.Stored) then
				datastream.StreamToClients(target, "EV_Adverts3_ReceiveList", adverts.Stored)
			end
		end
	end
	concommand.Add("EV_Adverts3_RequestList", SendAdvertsList)
else
	local NewAdPanelReg = {}
	function NewAdPanelReg:Init()
		self:SetPos( 40, (ScrH()/3)*2)
		self:SetSize(560, 62)
		self:SetTitle("Add new advert")
		self:MakePopup()
		self:SetZPos(999999)
		
		self.IDLabel = vgui.Create("DLabel", self)
		self.IDLabel:SetText("ID")
		self.IDLabel:SetPos(37, 20)
		self.IDInput = vgui.Create("DTextEntry", self)
		self.IDInput:SetPos(2, (self:GetTall()-24))
		self.IDInput:SetSize(70, 20)
		self.IDInput.OnLoseFocus = function() self.IDInput:SetValue(self.IDInput:GetValue():lower()) end
		
		self.ColourRLabel = vgui.Create("DLabel", self)
		self.ColourRLabel:SetText("R")
		self.ColourRLabel:SetPos(85, 20)
		self.ColourR = vgui.Create("DTextEntry", self)
		self.ColourR:SetSize(24, 20)
		self.ColourR:SetPos(74, (self:GetTall()-24))
		self.ColourR:SetValue("255")
		self.ColourR:SetTextColor(Color(255,0,0,255))
		self.ColourR.OnGetFocus = function() self.ColourR:SelectAll() end
		self.ColourR.OnLoseFocus = function() if (string.len(self.ColourR:GetValue()) == 0) then self.ColourR:SetValue("0") end end
		self.ColourR.OnTextChanged = function()
			if ((string.len(self.ColourR:GetValue()) > 0 and !tonumber(self.ColourR:GetValue())) or string.len(self.ColourR:GetValue()) > 3) then
				self.ColourR:SetValue("255")
			end
		end
		self.ColourGLabel = vgui.Create("DLabel", self)
		self.ColourGLabel:SetText("G")
		self.ColourGLabel:SetPos(109, 20)
		self.ColourG = vgui.Create("DTextEntry", self)
		self.ColourG:SetSize(24, 20)
		self.ColourG:SetPos(100, (self:GetTall()-24))
		self.ColourG:SetValue("255")
		self.ColourG:SetTextColor(Color(0,155,0,255))
		self.ColourG.OnGetFocus = function() self.ColourG:SelectAll() end
		self.ColourG.OnLoseFocus = function() if (string.len(self.ColourG:GetValue()) == 0) then self.ColourG:SetValue("0") end end
		self.ColourG.OnTextChanged = function()
			if ((string.len(self.ColourG:GetValue()) > 0 and !tonumber(self.ColourG:GetValue())) or string.len(self.ColourG:GetValue()) > 3) then
				self.ColourG:SetValue("255")
			end
		end
		self.ColourBLabel = vgui.Create("DLabel", self)
		self.ColourBLabel:SetText("B")
		self.ColourBLabel:SetPos(136, 20)
		self.ColourB = vgui.Create("DTextEntry", self)
		self.ColourB:SetSize(24, 20)
		self.ColourB:SetPos(126, (self:GetTall()-24))
		self.ColourB:SetValue("255")
		self.ColourB:SetTextColor(Color(0,0,255,255))
		self.ColourB.OnGetFocus = function() self.ColourB:SelectAll() end
		self.ColourB.OnLoseFocus = function() if (string.len(self.ColourB:GetValue()) == 0) then self.ColourB:SetValue("0") end end
		self.ColourB.OnTextChanged = function()
			if ((string.len(self.ColourB:GetValue()) > 0 and !tonumber(self.ColourB:GetValue())) or string.len(self.ColourB:GetValue()) > 3) then
				self.ColourB:SetValue("255")
			end
		end
		
		self.ColourIntLabel = vgui.Create("DLabel", self)
		self.ColourIntLabel:SetText("Time(s)")
		self.ColourIntLabel:SetPos(155, 20)
		self.Interval = vgui.Create("DTextEntry", self)
		self.Interval:SetPos(152, (self:GetTall()-24))
		self.Interval:SetSize(40, 20)
		self.Interval:SetValue("60")
		self.Interval.OnGetFocus = function() self.Interval:SelectAll() end
		self.ColourB.OnLoseFocus = function() if (string.len(self.Interval:GetValue()) == 0) then self.Interval:SetValue("60") end end
		self.Interval.OnTextChanged = function()
			if (string.len(self.Interval:GetValue()) > 0 and !tonumber(self.Interval:GetValue())) then
				self.Interval:SetValue("60")
			end
		end
		
		self.ColourMsgLabel = vgui.Create("DLabel", self)
		self.ColourMsgLabel:SetText("Message")
		self.ColourMsgLabel:SetPos(310, 20)
		self.Msg = vgui.Create("DTextEntry", self)
		self.Msg:SetPos(194, (self:GetTall()-24))
		self.Msg:SetSize(260, 20)
		
		self.AddBut = vgui.Create( "DButton", self )
		self.AddBut:SetSize( 60, 22 )
		self.AddBut:SetPos( self:GetWide() - 68, (self:GetTall()-26) )
		self.AddBut:SetText( "Add" )
		self.AddBut.DoClick = function()
			if (!tonumber(self.Interval:GetValue())) then
				evolve:Notify(LocalPlayer(), evolve.colors.red, "Incorrect Time input!")
				self:Remove()
				return
			end
			local newAd = {}
			newAd.Colour = {["r"] = self.ColourR:GetValue(), ["g"] = self.ColourG:GetValue(), ["b"] = self.ColourB:GetValue(), ["a"] = "255"} 
			newAd.Time =  self.Interval:GetValue()
			newAd.Msg = self.Msg:GetValue()
			newAd.OnState = true
			RunConsoleCommand("ev", "advert3", "add", self.IDInput:GetValue(), newAd.Colour["r"], newAd.Colour["g"], newAd.Colour["b"], tostring(newAd.Time), newAd.Msg)
			adverts[self.IDInput:GetValue()] = newAd
			timer.Simple(1.0, function() TAB:Update() end)
			self:Remove()
		end
		
	end
	vgui.Register("NewAdPanel", NewAdPanelReg, "DFrame")
	
	adverts = {}
	function SyncAdverts(hdl, id, enc, dec)
		adverts = dec
	end
	datastream.Hook("EV_Adverts3_ReceiveList", SyncAdverts)
	RunConsoleCommand("EV_Adverts3_RequestList")
end
--===================================================================================--
function TAB:Initialize( pnl )
	self.AdList = vgui.Create( "DListView", pnl )
	self.AdList:SetSize( self.Width, pnl:GetParent():GetTall() - 58 )
	self.AdList:SetMultiSelect( false )
	self.AdList:AddColumn( "ID" ):SetFixedWidth( 70 )
	self.AdList:AddColumn( "Colour" ):SetFixedWidth( 70 )
	self.AdList:AddColumn( "Time(s)" ):SetFixedWidth( 40 )
	self.AdList:AddColumn( "Message" ):SetFixedWidth( 308 )
	self.AdList:AddColumn( "Active" ):SetFixedWidth( 32 )

	self.New = vgui.Create( "DButton", pnl )
	self.New:SetSize( 60, 22 )
	self.New:SetPos( self.Width - 275, pnl:GetParent():GetTall() - 53 )
	self.New:SetText( "ReSync" )
	self.New.DoClick = function()
		self:Request()
	end
	
	self.New = vgui.Create( "DButton", pnl )
	self.New:SetSize( 60, 22 )
	self.New:SetPos( self.Width - 210, pnl:GetParent():GetTall() - 53 )
	self.New:SetText( "New" )
	self.New.DoClick = function()
		local newAdInput = vgui.Create("NewAdPanel")
	end
	
	self.Tog = vgui.Create( "DButton", pnl )
	self.Tog:SetSize( 60, 22 )
	self.Tog:SetPos( self.Width - 145, pnl:GetParent():GetTall() - 53 )
	self.Tog:SetText( "Toggle" )
	self.Tog.DoClick = function()
		local id = self.AdList:GetSelected()[1]:GetValue(1)
		RunConsoleCommand("ev", "advert3", "toggle", id)
		adverts[id]["OnState"] = !adverts[id]["OnState"]
		self.AdList:GetSelected()[1]:SetValue(5, adverts[id]["OnState"])
	end
	
	self.Rem = vgui.Create( "DButton", pnl )
	self.Rem:SetSize( 60, 22 )
	self.Rem:SetPos( self.Width - 80, pnl:GetParent():GetTall() - 53 )
	self.Rem:SetText( "Remove" )
	self.Rem.DoClick = function()
		local id = self.AdList:GetSelected()[1]:GetValue(1)
		RunConsoleCommand("ev", "advert3", "remove", id)
		adverts[id] = nil
		self:Update()
	end
	timer.Simple(1.5, function() TAB:Update() end)	
end

function TAB:Update()
	self.AdList:Clear()
	for id,data in pairs(adverts) do
		local line = self.AdList:AddLine( id, data.Colour["r"]..","..data.Colour["g"]..","..data.Colour["b"], data.Time, data.Msg, data.OnState);
	end
	self.AdList:SelectFirstItem()
end

function TAB:Request()
	RunConsoleCommand("EV_Adverts3_RequestList")
	timer.Simple(2, function() TAB:Update() end)
end

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Advert 3 Menu" )
end
evolve:RegisterTab( TAB )