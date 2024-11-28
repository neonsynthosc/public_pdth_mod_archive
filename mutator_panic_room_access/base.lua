return DMod:new("mutator_apa_access", {
    version = "0.1",
    abbr = "MAA",
    author = "whurr + dorentuz",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "Allows Bulldozers and Shields to spawn behind the walls in the back alley in Panic Room.",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "apa_access"
            local mutator_availability = { all = { levels = { apartment = true } } }
            
            local tweakdata_patches = {
                setup = function(m)
                    DPackageManager:register_processor(m, mutator_key, "mission", "levels/apartment/world/world", function(type_id, path_id, data)
                        local success = DPackageManager:load_custom_script_data(mutator_key, data, "mission", {
                            id = "default",
                            version = "0.1",
                            mission = {
                                update = {
                                    default = {
                                        {
                                            id = 101542,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_043",
                                            values = { accessibility="any" }
                                        },
                                        {
                                            id = 101669,
                                            class = "ElementSpawnEnemyDummy",
                                            editor_name = "ai_spawn_enemy_044",
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
        { "mutator_apa_access", "Panic Room Back Alley access change" },
        { "mutator_apa_access_help", "Allows dozers and shields to spawn in the back alley. this means non-scripted dozers and shields can spawn after the C4 blows up." },
        { "mutator_apa_access_motd", "This server is running a mutator which allows dozers and shields to spawn in the back alley." }
    }
})