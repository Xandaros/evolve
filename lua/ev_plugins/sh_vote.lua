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

function PLUGIN:VoteEnd()
	SendUserMessage( "EV_VoteEnd", nil )
	
	local msg = ""	
	for i = 1, #self.Options do
		local percent
		if ( table.Count( self.Votes ) == 0 ) then percent = 0 else percent = math.Round( ( self.Votes[i] or 0 ) / self.VotingPlayers * 100 ) end
		
		msg = msg .. self.Options[i] .. " (" .. percent .. "%)"
		
		if ( i == #self.Options - 1 ) then
			msg = msg .. " and "
		elseif ( i != #self.Options ) then
			msg = msg .. ", "
		end
	end
	
	evolve:Notify( evolve.colors.red, self.Question .. " ", evolve.colors.white, msg .. "." )
	
	self.Question = nil
	for _, pl in ipairs( player.GetAll() ) do
		pl.EV_Voted = nil
	end
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
			self.Question = args[1]
			table.remove( args, 1 )
			self.Options = args
			self.Votes = {}
			self.VotingPlayers = 0
			
			umsg.Start( "EV_VoteMenu" )
				umsg.String( self.Question )
				umsg.Short( #self.Options )
				for _, option in ipairs( self.Options ) do
					umsg.String( option )
				end
			umsg.End()
			
			timer.Create( "EV_VoteEnd", 10, 1, function() PLUGIN:VoteEnd() end )
			
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
			RunConsoleCommand( "EV_DoVote", i )
			self.VoteWindow:Close()
		end
		
		optionlist:AddItem( votebut )
	end
end

usermessage.Hook( "EV_VoteMenu", function( um )
	local question = um:ReadString()
	local optionc = um:ReadShort()
	local options = {}
	
	for i = 1, optionc do
		table.insert( options, um:ReadString() )
	end
	
	PLUGIN:ShowVoteMenu( question, options )
end )

if ( SERVER ) then
	concommand.Add( "EV_DoVote", function( ply, _, args )
		if ( PLUGIN.Question and !ply.EV_Voted and tonumber( args[1] ) and tonumber( args[1] ) <= #PLUGIN.Options ) then
			local optionid = tonumber( args[1] )
			
			if ( !PLUGIN.Votes[optionid] ) then
				PLUGIN.Votes[optionid] = 1
			else
				PLUGIN.Votes[optionid] = PLUGIN.Votes[optionid] + 1
			end
			
			ply.EV_Voted = true
			
			PLUGIN.VotingPlayers = PLUGIN.VotingPlayers + 1
			if ( PLUGIN.VotingPlayers == #player.GetAll() ) then
				timer.Destroy( "EV_VoteEnd" )
				PLUGIN:VoteEnd()
			end
		end
	end )
end

usermessage.Hook( "EV_VoteEnd", function()
	if ( PLUGIN.VoteWindow and PLUGIN.VoteWindow.Close ) then
		PLUGIN.VoteWindow:Close()
	end
end )

evolve:RegisterPlugin( PLUGIN )