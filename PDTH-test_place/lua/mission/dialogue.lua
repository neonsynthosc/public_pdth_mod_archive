core:import("CoreMissionScriptElement")
ElementDialogue = ElementDialogue or class(CoreMissionScriptElement.MissionScriptElement)

local ElementDialogue = module:hook_class("ElementDialogue")
module:post_hook(ElementDialogue, "init", function(self)
	self._values.enabled = false
end, true)
