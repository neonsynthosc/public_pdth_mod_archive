-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("direct_messaging")
local MenuLobbyRenderer = module:hook_class("MenuLobbyRenderer")

module:post_hook(MenuLobbyRenderer, "open", function(self)
	local player_slots = self._player_slots
	local N = #player_slots
	for i = 1, N do
		local slot = player_slots[i]
		slot.selection_marker = self.safe_rect_panel:rect({
			name = "selection_marker_" .. i,
			w = tweak_data.menu.selected_slot_marker_width or 2,
			h = slot.panel:h(),
			x = 0, y = self._info_bg_rect:y() + tweak_data.menu.info_padding + slot.panel:y(),
			color = tweak_data.menu.selected_slot_marker_color or Color.white:with_alpha(0.7),
			visible = false
		})
	end
end, false)

module:post_hook(50, MenuLobbyRenderer, "_layout_info_panel", function(self)
	local player_slots = self._player_slots
	for i = 1, #player_slots do
		local slot = player_slots[i]
		if alive(slot.selection_marker) then
			local panel_x, panel_y, _, panel_h = slot.panel:shape()
			panel_y = panel_y + self._info_bg_rect:y() + tweak_data.menu.info_padding

			local w = slot.selection_marker:w()
			slot.selection_marker:set_shape(0, panel_y, w, panel_h)
		end
	end
end, false)

module:hook(45, MenuLobbyRenderer, "set_selected_slot", function(self, nr)
	-- deselect previous one
	if self._selected_slot then
		local old_slot = self._player_slots[self._selected_slot]
		if old_slot and alive(old_slot.selection_marker) then
			old_slot.selection_marker:hide()
		end

		self._selected_slot = false
	end


	local slot = nr and self._player_slots[nr]
	if not slot or not alive(slot.selection_marker) then
		self._selected_slot = false
		return
	end
	
	-- select new one
	self._selected_slot = nr
	slot.selection_marker:show()
end)

module:hook(45, MenuLobbyRenderer, "_update_chat_input_for_target", function(self, target_peer)
	-- TODO: idk how to give feedback other than the slot selection
end)