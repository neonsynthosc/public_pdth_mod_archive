-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ...
local HUDManager = module:hook_class("HUDManager")

module:hook(HUDManager, "sync_start_assault", function(self, data)
	managers.music:post_event(Global.level_data.level_id, "assault")
	return module:call_orig(HUDManager, "sync_start_assault", self, data)
end)

module:hook(HUDManager, "sync_end_assault", function(self, result)
	managers.music:post_event(Global.level_data.level_id, "control")
	return module:call_orig(HUDManager, "sync_end_assault", self, result)
end)

module:hook(HUDManager, "sync_start_anticipation_music", function(self)
	managers.music:post_event(Global.level_data.level_id, "anticipation")
end)