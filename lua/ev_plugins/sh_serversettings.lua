/*-------------------------------------------------------------------------------------------------------------------------
	Relocates settings for 
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Server"
PLUGIN.Description = "Server settings outside the utilities menu."
PLUGIN.Author = "EntranceJew"
PLUGIN.ChatCommand = nil
PLUGIN.Usage = nil
PLUGIN.Privileges = { "Server Settings" }
PLUGIN.Icon = "server"
PLUGIN.Settings = {
	sv_password = {
		label = 'Connect Password',
		desc = 'Only people who know the code can join!',
		stype = 'string',
		default = 'example'
	},
	sv_kickerrornum = {
		label = "Kick for Clientside Errors",
		desc = "Kicks clients that experience this many errors.\n0=Don't kick.",
		stype = "limit",
		min = 0,
		max = 200,
		default = 0,
		isconvar = true,
	},
	sv_allowcslua = {
		label = 'Allow Client Lua',
		desc = "Allows clients to run lua. Usually you don't want this.",
		stype = 'bool',
		default = false,
		isconvar = true,
	},
	sv_gravity = {
		label = "Gravity",
		desc = "F=G((m1*m2)/r^2)",
		stype = "limit",--float
		min = -200,
		max = 600,
		default = 600,
		isconvar = true,
	},
	phys_timescale = {
		label = "Physics Timescale",
		desc = "Time is relative. Is it your uncle?",
		stype = "limit",--float
		min = 0,
		max = 2,
		default = 1.0,
		isconvar = true,
	},
	gmod_physiterations = {
		label = "Physics Iterations",
		desc = "How frequently we get physical.",
		stype = "limit",--float
		min = 1,
		max = 10,
		default = 1,
		isconvar = true,
	},
}

evolve:RegisterPlugin( PLUGIN )