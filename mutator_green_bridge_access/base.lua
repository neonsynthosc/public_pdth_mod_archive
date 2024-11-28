return DMod:new("mutator_bri_access", {
    version = "0.1",
    abbr = "MGA",
    author = "whurr",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "Mutator that allows Bulldozers and Shields to spawn between prisoner trucks 3 and 4 and climb up to the ground floor of the scaffolding.",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "bri_access"
            local mutator_availability = { all = { levels = { bridge = true } } }
            
            local tweakdata_patches = {
                setup = function(m)
                    DPackageManager:register_processor(m, mutator_key, "mission", "levels/bridge/world/world", function(type_id, path_id, data)
                        local success = DPackageManager:load_custom_script_data(mutator_key, data, "mission", {
                            id = "default",
                            version = "0.1",
                            mission = {
                                update = {
                                    default = {
                                        {
                                            id = 101309,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_158",
                                            values = { accessibility="any" }
                                        },
                                        {
                                            id = 101310,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_159",
                                            values = { accessibility="any" }
                                        },
                                        {
                                            id = 100913,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_119",
                                            values = { accessibility="any" }
                                        },
                                        {
                                            id = 100229,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_042",
                                            values = { accessibility="any" }
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
        { "mutator_bri_access", "Green Bridge access change" },
        { "mutator_bri_access_help", "Allows dozers and shields to spawn on the bridge between trucks 3 and 4 and also allows them to climb up to the ground floor of the scaffolding." },
        { "mutator_bri_access_motd", "This server is running a mutator which allows dozers and shields to spawn between prisoner trucks 3 and 4 and climb  up to the ground floor of the scaffolding." }
    }
})