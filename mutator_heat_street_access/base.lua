return DMod:new("mutator_str_access", {
    version = "0.3",
    abbr = "MSA",
    author = "whurr",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "Heat Street access type changes",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "str_access"
            local mutator_availability = { all = { levels = { heat_street = true } } }
            
            local tweakdata_patches = {
                setup = function(m)
                    DPackageManager:register_processor(m, mutator_key, "mission", "levels/street/world/world", function(type_id, path_id, data)
                        local success = DPackageManager:load_custom_script_data(mutator_key, data, "mission", {
                            id = "default",
                            version = "0.2",
                            mission = {
                                update = {
                                    default = {
                                        {
                                            id = 100441,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_036",
                                            values = {accessibility="any"}
                                        },
                                        {
											id = 102943,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_099",
											values = {accessibility="any"}
                                        },
                                        {
                                            id = 101582,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_070",
                                            values = {accessibility="any"}
                                        },
                                        {
											id = 101671,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_076",
											values = {accessibility="any"}
                                        },
                                        {
                                            id = 101274,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_025",
                                            values = {accessibility="any"}
                                        },
                                        {
											id = 101650,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_073",
											values = {accessibility="any"}
                                        },
                                        {
                                            id = 102947,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_043",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 102942,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_041",
                                            values = { SO_access="262100" }
                                        },
                                        {
											id = 101123,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_047",
											values = {accessibility="any"}
                                        },
                                        {
											id = 102475,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_035",
											values = {accessibility="any"}
                                        },
                                        {
											id = 101587,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_078",
											values = {accessibility="any"}
                                        },
                                        {
											id = 101979,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_079",
											values = {accessibility="any"}
                                        },
                                        {
											id = 100295,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_046",
											values = {accessibility="any"}
                                        },
                                        {
											id = 101479,
											class = "ElementSpawnEnemyDummy",
											editor_name = "ai_spawn_enemy_077",
											values = {accessibility="any"}
                                        },
                                        {
                                            id = 101766,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_011",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101763,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_009",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101760,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_007",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101764,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_010",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101762,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_008",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101759,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_005",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101696,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_035",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101598,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_001",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101929,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_036",
                                            values = { SO_access="262100" }
                                        },
                                        {
                                            id = 101932,
                                            class = "ElementSpecialObjective",
                                            editor_name = "point_special_objective_037",
                                            values = { SO_access="262100" }
                                        },
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
        { "mutator_str_access", "Heat Street access change" },
        { "mutator_str_access_help", "Allows dozers and shields to spawn behind the wall by the blue car in inkwell and the swat trucks behind the riot fences at inkwell as well as the swat trucks and the corner behind the second set of riot fences at the top of armitage ave." },
        { "mutator_str_access_motd", "This server is running a mutator which allows dozers and shields to spawn behind the wall by the blue car in inkwell and around the corner behind the riot fences at inkwell as well as at the top of armitage ave." }
    }
})