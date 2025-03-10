core:import("CoreMissionScriptElement")
ElementAreaTrigger = ElementAreaTrigger or class(CoreMissionScriptElement.MissionScriptElement)

local ElementAreaTrigger = module:hook_class("ElementAreaTrigger")
module:post_hook(ElementAreaTrigger, "init", function(self)
	self._values.enabled = false
end, true)
