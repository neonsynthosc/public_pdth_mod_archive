local module = ... or D:module("zneixs_fixes")
local MenuLobbyRenderer = module:hook_class("MenuLobbyRenderer")

-- XXX(zneix): Is complete replacement of these functions the way to go?

function MenuLobbyRenderer:set_slot_ready(peer, peer_id)
	local slot = self._player_slots[peer_id]
	if not slot then
		return
	end
	print("[MenuLobbyRenderer:set_slot_ready]")
	--slot.status:set_text(string.upper(managers.localization:text("menu_waiting_is_ready")))
	local text, colors = StringUtils:parse_color_string_utf8(managers.localization:to_upper_text("menu_waiting_is_ready"))
	--dlog(5, "MenuLobbyRenderer:set_slot_ready", text)
	--dump_table(colors)
	slot.status:set_text(text)
	if colors then
		for i = 1, #colors do
			local c = colors[i]
			slot.status:set_range_color(c.i - 1, c.j, c.color)
		end
	end
end

function MenuLobbyRenderer:set_slot_not_ready(peer, peer_id)
	local slot = self._player_slots[peer_id]
	if not slot then
		return
	end
	print("[MenuLobbyRenderer:set_slot_not_ready]")
	--slot.status:set_text(string.upper(managers.localization:text("menu_waiting_is_not_ready")))
	local text, colors = StringUtils:parse_color_string_utf8(managers.localization:to_upper_text("menu_waiting_is_not_ready"))
	--dlog(5, "MenuLobbyRenderer:set_slot_not_ready", text)
	--dump_table(colors)
	slot.status:set_text(text)
	if colors then
		for i = 1, #colors do
			local c = colors[i]
			slot.status:set_range_color(c.i - 1, c.j, c.color)
		end
	end
end

module:post_hook(50, MenuLobbyRenderer, "_set_player_slot", function(self, nr, params)
	local my_slot = params.peer_id == managers.network:session():local_peer():id()
	local slot = self._player_slots[nr]
	if params.status then
		local text, colors = StringUtils:parse_color_string_utf8(params.status)
		--dlog(5, "MenuLobbyRenderer:set_slot_not_ready", text)
		--dump_table(colors)
		slot.status:set_text(text)
		if colors then
			for i = 1, #colors do
				local c = colors[i]
				slot.status:set_range_color(c.i - 1, c.j, c.color)
			end
		end
	end
end, false)
