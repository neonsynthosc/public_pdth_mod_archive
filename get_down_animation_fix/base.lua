return DMod:new("get_down_animation_fix", {
	name = "Get down animation fix",
	abbr = "GDF",
	version = "1.1",
	author = "Zdann",
	categories = { "bugfixes" },
	description = {
		english = "Fixes 'get down' animations not being randomized.",
	},
	update = {
		platform = "modworkshop",
		id = "36811",
	},
	hooks = {{
		"lib/units/beings/player/states/playerstandard", function(module)
			local PlayerStandard = module:hook_class("PlayerStandard")
			module:hook(PlayerStandard, "_play_distance_interact_redirect", function(self, t, variant)
				managers.network:session():send_to_peers("play_distance_interact_redirect", self._unit, variant)
				if self._in_steelsight then
					return
				end

				if self._shooting or not self._equipped_unit:base():start_shooting_allowed() then
					return
				end

				if self:_is_reloading() or self:_changing_weapon() or self._melee_expire_t or self._use_item_expire_t then
					return
				end

				if self._running then
					return
				end

				--Anim weight randomizing (it can be either 0 or 1)
				local anim_weight = math.random(0, 1)
				local state = self._unit:camera():play_redirect(Idstring(variant))

				--Applies the anim weight
				self._camera_unit:anim_state_machine():set_parameter(state, "var1", anim_weight)
			end, false)
		end
	}},
})
