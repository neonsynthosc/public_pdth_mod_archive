local module = DMod:new("test_place_mutator", {
	author = "Dr_Newbie",
	version = "6",
	categories = { "gameplay", "mutator" },
	dependencies = { "_sdk", "ovk_193" },
	localization = {
		{ "mutator_test_place_mutator", "Test place" },
		{ "mutator_test_place_mutator_help", "" },
		{ "mutator_test_place_mutator_motd", "" },
	},
})

module:hook("OnModuleLoading", "load_test_place", function(module)
	local mutator_availability = { all = { levels = { apartment = true } } }

	if not MutatorHelper.setup_mutator(module, module:id(), mutator_availability, {}, true, true) then
		return
	end

	-- remove units
	module:hook_post_require("lib/setups/gamesetup", "lua/janitor")

	-- debug
	module:hook_post_require("lib/units/enemies/cop/copdamage", "lua/debug/copdamage")
	module:hook_post_require("lib/units/beings/player/states/playerstandard", "lua/debug/playerstandard")
	module:hook_post_require("lib/units/beings/player/playerdamage", "lua/debug/playerdamage")

	-- disable/modify events
	module:hook_post_require("lib/managers/mission/elementareatrigger", "lua/mission/areatrigger")
	module:hook_post_require("lib/managers/mission/elementdialogue", "lua/mission/dialogue")
	module:hook_post_require("lib/managers/mission/elementhint", "lua/mission/hint")
	module:hook_post_require("lib/managers/mission/elementobjective", "lua/mission/objective")
	module:hook_post_require("lib/managers/mission/elementplayerspawner", "lua/mission/playerspawner")
	module:hook_post_require("lib/managers/mission/elementspawncivilian", "lua/mission/spawncivilian")
	module:hook_post_require("lib/managers/mission/elementspawnciviliangroup", "lua/mission/spawnciviliangroup")
	module:hook_post_require("lib/managers/mission/elementspawnenemydummy", "lua/mission/spawnenemydummy")
	module:hook_post_require("lib/managers/mission/elementspawnenemygroup", "lua/mission/spawnenemygroup")
	module:hook_post_require("lib/managers/mission/elementwaypoint", "lua/mission/waypoint")
	module:hook_post_require("lib/managers/mission/missionscriptelement", "lua/mission/missionscript")

	-- Package loading
	module:hook_post_require("lib/setups/gamesetup", "lua/gamesetup")
end)

return module
