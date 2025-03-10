core:import("CoreMissionScriptElement")
ElementSpawnCivilianGroup = ElementSpawnCivilianGroup or class(CoreMissionScriptElement.MissionScriptElement)

local ElementSpawnCivilianGroup = module:hook_class("ElementSpawnCivilianGroup")
module:post_hook(ElementSpawnCivilianGroup, "init", function(self)
	self._values.enabled = false
end, true)
