-- DAHM by DorentuZ` -- https://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

return DMod:new("direct_messaging", {
	abbr = "dmi",
	author = "dorentuz",
	config = {
		{ "menu", "hud_toggle_marker", { type = "keybind", text_id = "mod_hud_toggle_marker" }},
		{ "menu", "dmi_always_show_hints", { type = "boolean", text_id = "mod_dmi_show_hints", help_id = "mod_dmi_show_hints_help", default = true }},
		{ "dmi_hint_duration", 1 },
	},
	categories = { "hud", "players" },
	dependencies = { "enhanced_chat", "hud" },
	description = "Interface for direct messaging",
	hooks = { "lib/managers/hudmanager", "lib/managers/menu/menulobbyrenderer", "lib/managers/menumanager" },
	localization = {
		{ "dm_target_all", "everyone" },
		{ "debug_chat_say_dm", "DIRECT MESSAGE ([peer_color]$NAME;[])>" },
		{ "mod_hud_toggle_marker", "Selection toggle" },
		{ "hint_dm_target", "DM TARGET: [peer_color]$NAME;[]" },
		{ "mod_dmi_show_hints", "Always show hints" },
		{ "mod_dmi_show_hints_help", "Show hints when selecting another target." }
	},
	priority = 666, -- for the chat input interception
	update = { id = "pdthdmi", url = "https://www.dropbox.com/s/0jv6pny4g8xgc14/version.txt?dl=1" },
	version = "0.3"
})