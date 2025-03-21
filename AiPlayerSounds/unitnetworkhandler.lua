local module = DorHUD:module('ailinesforplayer')
local UnitNetworkHandler = module:hook_class("UnitNetworkHandler")

module:hook(UnitNetworkHandler, "long_dis_interacted", function(self, unit, sender)
	module:call_orig(UnitNetworkHandler, "long_dis_interacted", self, unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end
	local player = managers.player:player_unit()
	if player and alive(player) then
		player:sound():say(unit:movement():downed() and "r02a_sin" or "r01x_sin", true)
	end
end)