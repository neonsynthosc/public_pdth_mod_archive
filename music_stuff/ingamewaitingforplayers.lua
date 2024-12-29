-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("music_stuff")
local IngameWaitingForPlayersState = module:hook_class("IngameWaitingForPlayersState")

module:hook(IngameWaitingForPlayersState, "at_enter", function(self)
	managers.music:post_event(Global.level_data.level_id, "loadout_music", true, true) -- force it in this state
	module:call_orig(IngameWaitingForPlayersState, "at_enter", self)
end)

module:hook(IngameWaitingForPlayersState, "sync_start", function(self, variant)
	managers.music:post_event(Global.level_data.level_id, "intro")
	return module:call_orig(IngameWaitingForPlayersState, "sync_start", self, variant)
end)

module:hook(IngameWaitingForPlayersState, "at_exit", function(self)
	if self._started_from_beginning then
		managers.music:post_event(Global.level_data.level_id, "intro")
	end
	return module:call_orig(IngameWaitingForPlayersState, "at_exit", self)
end)