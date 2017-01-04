--[[
	Observation plugin for Evolve.
	By `impulse.
]]--

local PLUGIN = {}

PLUGIN.Title = "Observation"
PLUGIN.Description = "Noclip around hidden."
PLUGIN.Author = "`impulse"
PLUGIN.ChatCommand = "observe"
PLUGIN.Usage = "[players] [1/0]"
PLUGIN.Privileges = { "Observation Mode" }

PLUGIN.SavedPoints = {}

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Observation Mode" ) ) then
	
		local players = evolve:FindPlayer( args, ply, true )
		local enabled = ( tonumber( args[ #args ] ) or 1 ) > 0
		
		for _, pl in ipairs( players ) do
		
			if ( !enabled ) then
				
				if ( self.SavedPoints[ pl ] == nil ) then
				
					evolve:Notify( pl, evolve.colors.red, "You are not in observation mode!" )
					return ""
					
				end
				
				pl:SetRenderMode( RENDERMODE_NORMAL )
				pl:SetColor( 255, 255, 255, 255 )
				pl:SetMoveType( MOVETYPE_WALK )
				pl:GodDisable()
				pl:SetPos( self.SavedPoints[ pl ].pos )
				pl:SetEyeAngles( self.SavedPoints[ pl ].ang )
				self.SavedPoints[ pl ] = nil
				
				for _, w in ipairs( pl:GetWeapons() ) do
					
					w:SetRenderMode( RENDERMODE_NORMAL )
					w:SetColor( 255, 255, 255, 255 )
					
				end
				
			else
			
				if ( self.SavedPoints[ pl ] ~= nil ) then
				
					evolve:Notify( pl, evolve.colors.red, "You are already in observation mode!" )
					return ""
					
				end
				
				self.SavedPoints[ pl ] = {
					pos = pl:GetPos(),
					ang = pl:EyeAngles()
				}
				
				pl:SetRenderMode( RENDERMODE_NONE )
				pl:SetColor( 255, 255, 255, 0 )
				pl:SetMoveType( MOVETYPE_NOCLIP )
				pl:GodEnable()
				
				for _, w in ipairs( ply:GetWeapons() ) do
				
					w:SetRenderMode( RENDERMODE_NONE )
					w:SetColor( 255, 255, 255, 0 )
					
				end
				
			end
			
		end
		
		if ( #players > 0 ) then
		
			if ( enabled ) then
			
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has made ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " enter observation mode." )
				
			else
			
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has made ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " exit observation mode." )
				
			end
			
		else
		
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
			
		end
		
	else
	
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
		
	end
	
end

function PLUGIN:Menu( arg, players )

	if ( arg ) then
		
		table.insert( players, arg )
		RunConsoleCommand( "ev", "observe", unpack( players ) )
		
	else
	
		return "Observation", evolve.category.actions, { { "Enter", 1 }, { "Exit", 0 } }
	
	end
	
end

evolve:RegisterPlugin( PLUGIN )