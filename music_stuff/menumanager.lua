-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("music_stuff")
local MenuManager = module:hook_class("MenuManager")

module:hook(20, MenuManager, "music_volume_changed", function(self, name, old_value, new_value)
	local tweak = _G.tweak_data.menu
	local percentage = (new_value - tweak.MIN_MUSIC_VOLUME) / (tweak.MAX_MUSIC_VOLUME - tweak.MIN_MUSIC_VOLUME) * 100
	managers.music:set_volume(percentage)
end)

module:hook(20, MenuManager, "set_slot_voice", function(self, peer, peer_id, active)
	module:call_orig(MenuManager, "set_slot_voice", self, peer, peer_id, active)
	managers.music:set_voice_slot_active(peer, active)
end)

local menus_to_modify = { menu_main = 1, menu_pause = 1, lobby_menu = 1, kit_menu = 1 }
module:hook(20, MenuManager, "modify_menu_nodes", function(self, menu_name, menu, nodes)
	module:call_orig(MenuManager, "modify_menu_nodes", self, menu_name, menu, nodes)

	if menus_to_modify[menu_name] then
		local ts_item = nil
		local ts_item_definition = {
			name = "track_select",
			callback = "choice_track_select",
			text_id = "menu_track_select",
			menu_name = menu_name
		}
		local music_select_options = self:_generate_music_track_options(Global.level_data and Global.level_data.level_id)

		if menu_name == "kit_menu" then
			local node = nodes.kit
			local inserted_items = self:insert_menu_item(node, false, { before = "chat" }, ts_item_definition, music_select_options)
			if inserted_items then
				ts_item = inserted_items[node:name()][1]
				self:insert_menu_item(node, false, { before = "track_select" }, {
					type = "MenuItemDivider", name = "track_select_divider", size = 16
				})
			end
		else
			local node = nodes.sound
			local inserted_items = self:insert_menu_item(node, false, { before = "music_volume" }, ts_item_definition, music_select_options)
			if inserted_items then
				ts_item = inserted_items[node:name()][1]
				self:insert_menu_item(node, false, { after = "track_select" }, {
					type = "MenuItemDivider", name = "track_select_divider", size = 16
				})
			end
		end

		if ts_item then
			local default_track = managers.music:get_track_for_level()
			if not default_track then
				local tracks = managers.music:tracks()
				default_track = tracks and tracks.default and "default" or "ingame_default"
			end

			ts_item:set_value(default_track)
			-- ts_item:trigger()
		end
	end
end)

module:hook(MenuCallbackHandler, "_dialog_quit_yes", function(self)
	if managers.music then
		managers.music:stop()
	end
	module:call_orig(MenuCallbackHandler, "_dialog_quit_yes", self)
end)

module:hook(20, MenuManager, "_generate_music_track_options", function(self, level_id)
	local music_select_options = { type = "MenuItemMultiChoice" }
	local tracks, ingame_tracks, custom_tracks = managers.music:tracks(), {}, {}
	for track_id, o in pairs(tracks) do
		if not o._name then
			local text_id = "menu_music_select_track_" .. track_id
			if managers.localization:exists(text_id) then
				o._name = managers.localization:text(text_id)
			else
				o._name = track_id
			end
		end

		if not o._requires_level or o._requires_level == level_id then
			if track_id ~= "default" and track_id ~= "menu" then
				local track_type = o._type
				if level_id or track_type ~= "ingame" then
					table.insert(track_type == "ingame" and ingame_tracks or custom_tracks, track_id)
					table.insert(music_select_options, {
						_meta = "option",
						value = track_id,
						text_id = o._name,
						localize = false,
					})
				end
			end
		end
	end

	table.sort(music_select_options, function(a, b)
		return a.text_id < b.text_id
	end)

	table.insert(music_select_options, 1, {
		_meta = "option", value = "ingame_default",
		text_id = "menu_music_select_ingame_default"
	})

	if tracks.default then
		table.insert(music_select_options, 1, {
			_meta = "option", value = "default",
			text_id = "menu_music_select_default"
		})
	end

	local include_random_options = D:conf("musicplayer_include_random_options")
	if include_random_options ~= false then
		if include_random_options ~= "ingame" and not table.empty(custom_tracks) then
			table.insert(music_select_options, 1, {
				_meta = "option",
				value = "random_other",
				text_id = "menu_music_select_random_other"
			})
		end
		if include_random_options ~= "custom" and not table.empty(ingame_tracks) then
			if level_id then
				table.insert(music_select_options, 1, {
					_meta = "option",
					value = "random_ingame",
					text_id = "menu_music_select_random_ingame"
				})
			end
		end
	end

	table.insert(music_select_options, 1, {
		_meta = "option",
		value = "none",
		text_id = "menu_music_select_none"
	})

	return music_select_options
end)

function MenuCallbackHandler:choice_track_select(item)
	local source_menu_name = item:parameter("menu_name")
	if source_menu_name == "menu_pause" then
		if Util:is_in_state("ingame_waiting_for_players") then
			-- update kit menu item
			local submenu = managers.menu:active_submenu("kit_menu")
			if submenu then
				local ts_item = submenu.logic:selected_node():item("track_select")
				if ts_item then
					ts_item:set_value(item:value())
				end
			end
		end
	end

	managers.music:set_track(item:value() ~= "none" and item:value())
end