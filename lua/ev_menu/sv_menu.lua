/*-------------------------------------------------------------------------------------------------------------------------
	Serverside menu framework
-------------------------------------------------------------------------------------------------------------------------*/

// Send all tabs to the clients
local tabs,_ = file.Find( "ev_menu/tab_*.lua", "LUA" )
for _, tab in ipairs( tabs ) do
	AddCSLuaFile( tab )
end

// Register privileges
table.insert( evolve.privileges, "Menu" )

function evolve:RegisterTab( tab )
	table.Add( evolve.privileges, tab.Privileges or {} )
end

for _, tab in ipairs( tabs ) do
	include( tab )
end