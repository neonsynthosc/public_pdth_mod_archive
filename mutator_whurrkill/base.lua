return DMod:new("mutator_whurkill", {
    version = "0.1",
    abbr = "WKM",
    author = "dorentuz + whurrhurr",
    categories = { "gameplay", "mutator" },
    description = "Whurr's difficulty overhaul based on PD2",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "whurrkill"
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
        { "mutator_whurrkill", "WHURRKILL" },
        { "mutator_whurrkill_help", "Whurr's difficulty overhaul" },
        { "mutator_whurrkill_motd", "This game is using a custom \"Whurrkill\" difficulty mutator." }
    }
})