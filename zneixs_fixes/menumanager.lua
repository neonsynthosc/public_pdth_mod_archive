local module = ... or D:module("zneixs_fixes")
local MenuCallbackHandler = module:hook_class("MenuCallbackHandler")
local MenuSTEAMHostBrowser = module:hook_class("MenuSTEAMHostBrowser")

-- replace the original quit_game function entirely
module:hook(MenuCallbackHandler, "quit_game", function(self)
	if not D:conf("zfx_simplify_quit_dialog") then
		return module:call_orig(MenuCallbackHandler, "quit_game", self)
	end

	return managers.system_menu:show({
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_to_quit"),
		button_list = {
			-- yes_save_button
			{
				text = managers.localization:text("dialog_yes_save"),
				callback_func = callback(self, self, "_dialog_save_progress_backup_yes"),
			},
			-- yes_dont_save_button
			{
				text = managers.localization:text("dialog_yes_dont_save"),
				callback_func = callback(self, self, "_dialog_save_progress_backup_no"),
			},
			-- no_button
			{
				text = managers.localization:text("dialog_no"),
				callback_func = callback(self, self, "_dialog_quit_no"),
				cancel_button = true,
			},
		},
		focus_button = 1,
	})
end, false)

-- show game difficulty in the lobby browser entry
module:post_hook(MenuSTEAMHostBrowser, "set_item_room_columns", function(self, params, room, attributes)
	-- we patch an override from matchmaking_common/menumanager.lua, it has the following columns:
	--string.utf8_upper(params.host_name),
	--string.utf8_upper(params.real_level_name),
	--string.utf8_upper(params.state_name), -- original which we replace
	--string.format("%s/%s ", tostring(params.num_plrs), tostring(tweak_data.max_players or 4))

	if D:conf("zfx_show_difficulty_in_lobby_browser") then
		-- XXX: Isn't there a better way to do this?
		params.columns[3] = string.format("%s%12s", string.gsub(string.utf8_upper(params.difficulty), "_", " "), string.utf8_upper(params.state_name))
	end
end, false)
