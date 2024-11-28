return DMod:new("mutator_xsub_spawns", {
    version = "0.1",
    abbr = "MAA",
    author = "whurr",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "Reduces the interval on the SWAT van spawns on counterfeit to 2 seconds from 5 seconds (10 on beachside)",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "xsub_spawns"
            local mutator_availability = { all = { levels = { suburbia = true } } }
            
            local tweakdata_patches = {
                setup = function(m)
                    DPackageManager:register_processor(m, mutator_key, "mission", "levels/suburbia/world/world", function(type_id, path_id, data)
                        local success = DPackageManager:load_custom_script_data(mutator_key, data, "mission", {
                            id = "whurr_suburbia",
                            version = "1.0",
                            mission = {
                                update = {
                                    default = {
                                        {
                                            id = 100267,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_012",
                                            values = { interval = "2" }
                                        },
                                        {
                                            id = 100261,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_006",
                                            values = { interval = "2" }
                                        },
                                        {
                                            id = 100269,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_014",
                                            values = { interval = "2" }
                                        },
                                        {
                                            id = 100266,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_011",
                                            values = { interval = "2" }
                                        },
                                        {
                                            id = 100259,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_004",
                                            values = { interval = "2" }
                                        },
                                        {
                                            id = 101138,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_027",
                                            values = { interval = "2" }
                                        },
                                        {
                                            id = 101633,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_018",
                                            values = { interval = "2" }
                                        },
                                        {
                                            id = 100263,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_008",
                                            values = { interval = "2" }
                                        },
                                    }
                                }
                            }
                        })
                    end)
                end
            }
            MutatorHelper.setup_mutator(module, mutator_key, mutator_availability)
        end
    }},
    localization = {
        { "mutator_xsub_spawns", "Counterfeit faster truck spawns" },
        { "mutator_xsub_spawns_help", "Reduces the interval between spawns on all the swat truck spawns to 2s from 5s." },
        { "mutator_xsub_spawns_motd", "This server is running a mutator which reduces the interval between enemy spawns from the swat vans to 2s from 5s." }
    }
})