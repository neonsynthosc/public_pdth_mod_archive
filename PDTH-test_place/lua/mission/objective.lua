core:import("CoreMissionScriptElement")
ElementObjective = ElementObjective or class(CoreMissionScriptElement.MissionScriptElement)

local ElementObjective = module:hook_class("ElementObjective")
module:post_hook(ElementObjective, "init", function(self)
	self._values.enabled = false
end, true)
