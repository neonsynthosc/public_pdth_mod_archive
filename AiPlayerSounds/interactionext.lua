local module = DorHUD:module('ailinesforplayer')
local ReviveInteractionExt = module:hook_class("ReviveInteractionExt")
module:hook(ReviveInteractionExt, "_at_interact_start_revive", function(self, player)
	module:call_orig(ReviveInteractionExt, "_at_interact_start_revive", self, player)
	if player:base().is_local_player then
		local t = TimerManager:game():time()
		local downed_time = self._unit:character_damage():down_time()
		if downed_time and (not managers.player._revive_line_t or managers.player._revive_line_t < t) then
			local suffix = "a"
			if downed_time <= tweak_data.player.damage.DOWNED_TIME_MIN then
				suffix = "c"
			elseif downed_time <= tweak_data.player.damage.DOWNED_TIME / 2 + tweak_data.player.damage.DOWNED_TIME_DEC then
				suffix = "b"
			end
			player:sound():say("s09" .. suffix, true)
			managers.player._revive_line_t = t + tweak_data.interaction.revive.timer - 1
		end
	end
end)