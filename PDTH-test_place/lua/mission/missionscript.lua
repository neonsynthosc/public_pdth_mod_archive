core:import("CoreMissionScriptElement")
core:import("CoreClass")
MissionScriptElement = MissionScriptElement or class(CoreMissionScriptElement.MissionScriptElement)

local _updator = rawget(_G, "_updator")
local MissionScriptElement = module:hook_class("MissionScriptElement")
module:post_hook(MissionScriptElement, "init", function(self)
	-- * disable team AI
	Global.criminal_team_AI_disabled = true
	managers.groupai:state():on_criminal_team_AI_enabled_state_changed()
end)

local disable_collision = function(unit)
	for index = 0, unit:num_bodies() - 1, 1 do
		local body = unit:body(index)

		if body then
			body:set_collisions_enabled(false)
			body:set_collides_with_mover(false)
			body:set_enabled(false)
		end
	end
end

local spawn_interaction = function(position, rotation, text, func)
	local interact_path = "units/world/props/apartment/apartment_key_dummy/apartment_key_dummy"
	local spawned_unit = safe_spawn_unit(Idstring(interact_path), position, rotation)
	if not alive(spawned_unit) then
		return
	end

	local interaction = spawned_unit.interaction and spawned_unit:interaction()
	if not interaction then
		return
	end

	interaction.old_selected = interaction.old_selected or interaction.selected

	interaction.selected = function(self, ...)
		self:old_selected(...)

		local icon = self._tweak_data.icon
		managers.hud:show_interact({ text = text or "default", icon = icon })
	end

	interaction.old_interact = interaction.old_interact or interaction.interact
	interaction.interact = function(self, ...)
		if type(func) == "function" then
			func()
		end
	end

	return spawned_unit
end

local delete_unit = function(unit)
	if alive(unit) then
		if unit.interaction and unit:interaction() then
			unit:interaction():set_active(false)
		end

		World:delete_unit(unit)
	end

	if alive(unit) then
		unit:set_slot(0)
	end
end

local spawn_button = function(position, rotation, text, func)
	local lamp_path = "units/world/props/apartment/apartment_hallway_lamp/apartment_hallway_lamp"

	local lamp = safe_spawn_unit_without_extensions(Idstring(lamp_path), position, rotation)
	if not lamp then
		return
	end

	-- ! Game crashes when your mover collides with the button
	disable_collision(lamp)

	spawn_interaction(position, rotation, text, func)
end

local spawn_enemy = function(enemy, position, offset, rotation, func)
	local path = string.format("units/characters/enemies/%s/%s", tostring(enemy), tostring(enemy))

	local unit = safe_spawn_unit(Idstring(path), position + offset, rotation or Rotation(180, 0, 0))
	if not alive(unit) then
		return
	end

	local action_data = {
		type = "act",
		variant = "clean",
		body_part = 1,
		align_sync = true,
	}
	local spawn_ai = {
		init_state = "inactive",
		objective = {
			type = "act",
			action = action_data,
			interrupt_on = "none",
		},
	}

	if alive(unit:inventory()._shield_unit) then
		unit:inventory()._shield_unit:unlink()
		unit:inventory()._shield_unit:set_slot(0)
	end

	unit:brain():set_spawn_ai(spawn_ai)
	unit:movement():set_allow_fire(false)
	-- managers.secret_assignment:register_unit(unit)

	unit:brain().set_logic = function() end
	unit:movement()._upd_actions = function() end
	unit:movement().set_allow_fire = function() end
	unit:inventory().drop_shield = function() end
	unit:character_damage().drop_pickup = function() end
	unit:character_damage()._spawn_head_gadget = function() end

	if type(func) == "function" then
		func(unit)
	end

	return unit
end

local spawn_text = function(position, rotation, text)
	local path = "units/dev_tools/editable_text_long/editable_text_long"
	local unit = safe_spawn_unit(Idstring(path), position, rotation)
	if not alive(unit) then
		return
	end

	if unit.editable_gui and unit:editable_gui() then
		unit:editable_gui():set_text(tostring(text))
	end
end

local add_unit_by_name = function(player, name)
	for k, v in ipairs(player:inventory()._available_selections) do
		if v.unit:name() == name then
			player:inventory():equip_selection(k, true)
			return
		end
	end

	player:inventory():add_unit_by_name(name, true)
end

local spawn_weapon = function(unit_id, position, rotation)
	local weapon_unit = safe_spawn_unit(unit_id, position, rotation)
	if not alive(weapon_unit) then
		return nil
	end

	weapon_unit:base():setup({
		user_unit = managers.player:player_unit(),
		ignore_units = {
			managers.player:player_unit(),
			weapon_unit,
		},
	})

	test_area_data.weapon_data.interaction = spawn_interaction(position, rotation, "Equip weapon", function()
		local player = managers.player:player_unit()
		if not alive(player) or not alive(weapon_unit) then
			return
		end

		local state = player:movement():current_state()
		if state:_is_reloading() or state:_changing_weapon() or state._melee_expire_t or state._use_item_expire_t then
			state._reload_enter_expire_t = nil
			state._reload_expire_t = nil
			state._reload_exit_expire_t = nil
		end

		add_unit_by_name(player, unit_id)

		managers.hud:_arrange_weapons()
		state._unit:camera():play_redirect(state.IDS_IDLE)
		managers.upgrades:setup_current_weapon()
	end)

	return weapon_unit
end

local display_unit = function(unit)
	disable_collision(unit)
	unit:character_damage():set_invulnerable(true)

	_updator:add(function()
		if not alive(unit) then
			return
		end

		unit:movement():set_rotation(Rotation(unit:rotation():yaw() + 1, 0, 0))
		unit:play_redirect(Idstring("so_debug_tpose"))
	end, tostring(unit), 0)
end

local disable_portals_and_occlusion = function()
	managers.portal.render = function() end

	for _, unit in pairs(World:find_units_quick("all", 1)) do
		managers.occlusion:remove_occlusion(unit)

		if not unit:unit_data() or unit:unit_data() and not unit:unit_data().only_visible_in_editor then
			unit:set_visible(true)
		end
	end
end

local create_museum = function()
	spawn_button(Vector3(-1940, 755, 1768), Rotation(0, 180, 0), "Teleport to the museum", function()
		disable_portals_and_occlusion()

		managers.player:warp_to(Vector3(-4505, 6032, 2935), Rotation())
	end)

	spawn_button(Vector3(-4458, 5920, 3065), Rotation(90, 90, 0), "Teleport back to the building", function()
		managers.player:warp_to(Vector3(-1845, 745, 1675), Rotation())
	end)

	local gangster_units = { "dealer", "gangster1", "gangster2", "gangster3", "gangster4", "gangster5", "gangster6" }
	for i, enemy in pairs(gangster_units) do
		spawn_enemy(enemy, Vector3(-6120, 6080, 3500), Vector3(0, 200, 0) * i, Rotation(-90, 0, 0), display_unit)
	end

	local police_and_fbi = { "cop", "cop2", "cop3", "fbi1", "fbi2", "fbi3" }
	for i, enemy in pairs(police_and_fbi) do
		spawn_enemy(enemy, Vector3(-5820, 6080, 3500), Vector3(0, 200, 0) * i, Rotation(-90, 0, 0), display_unit)
	end

	local swat_units = { "swat", "swat2", "swat3", "swat_kevlar1", "swat_kevlar2" }
	for i, enemy in pairs(swat_units) do
		spawn_enemy(enemy, Vector3(-5520, 6080, 3500), Vector3(0, 200, 0) * i, Rotation(-90, 0, 0), display_unit)
	end

	local special_units = { "tank", "taser", "shield", "spooc" }
	for i, enemy in pairs(special_units) do
		spawn_enemy(enemy, Vector3(-5220, 6080, 3500), Vector3(0, 200, 0) * i, Rotation(-90, 0, 0), display_unit)
	end

	local murky_units = { "murky_water1", "murky_water2" }
	for i, enemy in pairs(murky_units) do
		spawn_enemy(enemy, Vector3(-4920, 6080, 3500), Vector3(0, 200, 0) * i, Rotation(-90, 0, 0), display_unit)
	end
end

local despawn_bags = function()
	local data = test_area_data.bags or {}
	if next(data) then
		for k, unit in pairs(data) do
			if alive(unit) then
				unit:base():_set_empty()
				data[k] = nil
			end
		end
	end
end

module:post_hook(MissionScriptElement, "on_executed", function()
	if rawget(_G, "test_area_data") then
		return
	end

	rawset(_G, "test_area_data", {
		bags = {},
		enemies = {},
		weapon_data = { unit = nil, index = 1 },
		_environment = 2,
	})

	if not PackageManager:loaded("packages/level_slaughterhouse") then
		PackageManager:load("packages/level_slaughterhouse")
		PackageManager:load("levels/bank/world")
	end

	create_museum()

	-- * enemy spawner
	spawn_text(Vector3(-960, 210, 1735), Rotation(0, 90, 0), "Enemies") -- front
	spawn_text(Vector3(-965, 310, 1782.5), Rotation(0, -5, 0), "Enemies") -- top
	spawn_text(Vector3(-850, 340, 1735), Rotation(180, 90, 0), "Enemies") -- back
	spawn_button(Vector3(-905, 275, 1780), Rotation(0, 180, 0), "Spawn Enemies", function()
		local data = test_area_data.enemies or {}
		if next(data) then
			for i, unit in ipairs(data) do
				if alive(unit) then
					unit:base():pre_destroy(unit)
					unit:character_damage():die()
					unit:set_slot(0)
				end

				data[i] = nil
			end
		end

		for i, enemy in pairs({ "murky_water1", "swat_kevlar1", "sniper", "tank", "taser", "spooc", "shield" }) do
			table.insert(test_area_data.enemies, spawn_enemy(enemy, Vector3(-520, 1200, 1677), Vector3(-75, 0, 0) * i))
		end
	end)

	-- * bag spawner
	spawn_text(Vector3(-765, 210, 1735), Rotation(0, 90, 0), "Bags")
	spawn_text(Vector3(-765, 310, 1782.5), Rotation(0, -5, 0), "Bags")
	spawn_text(Vector3(-705, 340, 1735), Rotation(180, 90, 0), "Bags")
	spawn_button(Vector3(-732, 275, 1780), Rotation(0, 180, 0), "Spawn bags", function()
		despawn_bags()

		table.insert(test_area_data.bags, DoctorBagBase.spawn(Vector3(-780, 275, 1780), Rotation(90, 0, 0)))
		table.insert(test_area_data.bags, AmmoBagBase.spawn(Vector3(-680, 275, 1780), Rotation(90, 0, 0)))
	end)

	-- * test button
	spawn_text(Vector3(-595, 210, 1735), Rotation(0, 90, 0), "Test")
	spawn_text(Vector3(-595, 310, 1782.5), Rotation(0, -5, 0), "Test")
	spawn_text(Vector3(-530, 340, 1735), Rotation(180, 90, 0), "Test")
	spawn_button(Vector3(-560, 275, 1780), Rotation(0, 180, 0), "Test", function()
		despawn_bags()

		local equipmentList = {
			[1] = "DoctorBagBase",
			[2] = "AmmoBagBase",
		}

		local spawnUnit = function(unit, pos, rot)
			local eClass = _G[equipmentList[unit and 1 or 2]]
			if not eClass then
				return
			end

			table.insert(test_area_data.bags, eClass.spawn(pos, rot, 1, nil))
		end

		local get_sphere_points_with_rotation = function(position, n, radius)
			if n == 0 then
				return
			end

			local ret = {}
			local xxp, yyp = (360 / n), (180 / n)
			for xx = 1, n do
				for yy = 1, n do
					local newrot = Rotation(xxp * xx, 90 - (yyp * yy - (yyp / 2)), 0)
					local newpos = position + newrot:y() * radius
					local item = { pos = newpos, rot = newrot }
					table.insert(ret, item)
				end
			end
			return ret
		end

		local unit_id = true
		local sphere = get_sphere_points_with_rotation(Vector3(-140, 545, 1925), 15, 250)
		if sphere then
			for _, v in pairs(sphere) do
				spawnUnit(unit_id, v.pos, v.rot)
				unit_id = not unit_id
			end
		end
	end)

	-- * clear bags
	spawn_button(Vector3(-140, 545, 1676), Rotation(0, 180, 0), "Remove bags", despawn_bags)

	-- * roof accesses
	spawn_button(Vector3(-1950, 605, 125), Rotation(90, 90, 0), "Teleport back to the roof", function()
		managers.player:warp_to(Vector3(-1845, 745, 1675), Rotation())
	end)
	spawn_button(Vector3(450, 605, 70), Rotation(90, -90, 0), "Teleport back to the roof", function()
		managers.player:warp_to(Vector3(330, 600, 1675), Rotation())
	end)
	spawn_button(Vector3(-3700, -50, 125), Rotation(90, -90, 0), "Teleport back to the roof", function()
		managers.player:warp_to(Vector3(-335, 1095, 1675), Rotation())
	end)

	--* weapon selector
	spawn_button(Vector3(-1065, 275, 1755), Rotation(-90, 225, 0), "Spawn Gun", function()
		_updator:remove("weapon_display")

		local weapon_data = test_area_data.weapon_data
		local PlayerInventory = _G.PlayerInventory
		local weapon_list = PlayerInventory._index_to_weapon_list
		if weapon_data.unit then
			delete_unit(weapon_data.unit)
			delete_unit(weapon_data.interaction)

			weapon_data.unit = nil
		end

		weapon_data.unit = spawn_weapon(weapon_list[weapon_data.index], Vector3(-1025, 275, 1800), Rotation(0, 0, 0))

		weapon_data.index = weapon_data.index + 1
		if weapon_data.index > (#weapon_list - 2) then -- last 2 weapons are enemy weapons and crash the game.
			weapon_data.index = 1
		end

		_updator:add(function()
			if not alive(weapon_data.unit) then
				_updator:remove("weapon_display")
				return
			end

			weapon_data.unit:set_rotation(Rotation(weapon_data.unit:rotation():yaw() + 1, 0, 0))
		end, "weapon_display", 0)
	end)
	spawn_text(Vector3(-1090, 310, 1705), Rotation(-90, 75, 0), "Guns")

	-- * environment selector
	spawn_text(Vector3(-645, -72, 1724), Rotation(180, 90, 0), "Environment")
	spawn_button(Vector3(-732, -88, 1768), Rotation(0, 180, 0), "Change environment", function()
		local environments = {
			[1] = "environments/env_apartment/env_apartment",
			[2] = "environments/env_bank/env_bank",
			[3] = "environments/env_bridge2/env_bridge2",
			[4] = "environments/env_diamond2/env_diamond2",
			[5] = "environments/env_l4d/env_l4d",
			[6] = "environments/env_slaughterhouse/env_slaughterhouse",
			[7] = "environments/env_street/env_street",
			[8] = "environments/env_suburbia/env_suburbia",
			[9] = "environments/env_undercover/env_undercover",
		}

		local environment_name = environments[test_area_data._environment]
		managers.viewport:preload_environment(environment_name)
		managers.environment_area:set_default_environment(environment_name, nil, nil)

		test_area_data._environment = test_area_data._environment + 1
		if test_area_data._environment > #environments then
			test_area_data._environment = 1
		end
	end)
end)
