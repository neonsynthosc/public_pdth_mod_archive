local CopDamage = module:hook_class("CopDamage")

module:post_hook(50, CopDamage, "init", function(self)
	self:_create_debug_ws()
end)

module:post_hook(50, CopDamage, "_on_damage_received", function(self, damage_info)
	self:_update_debug_ws(damage_info)
end)

module:post_hook(50, CopDamage, "die", function(self, attack_data)
	self:_remove_debug_gui()
end)

module:post_hook(50, CopDamage, "destroy", function(self, attack_data)
	self:_remove_debug_gui()
end)

function CopDamage:_create_debug_ws()
	self._gui = World:newgui()
	local obj = self._unit:get_object(Idstring("Head"))
	self._ws = self._gui:create_linked_workspace(
		100,
		100,
		obj,
		obj:position() + obj:rotation():y() * 25,
		obj:rotation():x() * 50,
		obj:rotation():y() * 50
	)

	self._ws:set_billboard(self._ws.BILLBOARD_BOTH)
	self._ws:panel():text({
		name = "health",
		vertical = "center",
		visible = true,
		font_size = 30,
		align = "left",
		font = "fonts/font_univers_latin_530_bold",
		y = 0,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		text = "" .. self._health,
		color = Color.white,
	})
	self._ws:panel():text({
		name = "ld",
		vertical = "center",
		visible = true,
		font_size = 30,
		align = "left",
		text = "",
		font = "fonts/font_univers_latin_530_bold",
		y = 30,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		color = Color.white,
	})
	self._ws:panel():text({
		name = "variant",
		vertical = "center",
		visible = true,
		font_size = 30,
		align = "left",
		text = "",
		font = "fonts/font_univers_latin_530_bold",
		y = 60,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		color = Color.white,
	})
	self:_update_debug_ws()
end

function CopDamage:_update_debug_ws(damage_info)
	if alive(self._ws) then
		local str = string.format("HP: %.2f", self._health)

		self._ws:panel():child("health"):set_text(str)
		self._ws:panel():child("ld"):set_text(string.format("LD: %.2f", damage_info and damage_info.damage or 0))
		self._ws:panel():child("variant"):set_text("V: " .. (damage_info and damage_info.variant or "N/A"))

		local _, _, w, h = self._ws:panel():child("health"):text_rect()
		self._ws:panel():child("health"):set_w(w)
		self._ws:panel():child("health"):set_h(h)

		local _, _, w, h = self._ws:panel():child("ld"):text_rect()
		self._ws:panel():child("ld"):set_w(w)
		self._ws:panel():child("ld"):set_h(h)

		local _, _, w, h = self._ws:panel():child("variant"):text_rect()
		self._ws:panel():child("variant"):set_w(w)
		self._ws:panel():child("variant"):set_h(h)

		local vc = Color.white

		if damage_info and damage_info.variant then
			vc = damage_info.variant == "fire" and Color.red
				or damage_info.variant == "melee" and Color.yellow
				or Color.white
		end

		self._ws:panel():child("variant"):set_color(vc)

		-- Lines 4251-4266
		local function func(o)
			local mt = 0.25
			local t = mt

			while t >= 0 do
				local dt = coroutine.yield()
				t = math.clamp(t - dt, 0, mt)
				local v = t / mt
				local a = 1
				local r = 1
				local g = 0.25 + 0.75 * (1 - v)
				local b = 0.25 + 0.75 * (1 - v)

				o:set_color(Color(a, r, g, b))
			end
		end

		self._ws:panel():child("ld"):animate(func)

		if damage_info and damage_info.damage > 0 then
			local text = self._ws:panel():text({
				font_size = 20,
				vertical = "center",
				h = 40,
				visible = true,
				w = 40,
				align = "center",
				render_template = "OverlayVertexColorTextured",
				font = "fonts/font_medium_shadow_mf",
				y = -20,
				rotation = 360,
				layer = 1,
				text = string.format("%.2f", damage_info.damage),
				color = Color.white,
			})

			-- Lines 4272-4285
			local function func2(o, dir)
				local mt = 8
				local t = mt

				while t > 0 do
					local dt = coroutine.yield()
					t = math.clamp(t - dt, 0, mt)
					local speed = dt * 100

					o:move(dir * speed, (1 - math.abs(dir)) * -speed)
					text:set_alpha(t / mt)
				end

				self._ws:panel():remove(o)
			end

			local dir = math.sin(Application:time() * 1000)

			text:set_rotation(dir * 90)
			text:animate(func2, dir)
		end
	end
end

function CopDamage:_remove_debug_gui()
	if alive(self._gui) and alive(self._ws) then
		self._gui:destroy_workspace(self._ws)

		self._ws = nil
		self._gui = nil
	end
end
