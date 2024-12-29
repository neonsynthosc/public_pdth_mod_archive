-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ...
core:module("CoreElementMusic")

local ElementMusic = module:hook_env_class(getfenv(), "ElementMusic")
module:hook(30, ElementMusic, "on_executed", function(self, instigator)
	if not self._values.enabled then
		return
	end

	module:call_orig(ElementMusic, "on_executed", self, instigator)

	if self._values.music_event then
		managers.music:post_event(Global.level_data.level_id, self._values.music_event)
	end
end)