local module = ... or D:module("zneixs_fixes")
local WeaponTweakData = module:hook_class("WeaponTweakData")

-- make AK always use full reload's animation
module:post_hook(WeaponTweakData, "_init_data_player_weapons", function(self)
	if D:conf("zfx_always_full_reload_ak") then
		self.ak47.animations.reload_not_empty = "reload"
	end
end)
