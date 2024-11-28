local module = ...

local HUDManager = module:hook_class("HUDManager")
local is_PS3 = SystemInfo:platform() == Idstring("PS3")

-- chat_input function
module:hook(HUDManager, "_player_info_hud_layout", function(self)
	module:call_orig(HUDManager, "_player_info_hud_layout", self)
	
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	local state = full_hud:chat_output_state()
	
	if not is_PS3 then
		local say_text = full_hud.panel:child("say_text")
		say_text:set_font_size(tweak_data.hud.chatinput_size)
		local _, _, w, h = say_text:text_rect()
		
		local chatY = hud.health_panel:top() + self._saferect_size.y * self._workspace_size.h - 43 -- default is just 4
		say_text:set_size(w, h)
		say_text:set_position(21, chatY) -- default is (4,4)
		full_hud.panel:child("chat_input"):set_size(500 * tweak_data.scale.chat_multiplier, 25 * tweak_data.scale.chat_multiplier)
		full_hud.panel:child("chat_input"):set_y(chatY) -- default is [4]
		full_hud.panel:child("chat_input"):set_left(say_text:right())
		full_hud.panel:child("chat_input"):script().text:set_font_size(tweak_data.hud.chatinput_size)
		full_hud.panel:child("textscroll"):set_size(400 * tweak_data.scale.chat_multiplier, 118 * tweak_data.scale.chat_multiplier)
		full_hud.panel:child("textscroll"):script().scrollus:set_font_size(tweak_data.hud.chatoutput_size)
		full_hud.panel:child("textscroll"):set_x(4)
		self:_layout_chat_output()
	end
end)

-- move chatGUI up for chat_input location
module:hook(HUDManager, "_layout_chat_output", function(self)
	module:call_orig(HUDManager, "_layout_chat_output", self)
	
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	local state = full_hud:chat_output_state()
	
	if state == "default" then
		full_hud.panel:child("textscroll"):set_bottom(hud.health_panel:top() + self._saferect_size.y * self._workspace_size.h - 48) -- default is [- 12]
	else
		full_hud.panel:child("textscroll"):set_bottom(hud.health_panel:bottom() + self._saferect_size.y * self._workspace_size.h + 11)-- default is [- 4]
	end
end)

-- move endscreen chat loaction
module:hook(HUDManager, "set_chat_output_state", function(self, state)
	
	if is_PS3 then
		return
	end
	
	if not self:alive(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN) then
		return
	end
	
	local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	--full_hud:set_chat_output_state(state)
	
----------------------------add new code---------------------------------------
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	local say_text = full_hud.panel:child("say_text")
	say_text:set_font_size(tweak_data.hud.chatinput_size)
	local _, _, w, h = say_text:text_rect()

	local inputY = hud.health_panel:top() + self._saferect_size.y * self._workspace_size.h - 35
	full_hud.panel:child("textscroll"):set_bottom(inputY + 125)
	say_text:set_position(21, inputY + 130)
	full_hud.panel:child("chat_input"):set_y(inputY + 130)
end)