local module = ... or D:module("zneixs_fixes")
local TweakData = module:hook_class("TweakData")

module.custom_color = nil -- little hack to avoid calling D:conf on every message

module:post_hook(TweakData, "init", function(self)
	local setting = D:conf("zfx_chat_lobby_message_title_color")

	-- deal with a user-defined colour
	if type(setting) == "string" and _G.Color[setting] ~= nil then
		module.custom_color = _G.Color[setting]
	else
		-- set the colour directly to the setting's value (even if it's nil, we will just remove the colour)
		module.custom_color = setting
	end

	-- assigning a metatable to chat_colors in order to return the config value for every non-existing index
	setmetatable(self.chat_colors, {
		__index = function(t, k)
			return rawget(t, k) or module.custom_color
		end
	})
end, false)
