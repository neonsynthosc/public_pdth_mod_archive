local PlayerStandard = module:hook_class("PlayerStandard")
module:post_hook(PlayerStandard, "init", function(self)
	local _tracker = rawget(_G, "_tracker")
	local _updator = rawget(_G, "_updator")
	if not _tracker or not _updator then
		return
	end

	_tracker:remove("player_pos")
	_tracker:remove("player_rot")
	_tracker:remove("player_fwd")
	_tracker:remove("player_lookat")
	_updator:remove("debug_player")

	_tracker:add("pos", "0, 0, 0", "player_pos")
	_tracker:add("rot", "0, 0, 0", "player_rot")
	_tracker:add("fwd", "0, 0, 0", "player_fwd")
	_tracker:add("lookat", "0, 0, 0", "player_lookat")

	_updator:add(function()
		local unit = self._unit
		if not alive(unit) then
			return
		end

		_tracker:update("player_pos", tostring(unit:position()))
		_tracker:update("player_rot", tostring(unit:camera():rotation()))
		_tracker:update("player_fwd", tostring(unit:camera():forward()))

		local ray_forward = function()
			local player = managers.player:player_unit()
			local from = player:camera():position()
			local to = Vector3()
			mvector3.set(to, player:camera():forward())
			mvector3.multiply(to, 20000)
			mvector3.add(to, from)

			local colRay = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("bullet_impact_targets"))
			return colRay and colRay.hit_position
		end

		local to = ray_forward()
		if not to then
			return
		end

		Application:draw_sphere(to, 5, 0, 1, 0)
		_tracker:update("player_lookat", tostring(to))
	end, "debug_player")
end)

-- module:hook(PlayerStandard, "_get_input", function(self, t, dt, paused)
-- 	local input = module:call_orig(PlayerStandard, "_get_input", self, t, dt, paused)
-- 	local data_shit = {
-- 		data = {
-- 			jump = true,
-- 		},
-- 		keys = {
-- 			jump = "btn_jump_press",
-- 		},
-- 	}

-- 	for btn, on in pairs(data_shit.data) do
-- 		local shit = data_shit.keys[btn]
-- 		if on and input[shit] == false then
-- 			input[shit] = self._controller:get_input_bool(btn)
-- 		end
-- 	end

-- 	return input
-- end)
