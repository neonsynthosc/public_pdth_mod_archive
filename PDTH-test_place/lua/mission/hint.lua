core:import("CoreMissionScriptElement")
ElementHint = ElementHint or class(CoreMissionScriptElement.MissionScriptElement)

local ElementHint = module:hook_class("ElementHint")
module:post_hook(ElementHint, "init", function(self)
	self._values.enabled = false
end, true)
