/*-------------------------------------------------------------------------------------------------------------------------
	Default ranks
-------------------------------------------------------------------------------------------------------------------------*/

evolve.ranks.guest = {}
evolve.ranks.guest.Title = "Guest"
evolve.ranks.guest.Icon = "user"
evolve.ranks.guest.NotRemovable = true
evolve.ranks.guest.UserGroup = "guest"
evolve.ranks.guest.Immunity = 0
evolve.ranks.guest.Privileges = {
	"Noclip access", "The time", "Player names"
}

evolve.ranks.respected = {}
evolve.ranks.respected.Title = "Respected"
evolve.ranks.respected.Icon = "user_add"
evolve.ranks.respected.UserGroup = "guest"
evolve.ranks.respected.Immunity = 1
evolve.ranks.respected.Privileges = {
	"Noclip access", "The time", "Ratings visible", "Me", "Roll the Dice", "Private messages", "Player names"
}

evolve.ranks.admin = {}
evolve.ranks.admin.Title = "Admin"
evolve.ranks.admin.Icon = "shield"
evolve.ranks.admin.UserGroup = "admin"
evolve.ranks.admin.Immunity = 30
evolve.ranks.admin.Privileges = {
	"Admin chat", "Achievement", "Public admin message", "Arm", "Armor", "Ban", "Blind", "Bring", "Map changing", "Cleanup", "Convar changing", "Deaths", "Decal cleanup",
	"Enter vehicle", "Exit vehicle", "Explode", "Extinguish", "Frags", "Freeze", "Gag", "Ghost", "Give weapon", "God", "Goto", "Health", "Ignite", "Imitate",
	"Jail", "Kick", "Me", "Mute", "Noclip", "Noclip access", "No limits", "Notice", "Private messages", "Evade prop protection", "Ragdoll",
	"Map reload", "Respawn", "Rocket", "Roll the Dice", "Slap", "Slay", "Spectate", "Speed", "Strip", "Teleport", "The time", "Unban", "Menu",
	"Unlimited ammo", "Physgun players", "Ratings visible", "Player menu", "Player names"
}

evolve.ranks.superadmin = {}
evolve.ranks.superadmin.Title = "Super Admin"
evolve.ranks.superadmin.Icon = "shield_add"
evolve.ranks.superadmin.UserGroup = "superadmin"
evolve.ranks.superadmin.Immunity = 50
evolve.ranks.superadmin.Privileges = {
	"Admin chat", "Achievement", "Public admin message", "Arm", "Armor", "Ban", "Permaban", "Blind", "Bring", "Map changing", "Cleanup", "Convar changing", "Deaths", "Decal cleanup",
	"Enter vehicle", "Exit vehicle", "Explode", "Extinguish", "Frags", "Freeze", "Gag", "Ghost", "Give weapon", "God", "Goto", "Health", "Ignite", "Imitate",
	"Jail", "Kick", "Me", "Mute", "Noclip", "Noclip access", "No limits", "Notice", "Private messages", "Evade prop protection", "Ragdoll",
	"Map reload", "Respawn", "Rocket", "Roll the Dice", "Slap", "Slay", "Spectate", "Speed", "Strip", "Teleport", "The time", "Unban", "Menu",
	"Unlimited ammo", "Physgun players", "Ratings visible", "Player menu", "Sandbox menu", "Player names"
}

evolve.ranks.owner = {}
evolve.ranks.owner.Title = "Owner"
evolve.ranks.owner.Icon = "key"
evolve.ranks.owner.ReadOnly = true
evolve.ranks.owner.UserGroup = "superadmin"
evolve.ranks.owner.Immunity = 99