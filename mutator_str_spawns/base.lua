return DMod:new("mutator_str_spawns", {
    version = "0.2",
    abbr = "MSS",
    author = "whurr",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "Enables unused spawns on the roof by the catwalk on the yard that scripted bulldozers spawn from.",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "str_spawns"
            local mutator_availability = { all = { levels = { heat_street = true } } }
            
            local tweakdata_patches = {
                setup = function(m)
                    DPackageManager:register_processor(m, mutator_key, "mission", "levels/street/world/world", function(type_id, path_id, data)
                        local success = DPackageManager:load_custom_script_data(mutator_key, data, "mission", {
                            id = "whurr_str",
                            version = "0.1",
                            mission = {
                                update = {
                                    default = {
                                        {
                                            id = 101086,
                                            class = "ElementEnemyPreferedAdd",
                                            editor_name = "ai_enemy_prefered_add_009",
                                            module = "CoreElementEnemyPreferedAdd",
                                            values = { elements = { 101527, 100492 }} -- append
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
        { "mutator_str_spawns", "Heat Street unused Armitage Ave spawns enabler" },
        { "mutator_str_spawns_help", "Enables the unused spawns at the top of armitage ave." },
        { "mutator_str_spawns_motd", "This server is running a mutator which enables unused spawns at the top of armitage." }
    }
})