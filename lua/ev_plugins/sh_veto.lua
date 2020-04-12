local PLUGIN = {}
PLUGIN.Title = "Veto"
PLUGIN.Description = "Veto a mapvote."
PLUGIN.Author = "Feha"
PLUGIN.ChatCommand = "veto"
PLUGIN.Privileges = { "Veto" }

function PLUGIN:Call( ply, args )
	if (ply:EV_HasPrivilege( "Veto" )) then
		self:VotemapVeto( ply )
	end
end

function PLUGIN:VotemapVeto( ply )
	if (timer.IsTimer( "evolve_votemap" )) then
		timer.Destroy( "evolve_votemap" )
		evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " used his powers to ", evolve.colors.red, "veto", evolve.colors.white, " the voted mapchange."  )
	else
		evolve:Notify( ply, evolve.colors.red, "No voted mapchange currently in progress." )
	end
end

evolve:RegisterPlugin( PLUGIN )