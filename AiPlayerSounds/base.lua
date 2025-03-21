local module = DorHUDMod:new("ailinesforplayer", { 
	name = "AI Voice Lines",
	abbr = "aivos" ,
	priority = 1,
	version = "1.0",
	author = "easternunit100" ,
	description = {
		english = "Gives the player additional lines to be heard such as being called upon or when you're reviving a teammate."
	},
	dependencies = {
		"third_person_lines"
	}
})
-- script overrides
module:hook_post_require("lib/units/interactions/interactionext", "interactionext")
module:hook_post_require("lib/network/handlers/unitnetworkhandler", "unitnetworkhandler")
-- register module
return module
