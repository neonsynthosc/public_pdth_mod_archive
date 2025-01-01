-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ...
local GroupAIStateBase = module:hook_class("GroupAIStateBase")

module:hook(GroupAIStateBase, "set_assault_mode", function(self, enabled)
	if self._assault_mode ~= enabled then
		self._assault_mode = enabled
		managers.network:session():send_to_peers_synched("sync_assault_mode", enabled)
		if not enabled then
			self._warned_about_deploy_this_control = nil
			self._warned_about_freed_this_control = nil
			if table.size(self:all_char_criminals()) == 1 then
				self._coach_clbk = callback(self, self, "_coach_last_man_clbk")
				managers.enemy:add_delayed_clbk("_coach_last_man_clbk", self._coach_clbk, Application:time() + 15)
			end
		end

		managers.music:set_flag_state("wave_flag", enabled and "assault" or "control")
	end

	self:_update_lightfx_state()
end)

module:hook(GroupAIStateBase, "sync_assault_mode", function(self, enabled)
	if self._assault_mode ~= enabled then
		self._assault_mode = enabled
		managers.music:set_flag_state("wave_flag", enabled and "assault" or "control")
	end

	self:_update_lightfx_state()
end)

module:hook(GroupAIStateBase, "set_fake_assault_mode", function(self, enabled)
	if self._fake_assault_mode ~= enabled then
		self._fake_assault_mode = enabled
		if self._assault_mode ~= enabled or not self._assault_mode then
			managers.music:set_flag_state("wave_flag", enabled and "assault" or "control")
			managers.music:post_event(Global.level_data.level_id, enabled and "fake_assault" or "control")
		end
	end
end)

module:hook(GroupAIStateBase, "_update_lightfx_state", function(self)
	if managers.network and managers.network.account:has_alienware() then
		if rawget(_G, "LightFxUtil") then
			if self._assault_mode then
				LightFxUtil:post_event("assault_mode")
			else
				LightFxUtil:post_event("control_mode")
			end
		else
			if self._assault_mode then
				LightFX:set_lamps(255, 0, 0, 255)
			else
				LightFX:set_lamps(0, 255, 0, 255)
			end
		end
	end
end)