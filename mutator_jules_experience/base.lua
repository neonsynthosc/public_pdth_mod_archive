return DMod:new("mutator_jules", {
    version = "0.4",
    abbr = "MJE",
    author = "Whurr",
    categories = { "gameplay", "mutator" },
    checkable = true,
    description = "The authentic jules experience.",
    dependencies = "ovk_193", -- provides the mutators
    hooks = {{
        "OnModuleLoading", "OnModuleLoading_SetupMyMutators", function(module)
            local mutator_key = "jules"
            local tweakdata_patches = { group_ai = "groupaitweakdata.lua" }
            local mutator_availability = {
                all = false,
				hard= {},
                overkill = {},
                overkill_145 = {},
				overkill_193 = {}
            }

            MutatorHelper.setup_mutator(module, mutator_key, mutator_availability, tweakdata_patches)
        end
    }},
    localization = {
        { "mutator_jules", "The Authentic Jules Experience" },
        { "mutator_jules_help", "Increases the spawn cap to an absurd level even though the game wasn't designed around more than 40 cops max, also increases special unit caps.\nSpecial unit caps:\nHard: 4 Shields, 2 Tasers, 2 Cloakers and 2 Bulldozers.\nOVERKILL: 4 Shields, 3 Tasers, 2 Cloakers and 2 Bulldozers.\nOVERKILL 145+: 4 Shields, 3 Tasers, 2 Cloakers and 3 Bulldozers.\nOVERKILL 193+: 8 Shields, 4 Tasers, 3 Cloakers and 3 Bulldozers.\nGlobal Spawn Cap:\nHard: 56.\nOVERKILL: 72.\nOVERKILL 145+: 84.\nOVERKILL 193+: 108." },
        { "mutator_jules_motd", "This game is running the authentic jules experience. expect a lot of law enforcers." }
    }
})