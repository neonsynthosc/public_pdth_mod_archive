local module = ... or DorHUD:module("juke_box")

local LevelsTweakData = module:hook_class("LevelsTweakData")
module:hook(LevelsTweakData, "init", function(self)
module:call_orig(LevelsTweakData, "init", self)

for _, level_id in pairs({ "bank", "heat_street", "bridge", "apartment", "diamond_heist", "suburbia", "slaughter_house", "secret_stash", "hospital" }) do
	local music_override = DorHUD:conf(level_id .. "_music")
		if music_override then
			self[level_id].music = music_override
		end
	end
end)
