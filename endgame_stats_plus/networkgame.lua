-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("endgame_stats_plus")
local NetworkGame = module:hook_class("NetworkGame")

module:post_hook(NetworkGame, "on_statistics_recieved", function(self)
	for i = 1, tweak_data.max_players or 4 do
		local member = self._members[i]
		if member ~= nil and member:peer():waiting_for_player_ready() and not member:peer():has_statistics() then
			return
		end
	end
	
	if D:conf('endgame_stats_show_ai_stats') and game_state_machine:current_state().on_statistics_result_ai_extra then
		local stats = managers.statistics
		local ai_kills = stats:session_total_ai_kills()
		local ai_special_kills = stats:session_total_special_ai_kills()
		local ai_downs = stats:session_total_ai_downs()
		
		game_state_machine:current_state():on_statistics_result_ai_extra(ai_kills, ai_special_kills, ai_downs)
	end
end, false)