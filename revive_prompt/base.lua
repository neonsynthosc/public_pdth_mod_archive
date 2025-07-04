return DMod:new("revive_prompt", {
	name = "Teammate name in revive prompt",
	description = "Show your teammates nick name in the interaction prompt.",
	author = "_atom",
	localization = {
		debug_interact_revive = "hold $BTN_INTERACT; to help $TEAMMATE; up",
	},
	hooks = {
		["lib/units/interactions/interactionext"] = function(module)
			local ReviveInteractionExt = module:hook_class("ReviveInteractionExt")
			function ReviveInteractionExt:selected(player)
				self.super.selected(self, player)

				local text = managers.localization:text(self._tweak_data.text_id, {
					BTN_INTERACT = self:_btn_interact(),
					TEAMMATE = self._unit:base():nick_name(),
				})
				local icon = self._tweak_data.icon

				managers.hud:show_interact({ text = text, icon = icon })
			end
		end,
	},
})
