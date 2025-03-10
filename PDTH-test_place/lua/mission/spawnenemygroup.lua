core:import("CoreMissionScriptElement")
ElementSpawnEnemyGroup = ElementSpawnEnemyGroup or class(CoreMissionScriptElement.MissionScriptElement)

local ElementSpawnEnemyGroup = module:hook_class("ElementSpawnEnemyGroup")
module:post_hook(ElementSpawnEnemyGroup, "init", function(self)
	self._values.enabled = false
end, true)
