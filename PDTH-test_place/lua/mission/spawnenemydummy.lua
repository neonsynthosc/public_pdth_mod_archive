core:import("CoreMissionScriptElement")
ElementSpawnEnemyDummy = ElementSpawnEnemyDummy or class(CoreMissionScriptElement.MissionScriptElement)

local ElementSpawnEnemyDummy = module:hook_class("ElementSpawnEnemyDummy")
module:post_hook(ElementSpawnEnemyDummy, "init", function(self)
	self._values.enabled = false
end, true)
