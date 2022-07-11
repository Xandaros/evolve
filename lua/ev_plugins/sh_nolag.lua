/*-------------------------------------------------------------------------------------------------------------------------
	This command eliminate serverlags. Very useful if crappy adv-dupe shit got spawned and fuck up the server.
	Visit http://www.rodcust.eu/
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "No-Lag"
PLUGIN.Description = "With !nolag you can freeze all props at once."
PLUGIN.Author = "dOiF [AUT]"
PLUGIN.ChatCommand = "nolag"
PLUGIN.Privileges = { "Admin Anti-Lag" }

function PLUGIN:Call( ply )
	if ( ply:EV_HasPrivilege( "Admin Anti-Lag" ) ) then
	local Ent = ents.FindByClass("prop_physics")
		for _,Ent in pairs(Ent) do
			if Ent:IsValid() then
				local phys = Ent:GetPhysicsObject()
				if phys then
					if phys:IsValid() then
						phys:EnableMotion(false)
					end
				end
			end
		end
		evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has frozen all props on the server." )
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
	
end

evolve:RegisterPlugin( PLUGIN )
