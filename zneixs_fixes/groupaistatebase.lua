local module = ... or D:module("zneixs_fixes")
local GroupAIStateBase = module:hook_class("GroupAIStateBase")

-- TODO: Redo this with DAHM's fixed code for LightFX stuff
-- Adds a check for total player count prior to queueing _coach_last_man_clbk
--module:hook(50, GroupAIStateBase, "set_assault_mode", function(self, enabled)
	--if self._assault_mode ~= enabled then
		--self._assault_mode = enabled
		--SoundDevice:set_state("wave_flag", enabled and "assault" or "control")
		--managers.network:session():send_to_peers_synched("sync_assault_mode", enabled)
		--if not enabled then
			--self._warned_about_deploy_this_control = nil
			--self._warned_about_freed_this_control = nil
			--if (managers.network:game():amount_of_members() + table.size(self:all_AI_criminals())) > 1 and table.size(self:all_char_criminals()) == 1 then
				--self._coach_clbk = callback(self, self, "_coach_last_man_clbk")
				--managers.enemy:add_delayed_clbk("_coach_last_man_clbk", self._coach_clbk, Application:time() + 15)
			--end
		--end
	--end

	--if SystemInfo:platform() == Idstring("WIN32") and managers.network.account:has_alienware() then
		--if self._assault_mode then
			--LightFX:set_lamps(255, 0, 0, 255)
		--else
			--LightFX:set_lamps(0, 255, 0, 255)
		--end
	--end
--end, false)

--TODO: this might(?) not work
-- rewrite of original with addition of the second condition block
module:hook(50, GroupAIStateBase, "_coach_last_man_clbk", function(self)
	if table.size(self:all_char_criminals()) == 1 and self:bain_state() then
		if D:conf("zfx_fix_bain_coaching_solo") and (not self:is_AI_enabled()) then
			module:log(3, "GroupAIStateBase:_coach_last_man_clbk", "shutting bain up, because player is alone and AI is disabled, so there's nobody to trade out of custody")
			return
		end
		module:log(5, "GroupAIStateBase:_coach_last_man_clbk", "letting bain speak; ai enabled?", self:is_AI_enabled())
		local _, crim = next(self:all_char_criminals())
		local standing_name = managers.criminals:character_name_by_unit(crim.unit)
		if standing_name == managers.criminals:local_character_name() then
			local ssuffix = managers.criminals:character_static_data_by_name(standing_name).ssuffix
			if self:hostage_count() <= 0 then
				managers.dialog:queue_dialog("ban_h40" .. ssuffix, {})
			else
				managers.dialog:queue_dialog("ban_h42" .. ssuffix, {})
			end
		end
	end
end, false)
