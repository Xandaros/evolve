/*-------------------------------------------------------------------------------------------------------------------------
	Run Lua on the server
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Lua"
PLUGIN.Description = "Execute Lua on the server."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "lua"
PLUGIN.Usage = "<code>"
PLUGIN.Privileges = { "Lua" }

local mt, mt2 = {}, {}
EVERYONE, EVERYTHING = {}, {}

function mt.__index( t, k )
	return function( ply, ... )
		for _, pl in ipairs( player.GetAll() ) do
			pl[ k ]( pl, ... )
		end
	end
end

function mt2.__index( t, k )
	return function( ply, ... )
		for _, ent in ipairs( ents.GetAll() ) do
			if ( !ent:IsWorld() ) then ent[ k ]( ent, ... ) end
		end
	end
end

setmetatable( EVERYONE, mt )
setmetatable( EVERYTHING, mt2 )

function PLUGIN:Call( ply, args )	
	if ( ply:EV_HasPrivilege( "Lua" ) and ValidEntity( ply ) ) then
		local code = table.concat( args, " " )
		
		if ( #code > 0 ) then
			ME = ply
			THIS = ply:GetEyeTrace().Entity
			PLAYER = function( nick ) return evolve:FindPlayer( nick )[1] end
			
			local f, a, b = CompileString( code, "" )
			if ( !f ) then
				evolve:Notify( ply, evolve.colors.red, "Syntax error! Check your script!" ) 
				return
			end
			
			local status, err = pcall( f )
			
			if ( status ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " ran Lua code: ", evolve.colors.red, code )
			else
				evolve:Notify( ply, evolve.colors.red, string.sub( err, 5 ) )
			end
			
			THIS, ME, PLAYER = nil
		else
			evolve:Notify( ply, evolve.colors.red, "No code specified." )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )