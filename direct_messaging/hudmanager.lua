-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("direct_messaging")
local HUDManager = module:hook_class("HUDManager")

local PLAYER_INFO_HUD_IDS = Idstring("guis/player_info_hud")
local PLAYER_INFO_HUD_FULLSCREEN_IDS = Idstring("guis/player_info_hud_fullscreen")

module:hook(45, HUDManager, "_update_chat_input_for_target", function(self, target_peer)
	if not self:alive(PLAYER_INFO_HUD_FULLSCREEN_IDS) then
		return
	end

	local hud = managers.hud:script(PLAYER_INFO_HUD_FULLSCREEN_IDS)
	local chat_label = hud.panel:child("say_text")
	local chat_input = hud.panel:child("chat_input")
	if not alive(chat_label) or not alive(chat_input) then
		return
	end

	-- determine label text (and colors)
	local text, colors = nil
	if target_peer then
		text, colors = StringUtils:parse_color_string_utf8(
			managers.localization:text("debug_chat_say_dm", {
				NAME = target_peer:name(true):gsub("%[", "%[%[") -- escape for colorization
			}),
			{ peer_color = tweak_data.chat_colors[target_peer:id()] }
		)
	else
		text = managers.localization:text("debug_chat_say")
	end

	-- ensure upper case *after* colors have been parsed and save colors for later use
	text = text:utf8_upper()
	chat_label:set_text(text)
	if colors and colors[1] ~= nil then
		for i = 1, #colors do
			local c = colors[i]
			chat_label:set_range_color(c.i - 1, c.j, c.color)
		end
	end

	-- align elements
	chat_label:set_size(select(3, chat_label:text_rect()))
	chat_input:set_left(chat_label:right())
end, false)

module:pre_hook(HUDManager, "_add_mugshot", function(self, data, mugshot_data)
	local mugshot_is_preselected = false
	if self._selected_mugshot then
		local selection_data = self._selected_mugshot
		if selection_data.character_name_id == mugshot_data.character_name_id then
			mugshot_is_preselected = true
		elseif selection_data.character_name_id == nil and mugshot_data.peer_id and selection_data.peer_id == mugshot_data.peer_id then
			mugshot_is_preselected = true
		end

		if mugshot_is_preselected then
			selection_data.character_name_id = mugshot_data.character_name_id
			selection_data.id = mugshot_data.id
		end
	end

	local hud = managers.hud:script(PLAYER_INFO_HUD_IDS)
	mugshot_data.selection_marker = hud.panel:rect({
		name = "selection_marker_" .. mugshot_data.id,
		w = tweak_data.menu.selected_mugshot_marker_width or 2,
		h = mugshot_data.panel:h(),
		color = tweak_data.menu.selected_mugshot_marker_color or Color.white:with_alpha(0.7),
		visible = mugshot_is_preselected
	})
end, false)

module:pre_hook(HUDManager, "_remove_mugshot", function(self, id)
	local mugshot_data = self:_get_mugshot_data(id)
	if not mugshot_data or not alive(mugshot_data.selection_marker) then
		return
	end

	local hud = managers.hud:script(PLAYER_INFO_HUD_FULLSCREEN_IDS)
	if not hud then
		return
	end

	mugshot_data.selection_marker:parent():remove(mugshot_data.selection_marker)
end, false)

module:post_hook(50, HUDManager, "_layout_mugshot", function(self, mugshot_data)
	if alive(mugshot_data.selection_marker) then
		local w = mugshot_data.selection_marker:w()
		local panel_x, panel_y, _, panel_h = mugshot_data.panel:shape()
		mugshot_data.selection_marker:set_shape(panel_x, panel_y, w, panel_h)
		mugshot_data.panel:set_x(panel_x + w)
	end
end, false)

module:hook(45, HUDManager, "set_selected_mugshot", function(self, mugshot_data_or_id, peer_id)
	-- deselect previous one
	if self._selected_mugshot then
		local old_data = self:_get_mugshot_data(self._selected_mugshot.id)
		if old_data and alive(old_data.selection_marker) then
			old_data.selection_marker:hide()
		end

		self._selected_mugshot = false
	end

	local mugshot_id, mugshot_data
	if type(mugshot_data_or_id) == "number" then
		mugshot_id = mugshot_data_or_id
		mugshot_data = self:_get_mugshot_data(mugshot_id)
	elseif type(mugshot_data_or_id) == "table" then
		mugshot_data = mugshot_data_or_id
		mugshot_id = mugshot_data.id
	end

	if not mugshot_data then
		if peer_id then
			-- mugshots haven't been created yet, preselect one based on the peer id
			self._selected_mugshot = { peer_id = peer_id }
		end

		return
	end
	
	-- select new one
	if alive(mugshot_data.selection_marker) then
		self._selected_mugshot = {
			id = mugshot_id,
			peer_id = mugshot_data.peer_id,
			character_id = mugshot_data.character_name_id
		}

		if alive(mugshot_data.panel) and mugshot_data.panel:visible() then
			mugshot_data.selection_marker:show()
			return true
		end

		return false
	end
end, true)