local module = ... or D:module("zneixs_fixes")
local PlayerStandard = module:hook_class("PlayerStandard")

-- make AK always use full reload's animation
-- TODO: consider a better solution for having a dynamic reaction to config updates but also to not litter hooks when it's not needed (due to disabling a fix option)
module:hook(PlayerStandard, "_start_action_reload", function(self, t)
	if self._equipped_unit:base():can_reload() then
		self._equipped_unit:base():tweak_data_anim_stop("fire")
		local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		local reload_anim
		if self._equipped_unit:base():clip_empty() then
			local result = self._unit:camera():play_redirect(Idstring("reload_" .. self._equipped_unit:base().name_id), speed_multiplier)
			self._reload_expire_t = t + (tweak_data.timers.reload_empty or self._equipped_unit:base():reload_expire_t() or 2.6) / speed_multiplier
		else
			-- we're meant to perform not-full, quicker variant of reload
			-- the only change is in this block - first 2 out of 3 lines are custom
			if self._equipped_unit:base().name_id == "ak47" and D:conf("zfx_always_full_reload_ak") then
				reload_anim = "reload"
				local result = self._unit:camera():play_redirect(Idstring("reload_" .. self._equipped_unit:base().name_id), speed_multiplier * (tweak_data.timers.reload_empty / tweak_data.timers.reload_not_empty))
			else
				reload_anim = "reload_not_empty"
				local result = self._unit:camera():play_redirect(Idstring("reload_not_empty_" .. self._equipped_unit:base().name_id), speed_multiplier)
			end
			self._reload_expire_t = t + (tweak_data.timers.reload_not_empty or self._equipped_unit:base():reload_expire_t() or 2.2) / speed_multiplier
		end
		self._equipped_unit:base():start_reload()
		if not self._equipped_unit:base():tweak_data_anim_play(reload_anim, speed_multiplier) then
			self._equipped_unit:base():tweak_data_anim_play("reload", speed_multiplier)
		end
		if self._ext_network then
			self._ext_network:send("reload_weapon")
		end
	end
end)
