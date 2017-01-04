/*-------------------------------------------------------------------------------------------------------------------------
	Atmos settings.
-------------------------------------------------------------------------------------------------------------------------*/
if !ConVarExists("atmos_enabled") then return true end --Don't provide for what doesn't exist.
local PLUGIN = {}
PLUGIN.Title = "Atmos"
PLUGIN.Description = "Easy frontend for atmos ConVars."
PLUGIN.Author = "EntranceJew"
PLUGIN.ChatCommand = nil
PLUGIN.Usage = nil
PLUGIN.Privileges = { "Atmos Settings" }
PLUGIN.Icon = "weather_cloudy"
PLUGIN.Dependencies = { "Cconvar" }
PLUGIN.Settings = {
  atmos_enabled = {
    label = "Enable",
    desc = "Toggle whether there's weather.",
    stype = "bool",
    value = 1,
    default = 1,
    isconvar = true,
  },
  atmos_log = {
    label = "Logging",
    desc = "Toggle console logging of atmos events.",
    stype = "bool",
    value = 0,
    default = 0,
    isconvar = true,
  },
  atmos_dnc_length = {
    label = "Day/Night Length",
    desc = "Change the length of the day/night cycle, in seconds.",
    stype = "limit",
    value = 3600,
    min = 1,
    max = 3600,
    default = 3600,
    isconvar = true,
  },
  atmos_weather_length = {
    label = "Weather Length",
    desc = "Change the duration of a storm, in seconds.",
    stype = "limit",
    value = 480,
    min = 1,
    max = 3600,
    default = 480,
    isconvar = true,
  },
  atmos_weather_chance = {
    label = "Weather Chance",
    desc = "Change the liklihood of weather.",
    stype = "limit",
    value = 30,
    min = 1,
    max = 100,
    default = 30,
    isconvar = true,
  },
  atmos_weather_lighting = {
    label = "Impact Lighting",
    desc = "Toggles the ability for to weather affect lighting.",
    stype = "bool",
    value = 0,
    default = 0,
    isconvar = true,
  },
  -- atmos_dnc_gettime
  -- atmos_dnc_settime
  -- atmos_dnc_pause (toggles time)
  -- atmos_startstorm (begins a storm)
  -- atmos_stopstorm
  atmos_cl_hudeffects = {
    label = "CL: Hud Effects",
    desc = "Toggles rain droplets and the like on your HUD.",
    stype = "bool",
    value = 1,
    default = 1,
    isconvar = true,
  },
  atmos_cl_weather = {
    label = "CL: Weather",
    desc = "Toggles whether you perceive weather.",
    stype = "bool",
    value = 1,
    default = 1,
    isconvar = true,
  },
  atmos_cl_rainsplash = {
    label = "CL: Rain Splash",
    desc = "Toggles rain slash effects.",
    stype = "bool",
    value = 1,
    default = 1,
    isconvar = true,
  },
  atmos_cl_rainperparticle = {
    label = "CL: Rain per Particle",
    desc = "The amount of rain per particle.",
    stype = "limit",
    value = 16,
    min = 16,
    max = 64,
    default = 16,
    isconvar = true,
  },
  atmos_cl_rainradius = {
    label = "CL: Rain Radius",
    desc = "Tautological",
    stype = "limit",
    value = 16,
    min = 16,
    max = 32,
    default = 16,
    isconvar = true,
  },
}

--table.insert(evolve:FindPlugin("Cconvar").AllowedCommands, "atmos_")

evolve:RegisterPlugin( PLUGIN )