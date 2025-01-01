-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = DMod:new("music_stuff", {
	version = "0.6.6.6", author = "dorentuz", abbr = "MUS",
	name = "Music stuff", description = {
		english = "Change the music track at any time."
	}
})

-- Music override stuff.

do -- config

	module:add_config_option("musicplayer_mute_on_voice", false) -- also takes numeric arguments: 10 decreases the music to 10%
	module:add_config_option("musicplayer_default_level_tracks", {}) -- e.g. { bank = "ingame_bank" }
	module:add_config_option("musicplayer_tracks", nil) -- track overrides

	-- track config:
	--  level stages:
	--   intro
	--   control
	--   anticipation
	--   fake_assault
	--   assault
	--  other stages:
	--   menu_music
	--   loadout_music
	--   resultscreen_win
	--   resultscreen_lose

end

do -- file hooks

	module:hook_post_require("core/lib/managers/coremusicmanager", "musicmanager")
	module:hook_post_require("core/lib/managers/mission/coreelementmusic", "coreelementmusic")
	module:hook_post_require("lib/managers/group_ai_states/groupaistatebase", "groupaistatebase", -11)
	module:hook_post_require("lib/managers/hudmanager", "hudmanager")
	module:hook_post_require("lib/managers/menumanager", "menumanager")
	module:hook_post_require("lib/states/missionendstate", "missionendstate")
	module:hook_post_require("lib/states/ingamewaitingforplayers", "ingamewaitingforplayers")

end


do -- localization

	-- menu items
	module:add_localization_string("menu_track_select", "SELECT MUSIC TRACK")
	module:add_localization_string("mod_mus_default_track_help", "Select the default track for this level.")

	-- special tracks
	module:add_localization_string("menu_music_select_none", "NONE")
	module:add_localization_string("menu_music_select_default", "USE DEFAULT")
	module:add_localization_string("menu_music_select_ingame_default", "USE GAME DEFAULT")
	module:add_localization_string("menu_music_select_random_ingame", "RANDOM (INGAME)")
	module:add_localization_string("menu_music_select_random_other", "RANDOM (EXTERNAL)")

	-- ingame track names	
	module:add_localization_string("ingame_track_apartment", "The Take/Phoney Money (ingame)") -- panic room
	module:add_localization_string("ingame_track_bank", "Gun Metal Grey (ingame)") -- fwb
	module:add_localization_string("ingame_track_bridge", "Stone Cold (ingame)") -- bridge
	module:add_localization_string("ingame_track_diamond_heist", "Breach of Security (ingame)") -- diamond heist
	module:add_localization_string("ingame_track_hospital", "Code Silver (ingame *)") -- no mercy, requires package
	module:add_localization_string("ingame_track_secret_stash", "Three Way Deal (ingame *)") -- undercover, requires package
	module:add_localization_string("ingame_track_slaughter_house", "Crime Wave (ingame)") -- slaughterhouse
	module:add_localization_string("ingame_track_heat_street", "Double Cross (ingame)") -- heat street
	module:add_localization_string("ingame_track_suburbia", "Home Invasion (ingame *)") -- counterfeit, requires package

end

do -- hooks

	module:hook("OnLoadLevel", "OnLoadLevel_SetMusicPlayerState", function()
		if managers.music then
			managers.music:post_event("load_level", true)
		end
	end)

	module:hook("OnGameStart", "OnGameStart_SetMusicPlayerState", function()
		if managers.music then
			managers.music:post_event("load_level", false)
		end
	end)

end

do -- mod options

	local function available_track_options(node, option, current_value)
		return managers.menu:_generate_music_track_options(option.data.level_id)
	end

	local level_tracks_config_key = "musicplayer_default_level_tracks"
	local function track_option_changed(virtual_key, value, _, _, o)
		local current_value = D:conf(level_tracks_config_key)
		local data = o.data

		if type(current_value) ~= "table" then
			current_value = {}
		end
		current_value[data.level_id] = value

		D:set_config_option(level_tracks_config_key, current_value, true)
		module:update_persist_setting(level_tracks_config_key, current_value)
		return false
	end

	local function determine_current_track_value(new_item, option, config_key, module, node)
		local current_value = D:conf(level_tracks_config_key)
		if type(current_value) == "table" then
			return current_value[option.data.level_id]
		end
	end

	local options = {
		{ level_id = "bank" },
		{ level_id = "heat_street", text_id = "debug_street" },
		{ level_id = "apartment" },
		{ level_id = "bridge" },
		{ level_id = "diamond_heist" },
		{ level_id = "slaughter_house" },
		{ level_id = "suburbia" },
		{ level_id = "secret_stash" },
		{ level_id = "hospital" },
	}

	for i = 1, #options do
		local data = options[i]
		module:add_menu_option("level_track_" .. data.level_id, {
			data = data,
			type = "multi_choice",
			text_id = data.text_id or "debug_" .. data.level_id,
			help_id = data.help_id or "mod_mus_default_track_help",
			choices = available_track_options,
			callback = track_option_changed,
			initial_value = determine_current_track_value
		})
	end

end

-- register module
return module