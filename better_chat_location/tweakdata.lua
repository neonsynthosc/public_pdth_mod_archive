local module = ...

local TweakData = module:hook_class("TweakData")

-- size up chatGUI for easy to read
module:hook(TweakData, "set_hud_values", function(self)
	module:call_orig(TweakData, "set_hud_values", self)
	self.hud.chatoutput_size = 16 * self.scale.small_font_multiplier -- default is [14]
	self.hud.chatinput_size = 24 * self.scale.hud_default_font_multiplier -- default is [22]
end)