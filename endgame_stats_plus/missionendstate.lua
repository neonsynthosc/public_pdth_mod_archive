-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("endgame_stats_plus")
local MissionEndState = module:hook_class("MissionEndState")

-- module:post_hook(MissionEndState, "at_enter", function(self, old_state, params)
	-- local function update_saferect(self)
		-- local victoryscreen = managers.hud:script(self.GUI_SAFERECT)
		-- if alive(victoryscreen.time_played) and victoryscreen.time_played:text() then
			-- local new_text = string.extformat(
				-- DorHUD:conf("endgame_stats_endtime") or "",
				-- victoryscreen.time_played:text(),
				-- Network:is_server() and DorHUDLocalizer:local_variant(DorHUD:conf("endgame_stats_endtime_host_part")) or "",
				-- managers.statistics:is_dropin() and DorHUDLocalizer:local_variant(DorHUD:conf("endgame_stats_endtime_dropin_part")) or ""
			-- )
			
			-- if not string.empty(string.trim(new_text or "")) then
				-- victoryscreen.time_played:set_text(new_text)
			-- end
		-- end
	-- end
	
	-- if rawget(_G, "pcall") then
		-- pcall(update_saferect, self)
	-- else
		-- update_saferect(self)
	-- end
-- end, false)

module:hook(MissionEndState, "on_statistics_result_ai_extra", function(self, ai_kills, ai_specials_kills, ai_downs)
	if managers.network and managers.network:session() then
		local updated_text_fmt = D:conf('endgame_stats_group_total')
		local gui_script = managers.hud:script(self.GUI_SAFERECT)
		
		module:log(2, "MissionEndState:on_statistics_result_ai_extra", "ai stats received:", string.format(
			"kills: %s, sp. kills: %s, downs: %s", tostring(ai_kills), tostring(ai_specials_kills), tostring(ai_downs)
		))
		
		if ai_kills and ai_kills > 0 then
			local group_kills = tonumber(gui_script.group_total_kills:text()) or 0
			local total_group_kills = group_kills + (ai_kills or 0)
			if total_group_kills > 0 then
				gui_script.group_total_kills:set_text(managers.localization:text("endgame_stats_group_total", {
					GROUP_TOTAL = total_group_kills, PLAYER_TOTAL = group_kills, AI_TOTAL = ai_kills
				}))
			end
		end
		
		if ai_specials_kills and ai_specials_kills > 0 then
			local group_specials_kills = tonumber(gui_script.group_total_specials_kills:text()) or 0
			local total_group_specials_kills = group_specials_kills + (ai_specials_kills or 0)
			if total_group_specials_kills > 0 then
				gui_script.group_total_specials_kills:set_text(managers.localization:text("endgame_stats_group_total", {
					GROUP_TOTAL = total_group_specials_kills, PLAYER_TOTAL = group_specials_kills, AI_TOTAL = ai_specials_kills
				}))
			end
		end
		
		if ai_downs and ai_downs > 0 then
			local group_downs = tonumber(gui_script.group_total_downs:text()) or 0
			local total_group_downs = group_downs + (ai_downs or 0)
			if total_group_downs > 0 then
				gui_script.group_total_downs:set_text(managers.localization:text("endgame_stats_group_total", {
					GROUP_TOTAL = total_group_downs, PLAYER_TOTAL = group_downs, AI_TOTAL = ai_downs
				}))
			end
		end
	end
end, false)