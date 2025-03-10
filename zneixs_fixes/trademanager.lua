local module = ... or D:module("zneixs_fixes")
local TradeManager = module:hook_class("TradeManager")

-- escape square brackets in s so that they aren't parsed as colours
-- TODO: move this to some util.lua file or somewhere else
local function clear_string(s)
	return (string.gsub(s, "%[", "%[%["))
end

-- override function responsible for showing hints upon helping other heisters to make it support colors
-- TODO: this is incomplete
module:hook(TradeManager, "sync_teammate_helped_hint", function(self, helped_unit, helping_unit, hint, priority)
	if not alive(helped_unit) or not alive(helping_unit) then
		return
	end

	-- hud module's code

	local t = TimerManager:game():time()
	self._revive_history = self._revive_history or {}

	-- priorities: revived unit = 3, local interaction = 2, reviving unit = 1
	if priority then
		local h = self._revive_history[helped_unit:key()]
		if h and h.hint == hint and h.priority >= priority and h.time >= t - 1 then
			-- hint already shown within the last second
			return
		end
	end

	self._revive_history[helped_unit:key()] = { time = t, hint = hint, priority = priority or 0 }
	-- instead of calling origin function, we shall just copy and paste the modified version of it below
	--module:call_orig(TradeManager, "sync_teammate_helped_hint", self, helped_unit, helping_unit, hint)

	-- orig, modified for colour support

	local peer_id = managers.network:session():local_peer():id()
	if not managers.network:game():member(peer_id) then
		debug_pause("[TradeManager:sync_teammate_helped_hint] Couldn't get local unit! ", peer_id)
	end
	local local_unit = managers.criminals:character_unit_by_name(managers.criminals:local_character_name())

	local teammate_id, helper_id = nil, nil -- used for determining colours

	local hint_id = "teammate"
	if local_unit == helped_unit then
		hint_id = "you_were"
		teammate_id = peer_id -- helped unit was the local player
	elseif local_unit == helping_unit then
		hint_id = "you"
		helper_id = peer_id -- unit which helped another teammate was the local player
	end
	if not hint or hint == 1 then
		hint_id = hint_id .. "_revived"
	elseif hint == 2 then
		hint_id = hint_id .. "_helpedup"
	elseif hint == 3 then
		hint_id = hint_id .. "_rescued"
	end

	--if hint_id then
		--managers.hint:show_hint(hint_id, nil, false, {
			--TEAMMATE = helped_unit:base():nick_name(),
			--HELPER = helping_unit:base():nick_name()
		--})
	--end

	if not hint_id then
		return
	end

	-- my own modification
	local hint_text = managers.localization:text(managers.hint:hint(hint_id).text_id, {
		--TEAMMATE = "[teammate_color]" .. helped_unit:base():nick_name() .. "[]",
		--HELPER = "[helper_color]" .. helping_unit:base():nick_name() .. "[]",
		TEAMMATE = clear_string(helped_unit:base():nick_name()),
		HELPER = clear_string(helping_unit:base():nick_name()),
	})
	local hint_colors = nil

	-- zneix: can this hook_class call be moved to the top?
	--local NetworkGame = module:hook_class("NetworkGame")

	--if D:conf("zfx_color_names_in_hints") and NetworkGame ~= nil then
	if D:conf("zfx_color_names_in_hints") then
		module:log(5, "TradeManager:sync_teammate_helped_hint", "using colorful names in hint " .. hint_id)

		if teammate_id == nil then
			local teammate_member = managers.network:game():member_from_unit(helped_unit)
			if not teammate_member then
				teammate_id = 0 -- that means it's most likely team AI
			else
				teammate_id = teammate_member:peer():id()
			end
		end

		if helper_id == nil then
			local helper_member = managers.network:game():member_from_unit(helping_unit)
			if not helper_member then
				helper_id = 0 -- that means it's most likely team AI
			else
				helper_id = helper_member:peer():id()
			end
		end

		module:log(5, "TradeManager:sync_teammate_helped_hint", "teammate?", teammate_id)
		module:log(5, "TradeManager:sync_teammate_helped_hint", "helper?", helper_id)

		-- TODO: Handle "zfx_team_ai_name_color_in_hints"
		hint_text, hint_colors = StringUtils:parse_color_string_utf8(hint_text, {
			teammate_color = teammate_id and tweak_data.chat_colors[teammate_id] or D:conf("zfx_team_ai_name_color_in_hints"),
			helper_color = helper_id and tweak_data.chat_colors[helper_id] or D:conf("zfx_team_ai_name_color_in_hints"),
		})

	--else
		---- original code
		--managers.hint:show_hint(hint_id, nil, false, {
			--TEAMMATE = helped_unit:base():nick_name(),
			--HELPER = helping_unit:base():nick_name(),
		--})
	end

	module:log(5, "TradeManager:sync_teammate_helped_hint", "what's the hint?")
	dump_table(hint)
	managers.hud:show_hint({
		--text = managers.localization:text(hint.text_id, params),
		text = hint_text,
		colors = hint_colors,
		priority = priority or 0,
		id = hint_id,
		--event = hint.event,
		--time = time,
	})
end)
