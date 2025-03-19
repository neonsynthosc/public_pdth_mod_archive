local module = DorHUDMod:new("FPSCap")

-- script overrides
module:register_post_override("lib/entry", "init")
module:register_post_override("lib/setups/setup", "setup")
module:register_post_override("lib/managers/localizationmanager", "localizationmanager")
module:register_post_override("lib/managers/menumanager", "menumanager")

-- global settings used by the mod
_G.FPSCap = _G.FPSCap or {
	Limit = 60
}

module:hook('OnModuleLoaded', 'SetupModPath', function()
	rawset(_G, "FPSCap_ModPath", module:path())
end)

-- register module
return module