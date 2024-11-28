return DMod:new("mutator_bank_spawns", {
	version = "0.1",
	abbr = "MBS",
	author = "whurr",
	categories = { "gameplay", "mutator" },
	checkable = true,
	description = "Allows Bulldozers and Shields to spawn from the elevators in the Vault Hallway and sets the interval on those spawnpoints to 5 seconds for consistency.",
	dependencies = "ovk_193", -- provides the mutators
	hooks = {{
		"OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
			local mutator_key = "bank_spawns"
			local mutator_availability = { all = { levels = { bank = true } } }
            
			local tweakdata_patches = {
				setup = function(m)
					DPackageManager:register_processor(m, mutator_key, "mission", "levels/bank/world/world", function(type_id, path_id, data)
						local success = DPackageManager:load_custom_script_data(mutator_key, data, "mission", {
                            id = "bank_spawn_mut",
                            version = "1.0",
                            mission = {
                                update = {
                                    default = {
                                        {
                                            id = 103406,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_070",
                                            values = {accessibility = "any", interval = "5"}
                                        },
                                        {
                                            id = 103387,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_068",
                                            values = {accessibility = "any", interval = "5"}
                                        },
                                        {
                                            id = 103414,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_074",
                                            values = {accessibility = "any", interval = "5"}
                                        },
                                        {
                                            id = 103411,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_071",
                                            values = {accessibility = "any", interval = "5"}
                                        },
                                        {
                                            id = 103363,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_001",
                                            values = {accessibility = "any", interval = "5"}
                                        },
                                        {
                                            id = 103366,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_043",
                                            values = {accessibility = "any", interval = "5"}
                                        },
                                        {
                                            id = 103377,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_067",
                                            values = {accessibility = "any", interval = "5"}
                                        }
                                    }
                                }
                            }
                        })
                    end)
                end
            }
            MutatorHelper.setup_mutator(module, mutator_key, mutator_availability, tweakdata_patches)
        end
    }},
    localization = {
        { "mutator_bank_spawns", "FWB Vault Hallway elevator access change" },
        { "mutator_bank_spawns_help", "Allows bulldozers and shields to spawn from the elevator shaft spawnpoints in the vault hallway and sets their interval between to 5s." },
        { "mutator_bank_spawns_motd", "This server is running a mutator which allows dozers and shields to spawn from the elevator shafts in the vault halllway and reduces the interval between spawns on those spawnpoints to 5s." }
    }
})