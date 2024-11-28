-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("direct_messaging")
local MenuManager = module:hook_class("MenuManager")

local run_in_open_menu = function(func)
	for _, menu_name in pairs({ "kit_menu", "lobby_menu" }) do
		local lobby_menu = managers.menu:get_menu(menu_name)
		if lobby_menu and lobby_menu.renderer:is_open() then
			if func(lobby_menu, lobby_menu.renderer) == false then
				break
			end
		end
	end
end


-- menumanager functions (because we can't use the hudmanager)

module:hook(50, MenuManager, "chat_target", function(self)
	return self._chat_target or false
end, true)

module:hook(MenuManager, "set_chat_target", function(self, peer)
	self._chat_target = peer or false

	if managers.hud then
		managers.hud:_update_chat_input_for_target(self._chat_target)
	end

	run_in_open_menu(function(menu, renderer)
		renderer:_update_chat_input_for_target(self._chat_target)
	end)
end, false)


-- general hooks

module:hook("OnPeerRemoved", "OnPeerRemoved_CheckDMTarget", function(peer)
	local menumanager = managers.menu
	if menumanager and menumanager:chat_target() == peer then
		menumanager:set_chat_target(false)
		if managers.hud then
			managers.hud:set_selected_mugshot(false)
		end

		local menu = managers.menu:active_menu()
		if menu and menu.renderer and menu.renderer.set_selected_slot then
			menu.renderer:set_selected_slot(false)
		end
	end
end)

module:hook("OnCommand", "all", function(args)
	-- simple command to message everyone (useful when in pm mode)
	Util:chat_message(args, true, false, { parse_colors = false })
end)

module:hook("OnKeyPressed", "hud_toggle_marker", nil, function()
	local selected_peer, is_visible = nil, false
	local hudmgr = managers.hud
	local session = managers.network:session()
	local max_players = tweak_data.max_players or 4
	local debug_select_ai = module:conf("debug_allow_ai_selection")
	local debug_select_self = module:conf("debug_allow_self_selection")
	local is_playing = hudmgr and Util:is_in_state("any_ingame_playing")
	local is_endgame = Util:is_in_state("any_end_game")

	if session and is_playing then
		module:log(4, "hud_toggle_marker", "selection based on mugshot order")

		-- nothing selected -> first mugshot
		-- mugshot selected -> next mugshot
		-- last mugshot selected -> unspawned players
		-- unspawned player with highest id -> deselect

		-- selection is based on the mugshots order
		local i, new_selection = 0, false
		local mugshots, active_mugshot = hudmgr._hud.mugshots, hudmgr._selected_mugshot
		if active_mugshot then
			for j = 1, #mugshots do
				if mugshots[j].id == active_mugshot.id then
					i = j
					break
				end
			end
		end

		-- select next (or first) mugshot
		local currently_selected_peer = managers.menu:chat_target()
		for j = (i > 0 or currently_selected_peer) and i - 1 or #mugshots, 1, -1 do
			if debug_select_ai or mugshots[j].peer_id then
				module:log(4, "hud_toggle_marker", "found next mugshot:", j)
				new_selection = mugshots[j].id
				if mugshots[j].peer_id then
					selected_peer = session:peer(mugshots[j].peer_id)
				else
					selected_peer = session:local_peer()
				end

				if selected_peer then
					is_visible = true
					break
				end
			end
		end

		-- check for players that haven't spawned yet if the last mugshot is selected (or when no players have spawned)
		if not new_selection and session then
			-- check for unspawned players
            local current_peer_id = 0
			if currently_selected_peer and i == 0 then
				-- unspawned player is currently selected, next one should have a higher id
				local char_data = managers.criminals:character_data_by_peer_id(currently_selected_peer:id())
				if not char_data or not char_data.mugshot_id then
					current_peer_id = currently_selected_peer:id()
					module:log(4, "hud_toggle_marker", "active peer id:", current_peer_id)
                end
			end

            for j = current_peer_id + 1, max_players do
                local peer = session:peer(j)
                if peer then
                    local char_data = managers.criminals:character_data_by_peer_id(j)
                    if (not char_data or not char_data.mugshot_id) and (debug_select_self or not peer:is_local_user())then
						selected_peer = peer
						module:log(4, "hud_toggle_marker", "new unspawned peer selection:", peer:id())
                        break
                    end
                end
			end
		end

		hudmgr:set_selected_mugshot(new_selection, selected_peer and selected_peer:id())

		-- select peer slot in the lobby menu
		run_in_open_menu(function(menu, renderer)
			renderer:set_selected_slot(selected_peer and selected_peer:id() or false)
		end)
	else
		module:log(4, "hud_toggle_marker", "selection based on player ids")

		-- selection is based on the player ids
		local selected_slot = false

		-- find currently selected slot
		run_in_open_menu(function(menu, renderer)
			selected_slot = renderer._selected_slot
			if selected_slot ~= nil then
				return false
			end
		end)

		if selected_slot == false and is_endgame then
			selected_peer = managers.menu:chat_target()
			if selected_peer then
				selected_slot = selected_peer:id()
				selected_peer = false -- unset in case of self selection
			end
		end

		-- determine which slot follows it (and is taken by a player)
		if selected_slot == max_players then
			selected_slot = false
		elseif session then
			local old_selected_slot = selected_slot or 0
			selected_slot = false

			if debug_select_self or session:amount_of_peers() > 1 then
				for i = old_selected_slot + 1, max_players do
					local peer = session:peer(i)
					if peer and (debug_select_self or not peer:is_local_user()) then
						selected_peer = peer
						selected_slot = i
						break
					end
				end
			end
		end

		-- select slot in the lobby
		run_in_open_menu(function(menu, renderer)
			renderer:set_selected_slot(selected_slot)
		end)

		-- select mugshot on the hud
		if hudmgr then
			if selected_slot then
				is_visible = false
				local mugshots = hudmgr._hud.mugshots
				for j = 1, #mugshots do
					if mugshots[j].peer_id == selected_slot then
						if hudmgr:set_selected_mugshot(mugshots[j].id, selected_slot) then
							is_visible = true
						end
						break
					end
				end
			else
				hudmgr:set_selected_mugshot(false)
			end
		end
	end

	if not debug_select_self and selected_peer and selected_peer:is_local_user() then
		selected_peer = false
	end

	if hudmgr and (selected_peer or managers.menu:chat_target()) then
		if D:conf("dmi_always_show_hints") or (not is_visible and (is_playing or is_endgame)) then
			local supports_colors = false
			if D:has_module("hints") and Util:version_compare(D:version(), "1.8.5") >= 0 then
				supports_colors = true
			end

			local target_name
			if selected_peer then
				target_name = selected_peer:name():gsub("%[", "%[%[") -- escape
			elseif managers.localization:exists("dm_target_all") then
				target_name = managers.localization:text("dm_target_all")
			else
				target_name = "-"
			end

			local hint_text = managers.localization:text("hint_dm_target", { NAME = target_name })
			if not supports_colors then
				hint_text = StringUtils:parse_color_string_utf8(hint_text, false) -- parse to remove colors
			end

			hudmgr:show_hint({
				text = hint_text,
				colors = { peer_color = selected_peer and tweak_data.chat_colors[selected_peer:id()] or nil },
				time = D:conf("dmi_hint_duration") or 1, priority = -1
			}, false)
		end
	end

	module:log(3, "hud_toggle_marker", "new selection:", selected_peer)
	managers.menu:set_chat_target(selected_peer)
end)

module:hook("OnChatInput", "OnChatInput_EatDirectMessages", function(message, is_eaten)
	if is_eaten then
		return
	end

	local session = managers.network and managers.network:session()
	local peer = session and managers.menu:chat_target()
	if not peer then
		return
	end

	local ehc_mod = D:module("enhanced_chat")
	if ehc_mod and ehc_mod.send_direct_message then
		ehc_mod:send_direct_message(session:local_peer(), peer, message)
		return false -- eat message
	end
end, true)