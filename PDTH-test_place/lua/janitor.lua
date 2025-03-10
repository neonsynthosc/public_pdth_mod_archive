if not rawget(_G, "Janitor") then
	rawset(_G, "Janitor", {
		_all_unit_data = {},
		_selected_unit = nil,
		_last_active_unit = nil,
		_compressed_file_path = module:path() .. "data/heist_units_compressed.lua",
		_uncompressed_file_path = module:path() .. "data/heist_units_uncompressed.lua",
	})

	function Janitor:current_time()
		return TimerManager:main():time()
	end

	function Janitor:ray_forward(dist)
		local local_player = managers.player:player_unit()
		local from = local_player:movement():m_head_pos()
		local to = from + local_player:movement():m_head_rot():y() * (dist or 20000)
		return from, to
	end

	function Janitor:str_current_heist()
		return Global.level_data.level_id
	end

	function Janitor:load_table_from_file(filename)
		local file = io.open(filename, "r")
		if not file then
			return {}
		end

		local info = loadstring(file:read("*all"))()
		file:close()

		return info
	end

	function Janitor:write_table_to_file_raw(tbl, filename)
		local file = io.open(filename, "w+")
		if not file then
			return
		end

		file:write("return {")

		local function do_recursion_raw(file, data)
			local is_first = false
			for i, v in pairs(data) do
				if type(v) == "table" then
					file:write((is_first and "," or "") .. (type(i) == "number" and "" or ('["' .. i .. '"]=')) .. "{")
					is_first = true
					do_recursion_raw(file, v)
				else
					file:write(
						(is_first and "," or "")
							.. (type(i) == "number" and "" or (i .. "="))
							.. (
								type(v) == "string" and ('"' .. tostring(v):gsub("[\n\r]", "") .. '"')
								or tostring(v):gsub("[\n\r]", "")
							)
					)
					is_first = true
				end
			end

			file:write("}")
		end

		do_recursion_raw(file, tbl)

		file:close()
	end

	function Janitor:decompress_ids(list)
		local current_progress = 0
		local new_table = {}
		for i = #list - 1, 1, -2 do
			current_progress = current_progress + list[i]

			for i = 0, list[i + 1], 1 do
				table.insert(new_table, current_progress + i)
			end

			current_progress = current_progress + list[i + 1]
		end

		return new_table
	end

	function Janitor:compress_ids(list)
		table.sort(list, function(a, b)
			return a < b
		end)

		local new_table = {}
		local last_item = 0
		for i = 1, #list, 1 do
			local current_item = list[i]

			if current_item - last_item > 1 then
				table.insert(new_table, 1, 0)
				table.insert(new_table, 1, current_item - last_item)
				last_item = current_item
			elseif current_item - last_item == 1 then
				last_item = current_item
				new_table[2] = new_table[2] + 1
			end
		end

		return new_table
	end

	function Janitor:load_unit_data() --loads all the data
		local compressed_data = self:load_table_from_file(self._compressed_file_path)

		self._all_unit_data = {}
		for i, v in pairs(compressed_data) do
			if not self._all_unit_data[i] then
				self._all_unit_data[i] = self:decompress_ids(v)
			end
		end
	end

	function Janitor:save_unit_data() --saves all the data
		local current_heist = self:str_current_heist()
		if not self._all_unit_data[current_heist] then
			self._all_unit_data[current_heist] = {}
		end

		local compressed_data = {}
		for i, v in pairs(self._all_unit_data) do
			compressed_data[i] = self:compress_ids(v)
		end

		self:write_table_to_file_raw(self._all_unit_data, self._uncompressed_file_path)
		self:write_table_to_file_raw(compressed_data, self._compressed_file_path)
	end

	function Janitor:show_selected_unit()
		_G._updator:remove("unitalksjdkasd")
		_G._updator:remove("asdasdasdsadasd")

		local units_in_world = {}
		_G._updator:add(function()
			units_in_world = {}
			local lp_pos = managers.player:player_unit():movement():m_pos()
			for _, unit in pairs(World:find_units_quick("all")) do
				if mvector3.distance(unit:position(), lp_pos) and unit:editor_id() > 0 then
					table.insert(units_in_world, unit)
				end
			end
		end, "asdasdasdsadasd", 0.25)

		_G._updator:add(function()
			local should_show_pos = false --draws a circle at the pos
			local should_show_all = false --draws a box around the unit
			local _, to = self:ray_forward(500)
			if not to then
				return
			end

			Application:draw_sphere(to, 5, 0, 1, 0)

			local closes_dist = 1000000
			for i, v in pairs(units_in_world) do
				if alive(v) then
					if not self._selected_unit then
						self._selected_unit = v
					else
						local ray_dist = mvector3.distance(v:position(), to)
						if ray_dist < closes_dist then
							self._selected_unit = v
							closes_dist = ray_dist
						end
					end

					if should_show_pos then
						Application:draw_sphere(v:position(), 3, 1, 1, 1)
					end

					if should_show_all then
						Application:draw(v, 1, 1, 1)
					end
				else
					table.remove(units_in_world, i)
				end
			end

			if alive(self._selected_unit) then
				local time = self:current_time() * 6 % 1 --blinking thing
				local time2 = self:current_time() % 1
				if alive(self._last_active_unit) then
					if self._last_active_unit ~= self._selected_unit then
						local state = true

						if
							self._last_active_unit:unit_data()
							and self._last_active_unit:unit_data().only_visible_in_editor == true
						then
							state = false
						end

						self._last_active_unit:set_visible(state)
					else
						self._last_active_unit:set_visible(true)

						if time2 > 0.5 then
							self._last_active_unit:set_visible(false)
						end
					end
				end

				self._last_active_unit = self._selected_unit
				if time > 0.5 then
					Application:draw(self._selected_unit, 1, 1, 1)
				end
			end
		end, "unitalksjdkasd", 0)
	end

	function Janitor:delete_unit_and_add() --deleted highlighted unit
		local current_heist = self:str_current_heist()
		if not self._all_unit_data[current_heist] then
			self._all_unit_data[current_heist] = {}
		end

		if self._selected_unit and alive(self._selected_unit) then
			local item = self._selected_unit:editor_id()
			local save_data = true

			--check if unit is not already in the list
			for i, v in pairs(self._all_unit_data[current_heist]) do
				if v == item then
					save_data = false
					break
				end
			end

			if save_data then
				table.insert(self._all_unit_data[current_heist], item)
			end

			Network:detach_unit(self._selected_unit)
			World:delete_unit(self._selected_unit)
		end
	end

	function Janitor:delete_all_same() --delete all the units in world that have the same key as the highlighted unit
		local current_heist = self:str_current_heist()
		if not self._all_unit_data[current_heist] then
			self._all_unit_data[current_heist] = {}
		end

		if self._selected_unit and alive(self._selected_unit) then
			local id = self._selected_unit:name():key()
			for _, unit in pairs(World:find_units_quick("all", 1)) do
				if unit:name():key() == id then
					local item = unit:editor_id()
					local save_data = true

					--check if unit is not already in the list
					for i, v in pairs(self._all_unit_data[current_heist]) do
						if v == item then
							save_data = false
						end
					end

					if save_data then
						table.insert(self._all_unit_data[current_heist], item)
					end

					Network:detach_unit(unit)
					World:delete_unit(unit)
				end
			end
		end
	end

	function Janitor:restore_unit_and_remove() --function that does the deleting
		self:load_unit_data()

		-- remove mass units
		MassUnitManager:delete_all_units()

		local current_heist = self:str_current_heist()
		if not self._all_unit_data[current_heist] then
			return
		end

		local start_p = 1
		local end_p = 21
		local table_to_itterate = self._all_unit_data[current_heist]
		local step = 20
		local max_items = #table_to_itterate
		local units_in_world_2 = {}

		for _, unit in pairs(World:find_units_quick("all", 1)) do
			units_in_world_2[unit:editor_id()] = unit
		end

		_G._updator:add(function()
			if start_p > max_items then
				_G._updator:remove("removeasdjklaskjdlasjld")

				return
			end

			for i = start_p, end_p, 1 do
				local data_id = table_to_itterate[i]
				if units_in_world_2[data_id] and alive(units_in_world_2[data_id]) then
					Network:detach_unit(units_in_world_2[data_id])
					World:delete_unit(units_in_world_2[data_id])
				end
			end

			start_p = end_p
			end_p = end_p + step
		end, "removeasdjklaskjdlasjld", 0.016)
	end
end

local module = ... or D:module("test_place_mutator")
local GameSetup = module:hook_class("GameSetup")

module:post_hook(50, GameSetup, "init_finalize", function(self)
	local unit_remover = rawget(_G, "Janitor")
	if unit_remover then
		unit_remover:restore_unit_and_remove()
	end
end)
