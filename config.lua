Config = {}

Config.ScanDistance = 2.5 -- Distance to scan for vehicles
Config.EnableKeyOpen = false -- Enable if you want to use a key to open the OBD tablet
Config.OpenKey = 'F5' -- Key to open the OBD tablet 
Config.DebugMode = false -- Enables debug mode for additional logging and use of commands
Config.ShowNotifications = true -- Show notifications when actions are performed
Config.UseOXNotifications = true -- Use OX notifications if available, otherwise fallback to framework notifications
Config.FrameWork = "auto" -- Set the framework to use, options are "auto", "esx" or "qb"
Config.AutoVersionChecker = true -- Automatically check for updates

Config.OBDItem = 'obd' -- Item used to open the OBD tablet
Config.InCarUseOnly = true -- Use the OBD tablet only when inside a vehicle
Config.UpdateInterval = 60 -- Interval in seconds to update vehicle data
Config.UseAnimations = true -- Use animations when opening the tablet
Config.tabletAnimDict = "amb@world_human_tourist_map@male@base" -- Animation dictionary for the tablet
Config.tabletAnimName = "base" -- Animation name for the tablet
Config.tabletModel = "prop_cs_tablet" -- Model of the tablet prop
Config.ElectricVehicles = {
  "airtug",     "buffalo5",   "caddy",
  "caddy2",     "caddy3",     "coureur",
  "cyclone",    "cyclone2",   "imorgon",
  "inductor",   "iwagen",     "khamelion",
  "metrotrain", "minitank",   "neon",
  "omnisegt",   "powersurge", "raiden",
  "rcbandito",  "surge",      "tezeract",
  "virtue",     "vivanite",   "voltic",
  "voltic2",    "dilettante", "dilettante2",
  "nkomnisegt", "serv_electricscooter",  "mantis",
  "elytron",    "raidenz",    "kawaii",
}

Config.EnableBackgrondParticles = true -- Enable background particles animation in the OBD UI (not it minimalistic mode)