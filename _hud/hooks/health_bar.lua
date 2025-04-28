local convert_panel_data = function(data)
	if type(data) == "string" then
		data = { child = data, offset = 0 }
	end

	if not data.child then
		data.child = data[1]
		data[1] = nil
	end

	if not data.offset then
		data.offset = 0
	end

	return data
end

local PlayerHealthPanel = class()
function PlayerHealthPanel:init(super)
	self.super = super

	self._xp_hud = self.super:script(Idstring("guis/experience_hud"))
	self._hud = self.super:script(PlayerBase.PLAYER_INFO_HUD)
	self._panel = self._hud.panel:panel({ layer = -100 })

	self.font = "fonts/font_univers_530_bold"
	self.colors = {
		black = Color.black,
		name = D:conf("_hud_name_color"),
		vanilla_health = D:conf("_hud_vanilla_health_color"),
		health = D:conf("_hud_health_color"),
		hurt = D:conf("_hud_hurt_color"),
		patch = D:conf("_hud_patch_color"),
		vanilla_armor = D:conf("_hud_vanilla_armor_color"),
		armor = D:conf("_hud_armor_color"),
	}

	self.data = {
		is_open = true,
		peer = managers.network:session():local_peer(),
		current_health = 0,
		current_armor = 0,
	}
	self._cached_conf_vars = {}

	self._toolbox = _M._hudToolBox
	self._updater = _M._hudUpdater

	self:update_settings()
	self:setup_panels()

	self._initialized = true
	self:layout()
	self:update_panel_visibility()

	self._updater:remove("health_bar_update")
	self._updater:add(callback(self, self, "update"), "health_bar_update")
end

function PlayerHealthPanel:update_settings()
	local D = D
	local var_cache = self._cached_conf_vars
	local refresh_required

	if type(var_cache.use_bcl) ~= "boolean" then
		local bcl = D:module("better_chat_location")
		var_cache.use_bcl = bcl and bcl:enabled() or false
	end

	local use_health_panel = D:conf("_hud_use_custom_health_panel")
	if var_cache.use_health_panel ~= use_health_panel then
		var_cache.use_health_panel = use_health_panel
		self._panel:set_visible(use_health_panel)

		if not use_health_panel then
			managers.hud:_layout_mugshots()
			managers.hud:_layout_chat_output()

			for _, mugshot in ipairs(managers.hud._hud.mugshots or {}) do
				-- DorentuZ` direct_messaging marker
				if alive(mugshot.selection_marker) then
					local w = mugshot.selection_marker:w()
					local panel_x, panel_y, _, panel_h = mugshot.panel:shape()
					mugshot.selection_marker:set_shape(panel_x, panel_y, w, panel_h)
					mugshot.panel:set_x(panel_x + w)
				end
			end

			local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
			if not full_hud then
				return
			end

			local say_text = full_hud.panel:child("say_text")
			local input_panel = full_hud.panel:child("chat_input")
			local text_scroll = full_hud.panel:child("textscroll")

			input_panel:set_top((var_cache.use_bcl and text_scroll:bottom() + 4) or 4)
			say_text:set_center_y(input_panel:center_y())

			managers.hud:update_hud_settings()
		end

		managers.hud:update_hud_visibility()
	end

	var_cache.reposition_chat_input = var_cache.use_bcl or D:conf("_hud_reposition_chat_input")

	local use_inventory = D:conf("_hud_use_custom_health_panel") and D:conf("_hud_use_custom_inventory_panel")
	if var_cache.use_inventory ~= use_inventory then
		var_cache.use_inventory = use_inventory

		refresh_required = true
	end

	local hud_scale = D:conf("_hud_scaling")
	local font_scale = D:conf("_hud_font_scaling")
	if var_cache.hud_scale ~= hud_scale or var_cache.font_scale ~= font_scale then
		var_cache.hud_scale = hud_scale
		var_cache.font_scale = font_scale
		self.scales = {
			hud = var_cache.hud_scale,
			font = var_cache.hud_scale,
			panel = var_cache.hud_scale * var_cache.font_scale * 0.75,
		}
		self:update_scaling()

		refresh_required = true
	end

	local selected_layout = D:conf("_hud_custom_health_panel_layout")
	if var_cache.selected_layout ~= selected_layout then
		var_cache.selected_layout = selected_layout

		refresh_required = true
	end

	local display_hp_ap = D:conf("_hud_display_armor_and_health_values")
	if var_cache.display_hp_ap ~= display_hp_ap then
		var_cache.display_hp_ap = display_hp_ap
		refresh_required = true
	end

	local display_armor_regen_timer = D:conf("_hud_display_armor_regen_timer")
	if var_cache.display_armor_regen_timer ~= display_armor_regen_timer then
		var_cache.display_armor_regen_timer = display_armor_regen_timer
		refresh_required = true
	end

	local use_vrep = D:conf("hud_prefer_virtual_reps")
	if var_cache.use_vrep ~= use_vrep then
		var_cache.use_vrep = use_vrep
		refresh_required = true
	end

	local mugshot_name = D:conf("_hud_mugshot_name")
	if var_cache.mugshot_name ~= mugshot_name then
		var_cache.mugshot_name = mugshot_name
		refresh_required = true
	end

	local custom_username = D:conf("_hud_custom_mugshot_name")
	if var_cache.custom_username ~= custom_username then
		var_cache.custom_username = custom_username
		refresh_required = true
	end

	local upper_name = D:conf("_hud_display_name_in_upper_cases")
	if var_cache.upper_name ~= upper_name then
		var_cache.upper_name = upper_name
		refresh_required = true
	end

	var_cache.name_use_peer_color = D:conf("_hud_name_use_peer_color")

	if refresh_required then
		self:layout()
		self:update_panel_visibility()
		self.data.current_health = 0
		self.data.current_armor = 0
	end
end

function PlayerHealthPanel:setup_panels()
	self.main_panel = self._panel:panel({ y = 100 })
	self:create_background()

	self.info_panels = {}
	self:create_mugshot()
	self:create_player_data()
	self:create_health_and_armor()
end

function PlayerHealthPanel:create_background()
	self.main_panel:gradient({
		name = "panel_background",
		gradient_points = { 0, Color(0.4, 0, 0, 0), 1, Color(0, 0, 0, 0) },
		layer = -1,
	})
end

function PlayerHealthPanel:create_mugshot()
	local mugshot_ids = {
		["american"] = 1,
		["german"] = 2,
		["russian"] = 3,
		["spanish"] = 4,
	}

	local mask_id = mugshot_ids[managers.criminals:local_character_name()]
	local mask_icon = tablex.get(tweak_data.mask_sets, self.data.peer:mask_set(), mask_id, "mask_icon")
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(mask_icon or "mugshot_random")

	self.info_panels.mugshot = self.main_panel:bitmap({
		name = "player_mugshot",
		texture = icon,
		texture_rect = texture_rect,
		layer = 1,
		x = 0,
		y = 0,
		w = texture_rect[3] * self.scales.panel,
		h = texture_rect[4] * self.scales.panel,
	})

	self.data.mugshot_rect = deep_clone(texture_rect)

	icon, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_in_custody")
	self.info_panels.mugshot_status = self.main_panel:bitmap({
		texture = icon,
		texture_rect = texture_rect,
		alpha = 0,
		layer = 3,
		w = texture_rect[3] * self.scales.panel,
		h = texture_rect[4] * self.scales.panel,
	})

	self.data.mugshot_status_rect = deep_clone(texture_rect)
end

function PlayerHealthPanel:create_player_data()
	self.info_panels.player_name = self.main_panel:text({
		name = "player_name",
		text = "simon andersson",
		font = self.font,
		font_size = 14 * self.scales.hud * self.scales.font,
		layer = 1,
	})

	self.info_panels.player_level = self.main_panel:text({
		name = "player_level",
		text = "0",
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		layer = 1,
	})

	self.info_panels.player_downs = self.main_panel:text({
		name = "player_downs",
		text = "0",
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		layer = 2,
	})

	self.info_panels.respawn_delay = self.main_panel:text({
		name = "respawn_delay",
		text = "00",
		font = self.font,
		font_size = 20 * self.scales.hud * self.scales.font,
		layer = 4,
		visible = false,
	})

	self.info_panels.base_text = self.main_panel:text({
		name = "base_text",
		text = "100",
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		layer = 1,
		visible = false,
	})

	self.info_panels.health_points = self.main_panel:text({
		name = "health_points",
		text = "0",
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		color = self.colors.patch,
		layer = 1,
	})

	self.info_panels.armor_points = self.main_panel:text({
		name = "armor_points",
		text = "0",
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		color = self.colors.armor,
		layer = 1,
	})

	self.info_panels.armor_timer = self.main_panel:text({
		name = "armor_timer",
		text = "0.00s",
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		color = self.colors.armor,
		layer = 1,
	})

	self._toolbox:make_pretty_text(self.info_panels.player_name)
	self._toolbox:make_pretty_text(self.info_panels.player_level)
	self._toolbox:make_pretty_text(self.info_panels.player_downs)
	self._toolbox:make_pretty_text(self.info_panels.respawn_delay)
	self._toolbox:make_pretty_text(self.info_panels.base_text)
	self._toolbox:make_pretty_text(self.info_panels.health_points)
	self._toolbox:make_pretty_text(self.info_panels.armor_points)
	self._toolbox:make_pretty_text(self.info_panels.armor_timer)
end

function PlayerHealthPanel:create_health_and_armor()
	local health_bar_icon, health_bar_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_health")
	local health_bg_icon, health_bg_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_background")
	local armor_bar_icon, armor_bar_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_armor")

	self.data.armor_bar_rect = armor_bar_rect

	self.armor_health_panels = {
		vanilla = {
			health = {
				bar = self.main_panel:bitmap({
					name = "_hud_vanilla_health_bar",
					texture = health_bar_icon,
					layer = 2,
					texture_rect = health_bar_rect,
					color = Color.green,
					w = health_bar_rect[3],
					h = self.main_panel:child("player_mugshot"):h(),
				}),
				background = self.main_panel:bitmap({
					name = "_hud_vanilla_health_bg",
					texture = health_bg_icon,
					layer = 1,
					texture_rect = health_bg_rect,
					w = health_bg_rect[3],
					h = self.main_panel:child("player_mugshot"):h(),
				}),
			},
			armor = {
				bar = self.main_panel:bitmap({
					name = "_hud_vanilla_armor_bar",
					texture = armor_bar_icon,
					layer = 3,
					texture_rect = armor_bar_rect,
					w = armor_bar_rect[3],
					h = self.main_panel:child("player_mugshot"):h(),
				}),
			},
		},
		raid = {
			health = {
				bar = self.main_panel:rect({ name = "_hud_raid_health_bar", layer = 2, h = 8, w = 0 }),
				background = self.main_panel:rect({
					name = "_hud_raid_health_bg",
					color = self.colors.black,
					layer = 1,
					h = 8,
				}),
			},
			armor = {
				bar = self.main_panel:rect({
					name = "_hud_raid_armor_bar",
					color = self.colors.armor,
					layer = 3,
					h = 2,
					w = 0,
				}),
			},
		},
		raid_alt = {
			health = {
				bar = self.main_panel:rect({ name = "_hud_raid_alt_health_bar", layer = 2, h = 8, w = 0 }),
				background = self.main_panel:rect({
					name = "_hud_raid_alt_health_bg",
					color = self.colors.black,
					layer = 1,
					h = 8,
				}),
			},
			armor = {
				bar = self.main_panel:rect({
					name = "_hud_raid_alt_armor_bar",
					color = self.colors.armor,
					layer = 3,
					h = 8,
					w = 0,
				}),
				background = self.main_panel:rect({
					name = "_hud_raid_alt_armor_bg",
					color = self.colors.black,
					layer = 1,
					h = 8,
				}),
			},
		},
	}
end

function PlayerHealthPanel:update_panel_visibility()
	if not self._initialized then
		return
	end

	self.info_panels.player_name:set_visible(self:is_panel_open())
	self.info_panels.player_level:set_visible(self:is_panel_open())
	self.info_panels.player_downs:set_visible(self:is_panel_open())
	self.info_panels.respawn_delay:set_visible(not self:is_panel_open())

	local var_cache = self._cached_conf_vars
	self.info_panels.health_points:set_visible(
		var_cache.display_hp_ap and (var_cache.selected_layout == "vanilla" or self:is_panel_open())
	)
	self.info_panels.armor_points:set_visible(
		var_cache.display_hp_ap and (var_cache.selected_layout == "vanilla" or self:is_panel_open())
	)
	self.info_panels.armor_timer:set_visible(var_cache.selected_layout ~= "vanilla" and self:is_panel_open())

	for layout, layout_data in pairs(self.armor_health_panels) do
		for category, panels in pairs(layout_data) do
			for _, panel in pairs(panels) do
				local visible = var_cache.selected_layout == layout
				visible = visible and ((category == "health" and layout == "vanilla") or self:is_panel_open())

				panel:set_visible(visible)
			end
		end
	end
end

function PlayerHealthPanel:get_layout()
	local var_cache = self._cached_conf_vars

	return {
		vanilla = {
			{
				name = "base_text",
				data = {
					y = { child = "panel_background", offset = 4 },
					x = { child = "panel_background", offset = 4 },
				},
			},
			{
				name = "health_points",
				data = {
					y = { child = "panel_background", offset = 4 },
					x = { child = "base_text" },
				},
			},
			{
				name = "health",
				data = {
					bar = { x = "_hud_vanilla_health_bg", bottom_y = "_hud_vanilla_health_bg" },
					background = {
						y = { child = "health_points" },
						left = var_cache.display_hp_ap and { child = "base_text", offset = 4 },
						x = not var_cache.display_hp_ap and { child = "panel_background", offset = 4 },
					},
				},
			},
			{
				name = "armor",
				data = {
					bar = { x = "_hud_vanilla_health_bg", bottom_y = "_hud_vanilla_health_bg" },
				},
			},
			{
				name = "armor_points",
				data = {
					bottom_y = { child = "_hud_vanilla_health_bg", offset = 4 },
					x = { child = "health_points" },
				},
			},
			{
				name = "mugshot",
				data = {
					world_left = { child = "_hud_vanilla_health_bg", offset = 4 },
					y = { child = "_hud_vanilla_health_bg", offset = 0 },
				},
			},
			{
				name = "mugshot_status",
				data = { center = "player_mugshot" },
			},
			{
				name = "respawn_delay",
				data = { center = "player_mugshot" },
			},
			{
				name = "player_downs",
				data = {
					y = "player_mugshot",
					right_x = { child = "player_mugshot", offset = -2 },
				},
			},
			{
				name = "player_name",
				data = {
					y = "player_mugshot",
					left = { child = "player_mugshot", offset = 4 },
				},
			},
			{
				name = "player_level",
				data = {
					center_y = "player_name",
					left = { child = "player_name", offset = 4 },
				},
			},
		},
		raid = {
			{
				name = "mugshot",
				data = {
					x = { child = "panel_background", offset = 4 },
					y = { child = "panel_background", offset = 4 },
				},
			},
			{
				name = "mugshot_status",
				data = { center = "player_mugshot" },
			},
			{
				name = "respawn_delay",
				data = { center = "player_mugshot" },
			},
			{
				name = "player_downs",
				data = {
					y = "player_mugshot",
					right_x = { child = "player_mugshot", offset = -2 },
				},
			},
			{
				name = "player_name",
				data = {
					y = "player_mugshot",
					left = { child = "player_mugshot", offset = 4 },
				},
			},
			{
				name = "player_level",
				data = {
					y = "player_name",
					right_x = { child = "panel_background", offset = -4 },
				},
			},
			{
				name = "health_points",
				data = {
					top = { child = "player_name", offset = -4 },
					left = { child = "player_mugshot", offset = 4 },
				},
			},
			{
				name = "armor_points",
				data = {
					top = { child = "player_name", offset = -4 },
					right_x = { child = "panel_background", offset = -4 },
				},
			},
			{
				name = "health",
				data = {
					bar = { left_x = "_hud_raid_health_bg", y = "_hud_raid_health_bg" },
					background = {
						top = { child = var_cache.display_hp_ap and "health_points" or "player_name", offset = -4 },
						left_x = { child = "health_points", offset = -2 },
					},
				},
			},
			{
				name = "armor",
				data = {
					bar = { x = "_hud_raid_health_bg", bottom_y = "_hud_raid_health_bg" },
				},
			},
			{
				name = "armor_timer",
				data = {
					left_x = { child = "_hud_raid_health_bg" },
					top = "_hud_raid_health_bg",
				},
			},
		},
		raid_alt = {
			{
				name = "mugshot",
				data = {
					x = { child = "panel_background", offset = 4 },
					y = { child = "panel_background", offset = 4 },
				},
			},
			{
				name = "mugshot_status",
				data = { center = "player_mugshot" },
			},
			{
				name = "respawn_delay",
				data = { center = "player_mugshot" },
			},
			{
				name = "player_downs",
				data = {
					y = "player_mugshot",
					right_x = { child = "player_mugshot", offset = -2 },
				},
			},
			{
				name = "player_name",
				data = {
					y = "player_mugshot",
					left = { child = "player_mugshot", offset = 4 },
				},
			},
			{
				name = "player_level",
				data = {
					y = "player_name",
					right_x = { child = "panel_background", offset = -4 },
				},
			},
			{
				name = "base_text",
				data = {
					right_x = { child = "panel_background", offset = -4 },
				},
			},
			{
				name = "health",
				data = {
					bar = { left_x = "_hud_raid_alt_health_bg", y = "_hud_raid_alt_health_bg" },
					background = {
						top = { child = "player_name", offset = -4 },
						left_x = { child = "player_name", offset = -2 },
					},
				},
			},
			{
				name = "health_points",
				data = {
					center_y = { child = "_hud_raid_alt_health_bg" },
					left_x = "base_text",
				},
			},
			{
				name = "armor",
				data = {
					bar = { x = "_hud_raid_alt_armor_bg", bottom_y = "_hud_raid_alt_armor_bg" },
					background = {
						top = { child = "_hud_raid_alt_health_bg", offset = 4 },
						left_x = { child = "player_name", offset = -2 },
					},
				},
			},
			{
				name = "armor_points",
				data = {
					center_y = "_hud_raid_alt_armor_bg",
					left_x = "base_text",
				},
			},
			{
				name = "armor_timer",
				data = {
					left_x = { child = "_hud_raid_alt_health_bg" },
					top = "_hud_raid_alt_armor_bg",
				},
			},
		},
	}
end

function PlayerHealthPanel:layout_panel(panel, data)
	local position_translation = {
		bottom_y = "bottom",
		right_x = "right",
		left_x = "left",
	}
	local target_position_translation = {
		top = "bottom",
		bottom = "top",
		left = "right",
		right = "left",
		bottom_y = "bottom",
		right_x = "right",
		left_x = "left",
		world_left = "world_right",
		world_right = "world_left",
	}

	for _, position in pairs({
		"x",
		"y",
		"top",
		"bottom",
		"left",
		"right",
		"bottom_y",
		"center_y",
		"right_x",
		"left_x",
		"world_x",
		"world_y",
		"world_left",
		"world_right",
		"center",
	}) do
		if data[position] then
			local position_data = convert_panel_data(data[position])
			local child = self.main_panel:child(position_data.child)
			if alive(child) then
				local target_pos = target_position_translation[position] or position
				position = position_translation[position] or position

				if panel.font then
					self._toolbox:make_pretty_text(panel)
				end

				if position == "center" then
					panel:set_center(child:center())
				else
					panel["set_" .. position](panel, child[target_pos](child) + position_data.offset)
				end
			end
		end
	end
end

function PlayerHealthPanel:layout()
	if not self._initialized then
		return
	end

	self:update_player_data()

	self.data.workspace_width = self.info_panels.mugshot:w() + 8 + (176 * self.scales.panel)

	self.main_panel:set_h(self.info_panels.mugshot:h() + 8)
	self.main_panel:child("panel_background"):set_size(self.main_panel:size())

	local target_bottom = self._panel:bottom()
	if self._xp_hud then
		target_bottom = self.super._xp_hud_hidden and self._panel:bottom() or self._xp_hud.experience_panel:top() - 10
	end

	local var_cache = self._cached_conf_vars
	if var_cache.use_inventory then
		local inventory_panel = self.super._hud.custom_inventory_panel
		if inventory_panel and alive(inventory_panel.main_panel) then
			if var_cache.selected_layout ~= "vanilla" or inventory_panel.rows > 1 then
				target_bottom = target_bottom - inventory_panel.main_panel:h()
			end
		end
	end

	self.main_panel:set_world_bottom(target_bottom)
	self.main_panel:set_left(self._panel:left())

	for _, category in ipairs(self:get_layout()[var_cache.selected_layout]) do
		local info_panel = tablex.get(self.info_panels, category.name)
		if alive(info_panel) then
			self:layout_panel(info_panel, category.data)
		else
			for p, data in pairs(category.data) do
				local panel = tablex.get(self.armor_health_panels, var_cache.selected_layout, category.name, p)
				if panel and alive(panel) then
					self:layout_panel(panel, data)
				end
			end
		end
	end

	if var_cache.selected_layout == "vanilla" then
		self.armor_health_panels.vanilla.health.background:set_h(self.info_panels.mugshot:h())
		return
	end

	local container = self.armor_health_panels
	container.raid.health.background:set_w(self.data.workspace_width - self.info_panels.mugshot:w() - 12)

	container.raid_alt.health.background:set_w(
		self.data.workspace_width
			- self.info_panels.mugshot:w()
			- (var_cache.display_hp_ap and self.info_panels.base_text:w() or 0)
			- 12
	)
	container.raid_alt.armor.background:set_w(container.raid_alt.health.background:w())
end

function PlayerHealthPanel:layout_team_mugshots()
	if not managers.hud or not self._hud then
		return
	end

	local mugshots = managers.hud._hud.mugshots
	for i, mugshot in ipairs(mugshots) do
		local panel = mugshot.panel

		local y = ((i == 1) and (self.main_panel:world_y() - 4))
			or i == 2 and mugshots[1].panel:top() - 2 * tweak_data.scale.hud_health_multiplier
			or i == 3 and mugshots[2].panel:top() - 2 * tweak_data.scale.hud_health_multiplier

		panel:set_bottom(y)
		panel:set_left(self._panel:left())
		panel:set_visible(panel:parent():visible())
		panel:set_layer(-1150)

		-- DorentuZ` direct_messaging marker
		if alive(mugshot.selection_marker) then
			local w = mugshot.selection_marker:w()
			local panel_x, panel_y, _, panel_h = mugshot.panel:shape()
			mugshot.selection_marker:set_shape(panel_x, panel_y, w, panel_h)
			mugshot.panel:set_x(panel_x + w)
		end
	end
end

function PlayerHealthPanel:layout_vanilla_chat()
	if not managers.hud then
		return
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	if not hud or not full_hud then
		return
	end

	local hud_m = managers.hud
	local mugshots = hud_m._hud.mugshots

	if not next(mugshots) then
		return
	end

	local target_y = (
		((full_hud:chat_output_state() == "default") and mugshots[#mugshots].panel:top()) or hud.health_panel:bottom()
	) - 4

	local say_text = full_hud.panel:child("say_text")
	local input_panel = full_hud.panel:child("chat_input")

	if not self._cached_conf_vars.reposition_chat_input then
		input_panel:set_top(4)
		say_text:set_center_y(input_panel:center_y())

		full_hud.panel:child("textscroll"):set_bottom(target_y)
		return
	end

	input_panel:set_bottom(target_y + (hud_m._saferect_size.y * hud_m._workspace_size.h))
	say_text:set_center_y(input_panel:center_y())
	full_hud.panel:child("textscroll"):set_bottom(input_panel:top() - 4)
end

function PlayerHealthPanel:get_player_name()
	local var_cache = self._cached_conf_vars
	if var_cache.mugshot_name == "user_defined" then
		return not string.empty(var_cache.custom_username) and var_cache.custom_username or "<name>"
	end

	if var_cache.mugshot_name == "character_name" then
		local character_name = managers.criminals:local_character_name() or "russian"
		return managers.localization:text("debug_" .. character_name)
	end

	local name = self.data.peer:name()
	if var_cache.mugshot_name == "short_username" and utf8.len(name) > 16 then
		name = self._toolbox:get_longest_word(name)
	end

	return name
end

function PlayerHealthPanel:get_name_color()
	if self._cached_conf_vars.name_use_peer_color then
		return tweak_data.chat_colors[self.data.peer:id()]
	end

	return self.colors.name
end

function PlayerHealthPanel:update_scaling()
	if not self._initialized then
		return
	end

	self.info_panels.mugshot:set_w(self.data.mugshot_rect[3] * self.scales.panel)
	self.info_panels.mugshot:set_h(self.data.mugshot_rect[4] * self.scales.panel)

	self.info_panels.mugshot_status:set_w(self.data.mugshot_status_rect[3] * self.scales.panel)
	self.info_panels.mugshot_status:set_h(self.data.mugshot_status_rect[4] * self.scales.panel)

	self.info_panels.player_downs:set_font_size(11 * self.scales.hud * self.scales.font)
	self.info_panels.player_name:set_font_size(14 * self.scales.hud * self.scales.font)
	self.info_panels.player_level:set_font_size(11 * self.scales.hud * self.scales.font)
	self.info_panels.base_text:set_font_size(11 * self.scales.hud * self.scales.font)
	self.info_panels.health_points:set_font_size(11 * self.scales.hud * self.scales.font)
	self.info_panels.armor_points:set_font_size(11 * self.scales.hud * self.scales.font)
end

function PlayerHealthPanel:update_player_data()
	local character_name = managers.criminals:local_character_name()
	if self.info_panels.mugshot:texture_name():key() == "7e3fa6faeeaf4dd0" then
		local mugshot_ids = {
			["american"] = 1,
			["german"] = 2,
			["russian"] = 3,
			["spanish"] = 4,
		}
		local mask_id = mugshot_ids[character_name]
		local mask_set = tweak_data.mask_sets[self.data.peer:mask_set()][mask_id]
		local icon_id = tablex.get(mask_set, "mask_icon") or "mugshot_random"
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon_id)
		self.info_panels.mugshot:set_image(texture, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])
	end

	local player_level_func = self._cached_conf_vars.use_vrep and "current_virtual_level" or "current_level"
	local player_level = managers.experience[player_level_func](managers.experience, true)

	local name = self:get_player_name()
	if self._cached_conf_vars.upper_name then
		name = utf8.to_upper(name)
	end

	self.info_panels.player_name:set_text(name)
	self.info_panels.player_name:set_color(self:get_name_color())
	local var_cache = self._cached_conf_vars
	self.info_panels.player_level:set_text(
		string.format((var_cache.selected_layout == "vanilla" and "[%d]" or "%d"), player_level)
	)
	self.info_panels.player_level:set_font_size(
		(var_cache.selected_layout == "vanilla" and 14 or 11) * self.scales.hud * self.scales.font
	)

	self.info_panels.respawn_delay:set_text(string.format("%02d", managers.trade:respawn_delay_by_name(character_name)))

	self._toolbox:make_pretty_text(self.info_panels.player_level)
	self._toolbox:make_pretty_text(self.info_panels.player_downs)

	self._toolbox:make_pretty_text(self.info_panels.respawn_delay)
	self.info_panels.respawn_delay:set_center(self.info_panels.mugshot:center()) -- temp fix
end

function PlayerHealthPanel:update_health_and_armor()
	local p_unit = managers.player:player_unit()
	if not alive(p_unit) then
		return
	end

	local var_cache = self._cached_conf_vars

	local p_damage = p_unit:character_damage()

	local current_health = math.ceil((p_damage._health or 0) * 10)
	local max_health = math.ceil((p_damage:_max_health() or 0) * 10)
	local health_percentage = math.clamp(current_health / max_health, 0, 1)

	local current_armor = math.ceil((p_damage._armor or 0) * 10)
	local max_armor = math.ceil((p_damage:_max_armor() or 0) * 10)
	local armor_percentage = math.clamp(current_armor / max_armor, 0, 1)

	if self.data.current_health ~= current_health then
		local lower = self.data.current_health > current_health

		local container = self.armor_health_panels[var_cache.selected_layout].health
		local health_color_key = var_cache.selected_layout == "vanilla" and "vanilla_health" or "health"
		container.bar:stop()
		container.bar:animate(function(o)
			self._toolbox:animate_ui(1, function(p)
				if var_cache.selected_layout ~= "vanilla" then
					o:set_w(math.lerp(o:w(), container.background:w() * health_percentage, p))
				else
					o:set_h(math.lerp(o:h(), container.background:h() * health_percentage, p))
					o:set_bottom(container.background:bottom())
				end

				local health_color = ((health_percentage > 0.33) and self.colors[health_color_key]) or self.colors.hurt
				local damage_color = lower and self.colors.hurt or self.colors.patch
				o:set_color(self._toolbox:blend_colors(health_color, damage_color, p))
			end)

			if var_cache.selected_layout ~= "vanilla" then
				o:set_w(container.background:w() * health_percentage)
			else
				o:set_h(container.background:h() * health_percentage)
				o:set_bottom(container.background:bottom())
			end
		end)

		self.data.current_health = current_health
	end

	if self.data.current_armor ~= current_armor then
		local layout = self.armor_health_panels[var_cache.selected_layout]
		local armor_container = layout.armor
		local health_container = armor_container.background and armor_container or layout.health
		local armor_color_key = var_cache.selected_layout == "vanilla" and "vanilla_armor" or "armor"
		armor_container.bar:set_color(self.colors[armor_color_key])

		armor_container.bar:animate(function(o)
			self._toolbox:animate_ui(0.2, function(p)
				if var_cache.selected_layout ~= "vanilla" then
					o:set_w(math.lerp(o:w(), health_container.background:w() * armor_percentage, p))
				else
					local x = self.data.armor_bar_rect[1]
					local y = self.data.armor_bar_rect[2]
					local h = health_container.background:h()
					local y_offset = self.data.armor_bar_rect[4] * (1 - armor_percentage)
					local h_offset = h * (1 - armor_percentage)
					o:set_texture_rect(
						x,
						y + y_offset,
						self.data.armor_bar_rect[3],
						self.data.armor_bar_rect[4] - y_offset
					)

					o:set_h(math.lerp(o:h(), h - h_offset, p))
					o:set_bottom(health_container.background:bottom())
				end
			end)

			if var_cache.selected_layout ~= "vanilla" then
				o:set_w(health_container.background:w() * armor_percentage)
			else
				local x = self.data.armor_bar_rect[1]
				local y = self.data.armor_bar_rect[2]
				local h = health_container.background:h()
				local y_offset = self.data.armor_bar_rect[4] * (1 - armor_percentage)
				local h_offset = h * (1 - armor_percentage)
				o:set_texture_rect(x, y + y_offset, self.data.armor_bar_rect[3], self.data.armor_bar_rect[4] - y_offset)
				o:set_h(h - h_offset)
				o:set_bottom(health_container.background:bottom())
			end
		end)

		self.data.current_armor = current_armor
	end

	-- we use dahm's down counter instead of implementing a custom one.
	self.info_panels.player_downs:set_text(managers.hud._hud_health_downs:text())

	self.info_panels.health_points:set_text(string.format("%.0f", p_damage._health * 10 or 0))
	self._toolbox:make_pretty_text(self.info_panels.health_points)

	self.info_panels.armor_points:set_text(string.format("%.0f", p_damage._armor * 10 or 0))
	self._toolbox:make_pretty_text(self.info_panels.armor_points)

	local regen_timer = p_damage._regenerate_timer
	if regen_timer then
		self.info_panels.armor_timer:set_text(string.format("%.2fs", regen_timer))
		self._toolbox:make_pretty_text(self.info_panels.armor_timer)
	end

	self.info_panels.armor_timer:set_visible(
		(type(regen_timer) == "number")
			and (var_cache.selected_layout ~= "vanilla")
			and var_cache.display_armor_regen_timer
	)
end

function PlayerHealthPanel:is_panel_open()
	return self.data.is_open
end

function PlayerHealthPanel:close_panel()
	self.data.is_open = false

	self:update_panel_visibility()

	self.main_panel:stop()
	self.main_panel:animate(function(o)
		self._toolbox:animate_ui(2, function(p)
			o:set_w(math.lerp(o:w(), self.info_panels.mugshot:w() + self.info_panels.mugshot:x() + 4, p))
		end)

		o:set_w(self.info_panels.mugshot:w() + self.info_panels.mugshot:x() + 4)
	end)
end

function PlayerHealthPanel:open_panel()
	self.data.is_open = true

	self:update_panel_visibility()

	self.main_panel:stop()
	self.main_panel:animate(function(o)
		self._toolbox:animate_ui(1, function(p)
			o:set_w(math.lerp(o:w(), self.data.workspace_width, p))
		end)

		self.data.current_health = 0
		self.data.current_armor = 0

		o:set_w(self.data.workspace_width)
	end)
end

function PlayerHealthPanel:anim_take_damage()
	if not self._panel:visible() or not alive(self.main_panel) then
		return
	end

	self.main_panel:child("panel_background"):animate(self._hud.mugshot_damage_taken)
end

function PlayerHealthPanel:update_mugshot()
	if
		self.main_panel:w() > self.data.workspace_width
		or self:is_panel_open() and self.main_panel:w() < self.data.workspace_width
	then
		self.main_panel:stop()
		self.main_panel:set_w(self.data.workspace_width)
		self:layout()
		self.data.current_health = 0
		self.data.current_armor = 0
	end

	local states = {
		bleed_out = "mugshot_downed",
		incapacitated = "mugshot_downed",
		fatal = "mugshot_downed",
		tased = "mugshot_electrified",
		arrested = "mugshot_cuffed",
		custody = "mugshot_in_custody",
	}

	local state
	local current_state = managers.player:current_state()
	if not alive(managers.player:player_unit()) then
		state = "custody"
	end

	local state_icon = states[state or current_state] or nil
	if self.data.current_state and self.data.current_state == state_icon then
		return
	end

	self.data.current_state = state_icon
	if state and self:is_panel_open() then
		self:close_panel()
	end

	if not state and not self:is_panel_open() then
		self:open_panel()
	end

	if state_icon then
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(state_icon)
		self.info_panels.mugshot_status:set_image(
			icon,
			texture_rect[1],
			texture_rect[2],
			texture_rect[3],
			texture_rect[4]
		)

		self.info_panels.mugshot_status:stop()
		self.info_panels.mugshot_status:animate(function(o)
			self._toolbox:animate_ui(1, function(p)
				o:set_alpha(math.lerp(o:alpha(), 1, p))
				self.info_panels.mugshot:set_alpha(math.lerp(self.info_panels.mugshot:alpha(), 0.5, p))
			end)

			o:set_alpha(1)
			self.info_panels.mugshot:set_alpha(0.5)
		end)

		return
	end

	self.info_panels.mugshot_status:stop()
	self.info_panels.mugshot_status:animate(function(o)
		self._toolbox:animate_ui(1, function(p)
			o:set_alpha(math.lerp(o:alpha(), 0, p))
			self.info_panels.mugshot:set_alpha(math.lerp(self.info_panels.mugshot:alpha(), 1, p))
		end)

		o:set_alpha(0)
		self.info_panels.mugshot:set_alpha(1)
	end)
end

function PlayerHealthPanel:update()
	if not Util:is_in_state("any_ingame_playing") then
		return
	end

	if not self._cached_conf_vars.use_health_panel then
		return
	end

	self:update_player_data()
	self:update_health_and_armor()

	self:layout_team_mugshots()
	self:layout_vanilla_chat()
	self:update_mugshot()
end

function PlayerHealthPanel:destroy()
	self._panel:clear()
	self._panel:parent():remove(self._panel)
end

local module = ... or D:module("_hud")

if RequiredScript == "lib/managers/hudmanager" then
	module:hook("OnSetupHUD", "_hud.init_custom_health_panel", function(self)
		module.initialize_panel("custom_health_panel", PlayerHealthPanel, self)
	end)

	module:hook("OnPlayerHudLayout", "_hud.layout_health_panel", function(self, hud)
		local health_panel = self._hud.custom_health_panel
		if not health_panel then
			return
		end

		health_panel._panel:set_size(hud.panel:size())
		health_panel:layout()
	end)

	module:hook("OnPreUpdateHUDVisibility", "_hud.override_health_panel_visibility", function(self, hud)
		local health_panel = self._hud.custom_health_panel
		if not health_panel then
			return
		end

		local dahm_cached_vars = self._cached_conf_vars
		local _hud_cached_vars = health_panel._cached_conf_vars
		if not _hud_cached_vars.use_health_panel then
			return
		end

		if type(dahm_cached_vars.hud_vis_health_panel) == "nil" then
			dahm_cached_vars.hud_vis_mugshots = false
			return
		end

		dahm_cached_vars.hud_vis_health_panel = false
	end)

	module:hook("OnUpdateHUDVisibility", "_hud.override_teammate_mugshots_visibility", function(self, hud)
		if type(self._cached_conf_vars.hud_vis_health_panel) ~= "nil" then
			return
		end

		local health_panel = self._hud.custom_health_panel
		if not health_panel then
			return
		end

		if health_panel._cached_conf_vars.use_health_panel then
			local mugshots = self._hud.mugshots
			for i = 1, #mugshots do
				mugshots[i].panel:set_visible(true)
			end
		end
	end)
end

if RequiredScript == "lib/units/beings/player/playerdamage" then
	local PlayerDamage = module:hook_class("PlayerDamage")
	for _, func in pairs({ "damage_bullet", "damage_killzone", "damage_explosion" }) do
		module:post_hook(50, PlayerDamage, func, function(...)
			if not managers.hud._hud.custom_health_panel then
				return
			end

			managers.hud._hud.custom_health_panel:anim_take_damage()
		end, false)
	end
end
