return DMod:new("mutator_sla_spawns", {
    version = "0.2",
    abbr = "MSS",
    author = "whurr",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "Enables unused spawns on the roof by the catwalk on the yard that scripted bulldozers spawn from.",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "sla_spawns"
            local mutator_availability = { all = { levels = { slaughter_house = true } } }
            
            local tweakdata_patches = {
                setup = function(m)
                    DPackageManager:register_processor(m, mutator_key, "mission", "levels/slaughterhouse/world/world", function(type_id, path_id, data)
                        local success = DPackageManager:load_custom_script_data(mutator_key, data, "mission", {
                            id = "whurr_sla",
                            version = "0.1",
                            mission = {
                                update = {
                                    deafult = {
                                        {
                                            id = 100957,
                                            class = "ElementAreaTrigger",
                                            editor_name = "trigger_area_016",
                                            module = "CoreElementArea",
                                            values = { on_executed = {{ id = 101470, delay = 120 }}} -- append
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
        { "mutator_sla_spawns", "Slaughterhouse unused roof spawns enabler" },
        { "mutator_sla_spawns_help", "Enables the unused spawns on the roof by the catwalk out on the yard." },
        { "mutator_sla_spawns_motd", "This server is running a mutator which enables unused roof spawns by the catwalk on the yard." }
    }
})