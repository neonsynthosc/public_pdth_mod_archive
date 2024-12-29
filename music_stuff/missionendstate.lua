-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("music_stuff")
local MissionEndState = module:hook_class("MissionEndState")

module:hook(MissionEndState, "at_enter", function(self, old_state, params)
	module:call_orig(MissionEndState, "at_enter", self, old_state, params)

	local session_result = managers.statistics:session_result()

	dlog(">>>>> MissionEndState post event menu_music")
	managers.music:post_event(
		Global.level_data.level_id,
		session_result and "resultscreen_win" or "resultscreen_lose",
		true
	)
end)