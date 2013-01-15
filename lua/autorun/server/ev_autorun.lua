/*-------------------------------------------------------------------------------------------------------------------------
	Serverside autorun file
-------------------------------------------------------------------------------------------------------------------------*/

// Set up Evolve table
evolve = {}

// Distribute clientside and shared files
AddCSLuaFile( "autorun/client/ev_autorun.lua" )
AddCSLuaFile( "ev_framework.lua" )
AddCSLuaFile( "ev_cl_init.lua" )
AddCSLuaFile( "ev_menu/cl_menu.lua" )

// Load serverside files
include( "von.lua" )
include( "ev_framework.lua" )
include( "ev_sv_init.lua" )
include( "ev_menu/sv_menu.lua" )

// SourceBans integration
include( "ev_sourcebans.lua" )