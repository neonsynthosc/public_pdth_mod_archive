-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("endgame_stats_plus")
local NetworkPeer = module:hook_class("NetworkPeer")

NetworkPeer._stats_translation_map = {
	peer_id = false, -- remove
	kills = "total_kills",
	sp_kills = "total_specials_kills",
	civ_kills = "total_civilians_kills",
	headshots = "total_head_shots",
	-- accuracy = "accuracy",
	-- downs = "downs",
	time = "time_played",
	is_dropin = "is_dropin"
}

module:hook(NetworkPeer, "set_statistics2", function(self, stats, merge)
	if stats and not tablex.empty(stats) then
		if merge then
			self._statistics = tablex.merge(self._statistics or {}, stats)
		else
			self._statistics = stats
		end
		self:call_listeners("game_stats", self._statistics)
	end
end, false)