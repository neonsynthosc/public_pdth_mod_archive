core:import("CoreMissionScriptElement")
ElementWaypoint = ElementWaypoint or class(CoreMissionScriptElement.MissionScriptElement)

local ElementWaypoint = module:hook_class("ElementWaypoint")
module:post_hook(ElementWaypoint, "init", function(self)
	self._values.enabled = false
end, true)
