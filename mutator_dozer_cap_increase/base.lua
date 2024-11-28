return DMod:new("mutator_dz_cap_increase", {
    version = "1.0",
    abbr = "dz_cap_increase",
    author = "whurr",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "Increases the bulldozer cap by 1.",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "dz_cap_increase"
            local tweakdata_patches = { group_ai = "groupaitweakdata.lua" }
            local mutator_availability = {
                all = false,
                overkill = {},
                overkill_145 = {},
				overkill_193 = {}
            }

            MutatorHelper.setup_mutator(module, mutator_key, mutator_availability, tweakdata_patches)
        end
    }},
    localization = {
        { "mutator_dz_cap_increase", "Bulldozer spawn cap increase" },
        { "mutator_dz_cap_increase_help", "Increases dozer spawn cap to 2. increases the cap to 3 on 193+." },
        { "mutator_dz_cap_increase_motd", "This game is running a mutator which increases the bulldozer spawn cap by 1. this means there can be two non-scripted bulldozers active at a time. on 193+ the cap is increased to 3." }
    }
})