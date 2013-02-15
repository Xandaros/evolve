/*-------------------------------------------------------------------------------------------------------------------------
	Start a vote
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Vote"
PLUGIN.Description = "Start a vote."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "vote"
PLUGIN.Usage = '"question" "option1" "option2" ...'
PLUGIN.Privileges = { "Vote" }

function PLUGIN:GetArguments( str )
	local args = {}
	for arg in string.gmatch( str, '"([^"]+)"' ) do
		table.insert( args, arg )
	end
	return args
end

function PLUGIN:Initialize()
	util.AddNetworkString("EV_VoteEnd")
	util.AddNetworkString("EV_VoteMenu")
	util.AddNetworkString("EV_DoVote")
end

function PLUGIN:VoteEnd()
	evolve:SendNetMessage( "EV_VoteEnd", nil )
	
	local percentages = {}
	local absolutes = {}
	for i = 1, #self.Options do
		local percent
		if ( table.Count( self.Votes ) == 0 ) then
			percent = 0 else percent = math.Round( ( self.Votes[i] or 0 ) / self.VotingPlayers * 100 )
		end
		
		percentages[i] = percent
		absolutes[i] = self.Votes[i]
	end
	
	self.Callback(percentages, absolutes)
	
	self.Question = nil
	for _, pl in ipairs( player.GetAll() ) do
		pl.EV_Voted = nil
	end
end

function PLUGIN:VoteStart(question, options, callback)
	self.Question = question
	self.Options = options
	self.Votes = {}
	self.PlayerVotes = {}
	self.VotingPlayers = 0
	self.Callback = callback
	
	net.Start( "EV_VoteMenu" )
		net.WriteString( self.Question )
		net.WriteUInt( #self.Options, 8 )
		for _, option in ipairs( self.Options ) do
			net.WriteString( option )
		end
	net.Broadcast()
		
	timer.Create( "EV_VoteEnd", 10, 1, function() PLUGIN:VoteEnd() end )
end

function PLUGIN:Call( ply, _, argstr )
	if ( ply:EV_HasPrivilege( "Vote" ) ) then
		if ( self.Question ) then
			evolve:Notify( ply, evolve.colors.red, "You can't start a new vote until the current one has finished!" )
			return
		elseif ( #player.GetAll() < 2 ) then
			evolve:Notify( ply, evolve.colors.red, "There aren't enough players to start a vote!" )
			return
		end
		
		local args
		if ( argstr ) then
			args = self:GetArguments( argstr )
		else
			args = _
		end
		
		if ( #args == 0 ) then
			evolve:Notify( ply, evolve.colors.red, "You haven't specified a question and options!" )
		elseif ( #args == 1 ) then
			evolve:Notify( ply, evolve.colors.red, "You haven't specified any options!" )
		elseif ( #args == 2 ) then
			evolve:Notify( ply, evolve.colors.red, "There have to be at least two options!" )
		else
			local question = args[1]
			table.remove(args, 1)
			self:VoteStart(question, args, function(percentages, absolutes)
				local msg = ""
				
				for i=1, #percentages do
					msg = msg .. self.Options[i] .. " (" .. percentages[i] .. "%)"
					
					if ( i == #self.Options - 1 ) then
						msg = msg .. " and "
					elseif ( i != #self.Options ) then
						msg = msg .. ", "
					end
				end
				
				evolve:Notify( evolve.colors.red, self.Question .. " ", evolve.colors.white, msg .. "." )
			end)
			
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has started the vote ", evolve.colors.red, self.Question, evolve.colors.white, "." )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:ShowVoteMenu( question, options )
	self.VoteWindow = vgui.Create( "DFrame" )
	self.VoteWindow:SetSize( 200, 35 + #options * 30 )
	self.VoteWindow:SetPos( ScrW() / 2 - self.VoteWindow:GetWide() / 2, ScrH() / 2 - self.VoteWindow:GetTall() / 2 )
	self.VoteWindow:SetTitle( question )
	self.VoteWindow:SetDraggable( false )
	self.VoteWindow:ShowCloseButton( false )
	self.VoteWindow:SetBackgroundBlur( true )
	self.VoteWindow:MakePopup()
	
	local optionlist = vgui.Create( "DPanelList", self.VoteWindow )
	optionlist:SetPos( 5, 25 )
	optionlist:SetSize( 190, #options * 30 + 5 )
	optionlist:SetPadding( 5 )
	optionlist:SetSpacing( 5 )
	
	for i, option in ipairs( options ) do
		local votebut = vgui.Create( "DButton" )
		votebut:SetText( option )
		votebut:SetTall( 25 )
		votebut.DoClick = function()
			net.Start("EV_DoVote")
				net.WriteUInt(i, 8)
			net.SendToServer()
			self.VoteWindow:Close()
		end
		
		optionlist:AddItem( votebut )
	end
end

function PLUGIN:PlayerDisconnected(ply)
	if ply.EV_Voted then
		PLUGIN.VotingPlayers = PLUGIN.VotingPlayers - 1
		PLUGIN.Votes[PLUGIN.PlayerVotes[ply]] = PLUGIN.Votes[PLUGIN.PlayerVotes[ply]] - 1
		
		if PLUGIN.VotingPlayers == #player.GetAll() then
			timer.Destroy("EV_VoteEnd")
			PLUGIN:VoteEnd()
		end
	end
end

if CLIENT then
	net.Receive( "EV_VoteMenu", function( length )
		local question = net.ReadString()
		local optionc = net.ReadUInt(8)
		local options = {}
		
		for i = 1, optionc do
			table.insert( options, net.ReadString() )
		end
		
		PLUGIN:ShowVoteMenu( question, options )
	end )
	
	net.Receive( "EV_VoteEnd", function(length)
		if ( PLUGIN.VoteWindow and PLUGIN.VoteWindow.Close ) then
			PLUGIN.VoteWindow:Close()
		end
	end )
end

if ( SERVER ) then
	net.Receive( "EV_DoVote", function( length, ply )
		local id = net.ReadUInt(8)
		if ( PLUGIN.Question and !ply.EV_Voted and id and (id <= #PLUGIN.Options) ) then
			
			if ( !PLUGIN.Votes[id] ) then
				PLUGIN.Votes[id] = 1
			else
				PLUGIN.Votes[id] = PLUGIN.Votes[id] + 1
			end
			PLUGIN.PlayerVotes[ply] = id
			
			ply.EV_Voted = true
			
			PLUGIN.VotingPlayers = PLUGIN.VotingPlayers + 1
			if ( PLUGIN.VotingPlayers == #player.GetAll() ) then
				timer.Destroy( "EV_VoteEnd" )
				PLUGIN:VoteEnd()
			end
		end
	end )
end

evolve:RegisterPlugin( PLUGIN )
