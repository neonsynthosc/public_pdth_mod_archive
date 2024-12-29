-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("endgame_stats_plus")
local HUDManager = module:hook_class("HUDManager")

local PLAYER_INFO_HUD_IDS = Idstring("guis/player_info_hud")
local PLAYER_INFO_HUD_KEY = PLAYER_INFO_HUD_IDS:key()

module:post_hook(HUDManager, "update_hud_settings", function(self)
	if Util:is_in_state("any_end_game") then
		local var_cache = self._cached_conf_vars
		var_cache.hud_vis_mugshots = true
	end
end, false)

module:post_hook(HUDManager, "update_hud_visibility", function(self, name)
	if Util:is_in_state("any_end_game") then
		if not name or name:key() == PLAYER_INFO_HUD_KEY then
			if self:alive(PLAYER_INFO_HUD_IDS) then
				local hud = self:script(PLAYER_INFO_HUD_IDS)
				local var_cache = self._cached_conf_vars

				for _, mugshot in ipairs(self._hud.mugshots) do
					mugshot.panel:set_visible(var_cache.hud_vis_mugshots)
				end

				local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
				hud.health_panel:set_visible(var_cache.hud_vis_mugshots)
				hud.health_panel:set_bottom(self._saferect_size.y + self._saferect_size.h)
			else
				dlog(">>>>> panel is not alive")
			end
		end
	end
end, false)