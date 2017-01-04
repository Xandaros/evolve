--[[
Requires that sh_advert.lua be installed. 
Usage of the menu requires both "Advert 3" and "Advert 3 Menu" privileges be set to your rank.
ReSync button allows for variations from the server's advert list and the client's advert list.

Any problems, let me know! thatcutekiwi@gmail.com . Thanks! Saria Parkar <3]]

local TAB = {}
TAB.Title = "Adverts"
TAB.Description = "Add, remove, modify adverts."
TAB.Icon = "feed_edit"
TAB.Author = "SariaFace & EntranceJew"
TAB.Width = 520
TAB.Privileges = { "Advert 3 Menu" }

function SendAdverts(ply)
  local tosend = nil
  if ( SERVER ) and (adverts and #adverts.Stored) then
    tosend = adverts.Stored
  elseif ( CLIENT ) and (adverts) then
    tosend = adverts
  else
    -- well this isn't right
    return false
  end
  
  net.Start("EV_Adverts3")
  net.WriteString("send")
  net.WriteTable(tosend)
    
  if ( SERVER ) and ( IsValid( ply ) and ply:IsPlayer() ) then
    net.Send(ply)
  else
    net.SendToServer()
  end
end

net.Receive( "EV_Adverts3", function( length, ply )
  local mtype = net.ReadString()
  
  if mtype == "get" then
    SendAdverts(ply)
  elseif mtype == "send" then
    local inbound = net.ReadTable()
    if ( SERVER ) then
      adverts.Stored = inbound
    else
      adverts = inbound
    end
  end
end )

if (SERVER) then
  util.AddNetworkString("EV_Adverts3")
else
  local NewAdPanelReg = {}
	function NewAdPanelReg:Setup()
		--Attention: EditAdPanelReg extends this function.
		--If you want to add/change something specific to NewAdPanelReg, do it in NewAdPanelReg:Init() below
			
		self:SetPos( 40, (ScrH()/3)*2)
		self:SetSize(560, 62)
		self:SetTitle("Add new advert")
		self:SetZPos(32767)
		self:DoModal(true)
		
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
		
		self.OnStateCheckbox = vgui.Create("DCheckBox", self)
		self.OnStateCheckbox:SetPos( 456, (self:GetTall()-22))
		self.OnStateCheckbox:SetValue(1)
		
		self.AddBut = vgui.Create( "DButton", self )
		self.AddBut:SetSize( 60, 22 )
		self.AddBut:SetPos( self:GetWide() - 68, (self:GetTall()-26) )
		self.AddBut:SetText( "Add" )
		self.AddBut.DoClick = function()
			if (!tonumber(self.Interval:GetValue()) || tonumber(self.Interval:GetValue())<60) then
				evolve:Notify(LocalPlayer(), evolve.colors.red, "Incorrect Time input, value must be equal or greater than 60!")
				return
			end
			if (#string.Trim(self.Msg:GetValue())==0) then
				evolve:Notify(LocalPlayer(), evolve.colors.red, "A message is required!")
				return
			end
			local newAd = {}
			newAd.Colour = {["r"] = self.ColourR:GetValue(), ["g"] = self.ColourG:GetValue(), ["b"] = self.ColourB:GetValue(), ["a"] = "255"} 
			newAd.Time =  self.Interval:GetValue()
			newAd.Msg = self.Msg:GetValue()
			newAd.OnState = tostring(self.OnStateCheckbox:GetChecked())
			RunConsoleCommand("ev", "advert3", "add", self.IDInput:GetValue(), newAd.Colour["r"], newAd.Colour["g"], newAd.Colour["b"], tostring(newAd.Time), newAd.OnState, newAd.Msg)
			adverts[self.IDInput:GetValue()] = newAd
			timer.Simple(1.0, function() TAB:Update() end)
			self:Remove()
			return true
		end
	end
		
	function NewAdPanelReg:Init()
		self:Setup()
		self:MakePopup()
	end	
	vgui.Register("NewAdPanel", NewAdPanelReg, "DFrame")
	
	--EditAdPanelReg extends NewAdPanelReg
	local EditAdPanelReg = table.Copy(NewAdPanelReg)
	function EditAdPanelReg:Init()
		self:Setup()
		self:SetTitle("Edit advert")
		self.AddBut:SetText( "Update" )
		self.IDInput:SetEditable( false )
		self.IDInput:SetDisabled( true )
		if TAB.AdList:GetSelected() && #TAB.AdList:GetSelected() > 0 then
			local id = TAB.AdList:GetSelected()[1]:GetValue(1)
			self.IDInput:SetValue(id)
			self.ColourR:SetValue(adverts[id].Colour["r"])
			self.ColourG:SetValue(adverts[id].Colour["g"])
			self.ColourB:SetValue(adverts[id].Colour["b"])
			self.Interval:SetValue(adverts[id].Time)
			self.Msg:SetValue(adverts[id].Msg)
			self.OnStateCheckbox:SetValue(adverts[id].OnState)
			
			local DoClick = self.AddBut.DoClick
			self.AddBut.DoClick = function()
				local result = DoClick()
				if(result) then
					TAB.AdList:GetSelected()[1]:SetValue(2, adverts[id].Colour["r"]..","..adverts[id].Colour["g"]..","..adverts[id].Colour["b"])
					TAB.AdList:GetSelected()[1]:SetValue(3, adverts[id].Time)
					TAB.AdList:GetSelected()[1]:SetValue(4, adverts[id].Msg)
					TAB.AdList:GetSelected()[1]:SetValue(5, adverts[id].OnState)
				end
			end
		else
			evolve:Notify(LocalPlayer(), evolve.colors.red, "Nothing selected!")
		end
		self:MakePopup()
	end
	vgui.Register("EditAdPanel", EditAdPanelReg, "DFrame")
end

function TAB:GetAdverts(ply)
  net.Start("EV_Adverts3")
  net.WriteString("get")
  if ( SERVER ) and ( IsValid( ply ) and ply:IsPlayer() ) then
    net.Send(ply)
  else
    net.SendToServer()
  end
end

--===================================================================================--

if(CLIENT) then
	function TAB:Initialize( pnl )
	  adverts = {}
	  
		self.AdList = vgui.Create( "DListView", pnl )
		self.AdList:SetSize( self.Width, pnl:GetParent():GetTall() - 58 )
		self.AdList:SetMultiSelect( false )
		self.AdList:AddColumn( "ID" ):SetFixedWidth( 70 )
		self.AdList:AddColumn( "Colour" ):SetFixedWidth( 70 )
		self.AdList:AddColumn( "Time(s)" ):SetFixedWidth( 40 )
		self.AdList:AddColumn( "Message" ):SetFixedWidth( 302 )
		self.AdList:AddColumn( "Active" ):SetFixedWidth( 32 )

		self.ResyncButton = vgui.Create( "DButton", pnl )
		self.ResyncButton:SetSize( 60, 22 )
		self.ResyncButton:SetPos( self.Width - 340, pnl:GetParent():GetTall() - 53 )
		self.ResyncButton:SetText( "ReSync" )
		self.ResyncButton.DoClick = function()
			self:Request()
		end
		
		self.NewButton = vgui.Create( "DButton", pnl )
		self.NewButton:SetSize( 60, 22 )
		self.NewButton:SetPos( self.Width - 275, pnl:GetParent():GetTall() - 53 )
		self.NewButton:SetText( "New" )
		self.NewButton.DoClick = function()
			newAdInput = vgui.Create("NewAdPanel", pnl)
		end
		
		self.EditButton = vgui.Create( "DButton", pnl )
		self.EditButton:SetSize( 60, 22 )
		self.EditButton:SetPos( self.Width - 210, pnl:GetParent():GetTall() - 53 )
		self.EditButton:SetText( "Edit" )
		self.EditButton:SetDisabled( true )
		self.EditButton.DoClick = function()
			editAdInput = vgui.Create("EditAdPanel", pnl)
		end		
		
		self.ToggleButton = vgui.Create( "DButton", pnl )
		self.ToggleButton:SetSize( 60, 22 )
		self.ToggleButton:SetPos( self.Width - 145, pnl:GetParent():GetTall() - 53 )
		self.ToggleButton:SetText( "Toggle" )
		self.ToggleButton:SetDisabled( true )
		self.ToggleButton.DoClick = function()
			if self.AdList:GetLines() && #self.AdList:GetSelected() > 0 then
				local id = self.AdList:GetSelected()[1]:GetValue(1)
				RunConsoleCommand("ev", "advert3", "toggle", id)
				adverts[id]["OnState"] = !adverts[id]["OnState"]
				self.AdList:GetSelected()[1]:SetValue(5, adverts[id]["OnState"])
			else
				evolve:Notify(LocalPlayer(), evolve.colors.red, "Nothing selected!")
			end
		end
		
		self.RemoveButton = vgui.Create( "DButton", pnl )
		self.RemoveButton:SetSize( 60, 22 )
		self.RemoveButton:SetPos( self.Width - 80, pnl:GetParent():GetTall() - 53 )
		self.RemoveButton:SetText( "Remove" )
		self.RemoveButton:SetDisabled( true )
		self.RemoveButton.DoClick = function()
			if self.AdList:GetSelected() && #self.AdList:GetSelected() > 0 then
				local id = self.AdList:GetSelected()[1]:GetValue(1)
				RunConsoleCommand("ev", "advert3", "remove", id)
				adverts[id] = nil
			end
			self:Update()
		end
		timer.Simple(1.5, function() TAB:Request() end)	
	end

	function TAB:Update()
		local oldSelectedId = 0
		local selectLine
		if self.AdList:GetSelected() && #self.AdList:GetSelected() > 0 then
			oldSelectedId = self.AdList:GetSelected()[1]:GetValue(1)
		end
		self.AdList:Clear()
		for id,data in pairs(adverts) do
			local line = self.AdList:AddLine( id, data.Colour["r"]..","..data.Colour["g"]..","..data.Colour["b"], data.Time, data.Msg, tostring(data.OnState));
			if(id == oldSelectedId ) then
				selectLine = line
			end
		end
		if(#self.AdList:GetLines() > 0) then
			self.EditButton:SetDisabled( false )
			self.ToggleButton:SetDisabled( false )
			self.RemoveButton:SetDisabled( false )
			if(selectLine) then
				self.AdList:SelectItem(selectLine)
			else
				self.AdList:SelectFirstItem()
			end			
		else
			self.EditButton:SetDisabled( true )
			self.ToggleButton:SetDisabled( true )
			self.RemoveButton:SetDisabled( true )
		end
	end

	function TAB:Request()
		self:GetAdverts()
		timer.Simple(2, function() TAB:Update() end)
	end

	function TAB:IsAllowed()
		return LocalPlayer():EV_HasPrivilege( "Advert 3 Menu" )
	end
end
evolve:RegisterTab( TAB )