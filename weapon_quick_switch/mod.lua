-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

-- Quick Weapon Switch mod (like cs) for PAYDAY: The Heist.

local module = DMod:new("weapon_quick_switch", {
	abbr = "QWS", version = "1.0",
	author = "dorentuz", description = {
		english = "Quick weapon switching."
	},
	update = { id = "pdthqws", url = "https://www.dropbox.com/s/0jv6pny4g8xgc14/version.txt?dl=1" },
})

module:hook_post_require("lib/units/beings/player/playerinventory", function()
	local equip_selection_orig = PlayerInventory.equip_selection
	function PlayerInventory:equip_selection(selection_index, instant)
		if selection_index and selection_index ~= self._equipped_selection and self._available_selections[selection_index] then
			if self._equipped_selection then
				self._prev_equipped_selection = self._equipped_selection
			end
		end
		return equip_selection_orig(self, selection_index, instant)
	end
end)

module:hook_post_require("lib/units/beings/player/states/playerstandard", function()
	local check_change_weapon_orig = PlayerStandard._check_change_weapon
	function PlayerStandard:_check_change_weapon(t, input)
		local new_action = check_change_weapon_orig(self, t, input)
		if not new_action and input.btn_last_weapon_press then
			local action_forbidden = self:_changing_weapon()
			action_forbidden = action_forbidden or self._melee_expire_t or self._use_item_expire_t or self._change_item_expire_t
			action_forbidden = action_forbidden or self._unit:inventory():num_selections() == 1 or self:_interacting()
			if not action_forbidden then
				local data = {}
				local last_weapon_selection = self._ext_inventory._prev_equipped_selection
				if last_weapon_selection then
					data.selection_wanted = last_weapon_selection
					local currently_equipped = self._ext_inventory._equipped_selection
					do	-- add a nice controller animation on the hud, because why not
						local d = currently_equipped < last_weapon_selection
							and (currently_equipped == last_weapon_selection - 1 and 1 or -1)
							or  (currently_equipped == last_weapon_selection + 1 and -1 or 1)
						managers.hud:pressed_d_pad(d > 0 and "right" or "left")
					end
				else
					-- nothing defined, use next weapon
					data.next = true
					managers.hud:pressed_d_pad("right")
				end
				self._change_weapon_pressed_expire_t = t + 0.33
				self:_start_action_unequip_weapon(t, data)
				new_action = true
			end
		end
		return new_action
	end

	local get_input_orig = PlayerStandard._get_input
	function PlayerStandard:_get_input(t, dt)
		local input = get_input_orig(self, t, dt)
		if self._input_ext ~= nil then
			if not table.empty(self._input_ext) then
				table.merge(input, self._input_ext)
			end
			self._input_ext = nil
		end
		return input
	end
end)

module:hook("OnKeyPressed", "equip_last_used_weapon", "q", "GAME", function(input_pressed)
	local player_unit = managers.player:player_unit()
	if not alive(player_unit) then
		return
	end

	local k = "btn_last_weapon_press"
	local self = player_unit:movement()._current_state
	if self._input_ext == nil then
		self._input_ext = { [k] = input_pressed }
	else
		self._input_ext[k] = input_pressed
	end
end)

module:add_menu_option("equip_last_used_weapon", {
	type = "keybind",
	localize = false, -- avoid bug in old framework version
	text_id = {
		english = "Quick switch weapon"
	}
})

return module