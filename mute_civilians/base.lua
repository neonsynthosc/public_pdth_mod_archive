local module = DMod:new("mute_civilians", {
	name = "Mute Civilians",
	description = "Allows you to selectively mute types of civilians.",
	author = "_atom",
	version = "1.1",
	categories = { "gameplay", "qol" },
	includes = {
		{ "mod_localization", { type = "localization" } },
		{ "mod_options", { type = "menu_options" } },
	},
})

module:hook_post_require("lib/units/enemies/cop/copsound", "hooks/copsound")
module:hook_post_require("lib/tweak_data/charactertweakdata", "hooks/charactertweakdata")

return module
