local module = ... or D:module("zneixs_fixes")
local HUDManager = module:hook_class("HUDManager")

module:post_hook(HUDManager, "update_hud_settings", function(self)
	local var_cache = self._cached_conf_vars

	-- keep a copy of the format for a timer of an actual assault
	-- to be able to restore it later once assault starts again
	var_cache._sl_assault_timer_format = var_cache.sl_assault_timer_format
end, false)

module:post_hook(HUDManager, "sync_start_assault", function(self)
	local var_cache = self._cached_conf_vars

	-- restore original value of "sl_assault_timer_format"
	module:log(5, "HUDManager:sync_start_assault", "restoring original assault timer format")
	var_cache.sl_assault_timer_format = var_cache._sl_assault_timer_format

	-- Disable assault image and title
	local hud = self:script(PlayerBase.PLAYER_INFO_HUD)
	if hud and D:conf("zfx_disable_assault_image") then
		hud.assault_image:set_visible(false)
		hud.assault_image:stop()
		hud.control_assault_title:set_visible(false)
		hud.control_assault_title:stop()
		hud.control_hostages:set_color(Color.white)
	end
end, false)

module:post_hook(HUDManager, "sync_end_assault", function(self)
	local var_cache = self._cached_conf_vars

	-- overwrite "sl_assault_timer_format" to respect custom assault break timer config option
	local assault_break_timer = D:conf("zfx_assault_break_timer_str")
	module:log(5, "HUDManager:sync_end_assault", "patching assault timer format with assault break one: " .. assault_break_timer)

	if type(assault_break_timer) == "string" and assault_break_timer ~= "" then
		var_cache.sl_assault_timer_format = assault_break_timer
	end
end, false)
