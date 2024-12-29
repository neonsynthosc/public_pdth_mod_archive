-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = DMod:new("endgame_stats_plus", {
	abbr = "ESP", author = "dorentuz", bundle = "extra", sync = true,
	dependencies = { "hud", "improved_stat_tracking" }, categories = { "hud", "info" },
	description = "Show additional statistics at the end screen. This both expands on the available categories and adds team AI statistics."
})

-- default config; strings support argument reordering (e.g. %3$s is the third argument and should be a string)
module:add_config_option("endgame_stats_show_ai_stats", true) -- include ai stats in the group total (host only)
module:add_config_option("show_shared_top_stats", true)
module:add_config_option("show_extra_stats", true)

-- localization
module:add_localization_string("endgame_stats_group_total", {
	english = "$GROUP_TOTAL; ($PLAYER_TOTAL; by players + $AI_TOTAL; by bots)",
	french  = "$GROUP_TOTAL; ($PLAYER_TOTAL; par joueur + $AI_TOTAL; par les bots)",
	german  = "$GROUP_TOTAL; ($PLAYER_TOTAL; von Spielern + $AI_TOTAL; von Bots)",
	italian = "$GROUP_TOTAL; ($PLAYER_TOTAL; dai giocatori + $AI_TOTAL; dai bot)",
	korean  = "$GROUP_TOTAL; ($PLAYER_TOTAL; 플레이어 + $AI_TOTAL; 봇)",
	russian = "$GROUP_TOTAL; ($PLAYER_TOTAL; игроки + $AI_TOTAL; боты)",
	spanish = "$GROUP_TOTAL; ($PLAYER_TOTAL; por jugadores + $AI_TOTAL; por bots)",
})

module:add_localization_string("victory_most_head_shots", {
	english = "MOST HEADSHOTS:",
})
module:add_localization_string("victory_most_head_shots_name", {
	english = "$PLAYER_NAME; ($SCORE;)",
})
module:add_localization_string("victory_best_civilians_killer", {
	english = "HIGHEST CIVILIANS BODY COUNT:",
})
module:add_localization_string("victory_best_civilians_killer_name", {
	english = "$PLAYER_NAME; ($SCORE;)",
})
module:add_localization_string("victory_total_civilians_kills", {
	english = "CREW CIVILIANS BODY COUNT:",
})

-- script overrides
module:hook_post_require("lib/managers/hudmanager", "hudmanager")
module:hook_post_require("lib/network/networkgame", "networkgame")
module:hook_post_require("lib/network/networkpeer", "networkpeer")
module:hook_post_require("lib/states/missionendstate", "missionendstate")

--module.endgame_show_player_stats = true -- still very broken
if module.endgame_show_player_stats then
	D:hook("OnNetworkDataRecv", "OnNetworkDataRecv_CollectGameStats", "GameStats", function(peer, data_type, data)
		if data_type ~= "GameStats" or not data or not data.peer_id then
			return
		end

		if peer:id() == data.peer_id or peer:is_server() then
			local target_peer = peer
			if peer:id() ~= data.peer_id then
				target_peer = managers.network:session() and managers.network:session():peer(data.peer_id)
			end

			if target_peer and (not target_peer:has_statistics() or not target_peer:statistics().time_played) then
				target_peer:set_statistics(data.kills, data.sp_kills, data.headshots, data.accuracy, data.downs, data.time, data.is_dropin)
			end
		end
	end)

	local function update_hud_stats()
		managers.hud:update_hud_visibility()
	end

	D:hook("OnEnteredLobby", "OnEnteredLobby_ShowLocalPeerStats", function(state, level)
		managers.network:session():local_peer():add_listener("OnGameStatsEvent_ShowLocalStatsOnHud", "game_stats", update_hud_stats)
	end)

	D:hook("OnPeerAdded", "OnPeerAdded_ShowPeerStatsOnHud", function(peer)
		peer:add_listener("OnGameStatsEvent_LogStats", "game_stats", update_hud_stats)
	end)

	module:hook("OnGameStateChange", "OnGameStateChange_ShowEndgamePlayerStats", function(old_state, new_state)
		if new_state == "gameoverscreen" or new_state == "victoryscreen" then
			dlog(">>>>> update hud vis")
			managers.hud:update_hud_visibility()
		end
	end)
end

-- register module
return module