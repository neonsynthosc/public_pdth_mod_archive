core:import("CoreMissionScriptElement")
ElementSpawnCivilian = ElementSpawnCivilian or class(CoreMissionScriptElement.MissionScriptElement)

local ElementSpawnCivilian = module:hook_class("ElementSpawnCivilian")
module:post_hook(ElementSpawnCivilian, "init", function(self)
	self._values.enabled = false
end, true)
