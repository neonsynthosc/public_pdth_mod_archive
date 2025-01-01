-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ...
local MusicManager = module:hook_class("CoreMusicManager")

require(module:path() .. "musicplayer")

module:hook(20, MusicManager, "init", function(self)
	module:call_orig(MusicManager, "init", self)

	self._users_talking = { N = 0 }
	self._tracks = table.merge({
		-- ingame defaults:
		["ingame_apartment"] = {
			_name = managers.localization:text("ingame_track_apartment"),
			_type = "ingame",
			music_id = "apa"
		},
		["ingame_bank"] = {
			_name = managers.localization:text("ingame_track_bank"),
			_type = "ingame",
			music_id = "bank"
		},
		["ingame_bridge"] = {
			_name = managers.localization:text("ingame_track_bridge"),
			_type = "ingame",
			music_id = "bri"
		},
		["ingame_diamond_heist"] = {
			_name = managers.localization:text("ingame_track_diamond_heist"),
			_type = "ingame",
			music_id = "dia"
		},
		["ingame_hospital"] = { -- requires soundbanks/music_hos
			_name = managers.localization:text("ingame_track_hospital"),
			_type = "ingame",
			music_id = "hos",
			_requires_level = "hospital"
		},
		["ingame_secret_stash"] = {  -- requires soundbanks/music_und
			_name = managers.localization:text("ingame_track_secret_stash"),
			_type = "ingame",
			music_id = "und",
			_requires_level = "secret_stash"
		},
		["ingame_slaughter_house"] = {
			_name = managers.localization:text("ingame_track_slaughter_house"),
			_type = "ingame",
			music_id = "sla"
		},
		["ingame_heat_street"] = {
			_name = managers.localization:text("ingame_track_heat_street"),
			_type = "ingame",
			music_id = "str"
		},
		["ingame_suburbia"] = { -- requires soundbanks/music_cft
			_name = managers.localization:text("ingame_track_suburbia"),
			_type = "ingame",
			music_id = "cft",
			_requires_level = "suburbia"
		}
	}, D:conf("musicplayer_tracks"))
	self._level_to_track = D:conf("musicplayer_default_level_tracks")
	self._menu_event_action = D:conf("musicplayer_default_menu_action") or "ingame"
	self._mute_on_voice = D:conf("musicplayer_mute_on_voice")
	if type(self._mute_on_voice) ~= "number" then
		self._mute_on_voice = self._mute_on_voice and 0
	end

	self:set_track(self:get_track_for_level() or self._tracks.default and "default" or "ingame_default", true)
	NetworkPeer:register_persistent_property("mp_mov_ignore")

	-- load customizations if present
	do
		local setup_customization_path = module:path() .. "setup_customization.lua"
		if os.file_exists(setup_customization_path) then
			loadfile(setup_customization_path)(module, self)
		end
	end
end)

module:hook(20, MusicManager, "post_event", function(self, level, event, is_level_independent, force)
	local __fn_name = "MusicManager:post_event"
	module:log(5, __fn_name, "post event:", level, event, JSON:encode(Global.music_manager.current_event))

	-- handle special cases
	if level == "load_level" then
		self._loading_level = event
		if event == true or (not Global.level_data or not Global.level_data.level_id) then
			return
		end

		-- play level intro track
		event, level = "loadout_music"
	elseif level == "loadout_music" or level == "menu_music" then
		event, level = level
	elseif is_level_independent then
		level = nil
	elseif not level then
		module:log(5, __fn_name, "ignoring " .. tostring(event) .. ": requires a level")
		return
	end

	if event == nil then
		-- ignore calls without a level or name (unmodified calls)
		module:log(5, __fn_name, "ignoring", level, event, is_level_independent)
		return
	end

	self:_play_track_event(event, level, force)
end)

module:hook(60, MusicManager, "tracks", function(self)
	return self._tracks
end)

module:hook(60, MusicManager, "current_track", function(self)
	if self._current_track then
		return self._current_track, self._tracks[self._current_track]
	end
	return self._current_track
end)

module:hook(60, MusicManager, "get_track_for_level", function(self, level)
	level = level or (Global.level_data and Global.level_data.level_id)
	if self._level_to_track then
		return self._level_to_track[level]
	end
end)

module:hook(20, MusicManager, "set_track", function(self, track, set_only)
	module:log(3, "MusicManager:set_track", "track =", track, set_only)

	if self._loading_level then
		if track == "default" and Global.music_manager and Global.music_manager.current_track_id ~= track then
			module:log(3, "MusicManager:set_track", "not setting default track while loading the level")
			return
		end
	end

	if track then
		if track == "ingame_default" then
			-- default option
			if not set_only and self._current_track then
				if self._music_player then
					self._music_player:stop()
				end
			end
			self._current_track = track
		elseif track == "random" or track:find("^random_") then
			-- random option
			local available_tracks, current_level = {}, Global.level_data.level_id or "menu"
			if track == "random_ingame" then
				-- collect ingame tracks
				for track_id, o in pairs(self._tracks) do
					if not o._requires_level or o._requires_level == current_level then
						if o._type == "ingame" and track_id ~= "default" and (current_level == "menu" or track_id ~= "menu") then
							table.insert(available_tracks, track_id)
						end
					end
				end
			elseif track == "random_other" then
				-- collect other tracks
				for track_id, o in pairs(self._tracks) do
					if not o._requires_level or o._requires_level == current_level then
						if o._type ~= "ingame" and track_id ~= "default" and (current_level == "menu" or track_id ~= "menu") then
							table.insert(available_tracks, track_id)
						end
					end
				end
			elseif track == "random" then
				-- collect all tracks
				for track_id, o in pairs(self._tracks) do
					if not o._requires_level or o._requires_level == current_level then
						if track_id ~= "default" and (current_level == "menu" or track_id ~= "menu") then
							table.insert(available_tracks, track_id)
						end
					end
				end
			end

			if available_tracks[1] ~= nil then
				self._current_track = available_tracks[math.random(1, #available_tracks)]
				module:log(3, "MusicManager:set_track", "random track =", self._current_track)
			else
				-- invalid data
				self._current_track = false
				module:log(3, "MusicManager:set_track", "(random) track is invalid")
				if not set_only and self._current_track then
					self:stop()
				end
				return
			end
		elseif self._tracks[track] then
			self._current_track = track
		else
			-- invalid data
			self._current_track = false
			module:log(3, "MusicManager:set_track", "track is invalid")
			if not set_only and self._current_track then
				self:stop()
			end
			return
		end

		if module:current_log_level() >= 4 then
			module:log(3, "MusicManager:set_track", "track data:", JSON:encode(self._current_track))
		end

		-- start playing after a certain timeout
		if not set_only then
			local mmg = Global.music_manager

			-- small delay so we don't play the selection instantly
			if self._delayed_start_tcid then
				managers.delayed_callbacks:remove_time_callback(self._delayed_start_tcid)
			end
			self._delayed_start_tcid = managers.delayed_callbacks:add_time_callback(function()
				self:_play_track_event(mmg.current_event_stage, mmg.current_event_level, true)
			end, 0.5, 1, true)
		end

		return true
	else
		if not set_only and self._current_track then
			self:stop()
		end
		self._current_track = false
		Global.music_manager.current_track_id = "none"
	end
end)

module:hook(20, MusicManager, "_play_track_event", function(self, event, level_id, force)
	local __fn_name = "MusicManager:_play_track_event"
	local track_id, track_data = self:current_track()
	if module:current_log_level() >= 3 then
		module:log(3, __fn_name, "event, level_id, track_id, track_data =",
			JSON:encode({ event = event, level_id = level_id, id = track_id, data = track_data })
		)
	end

	-- determine event name
	local name = nil
	if track_id ~= false then
		local music_id = track_data and track_data.music_id
		if not music_id then
			local level_data = level_id and tweak_data.levels[level_id]
			music_id = level_data and level_data.music or "default"
		end

		name = tweak_data.music[music_id][event]
		if level_id == nil and name == nil then
			module:log(5, __fn_name, "is level independent and name is not defined directly //", track_id, event)

			-- check track data, but fall back to the event
			--if self._music_player and track_id ~= "ingame_default" then -- NOTE: why is music player needed?
			if track_id ~= "ingame_default" then
				local tracks = self:tracks()
				if tracks and not table.empty(tracks) then
					local menu_track_id = self:get_track_for_level("menu")
					if menu_track_id == false then
						-- disabled via mapping
						module:log(5, __fn_name, "disabled via mapping")
						name = false
					else
						-- find track id in these tracks: [selected track], menu, default
						local possible_track_ids = { "menu", "default" }
						if menu_track_id ~= nil then table.insert(possible_track_ids, menu_track_id, 1) end
						for _, tid in ipairs(possible_track_ids) do
							local track = tracks[tid]
							module:log(5, __fn_name, "checking", tid, "for presence and event definition", track)
							if track ~= nil then
								if track then
									if track[event] ~= nil then
										-- entry defined
										module:log(5, __fn_name, "entry defined", tid, JSON:encode(track[event]), JSON:encode(track))
										track_id, track_data, name = tid, track, track[event]
										break
									end
								else
									-- disabled via track definition
									module:log(5, __fn_name, "disabled via track definition")
									name = false
									break
								end
							end
						end
					end
				end
			end

			-- if nothing is defined, fall back to the default action
			if name == nil then
				if self._menu_event_action == "ingame" or track_id == "ingame_default" then
					module:log(5, __fn_name, "nothing defined, using ingame music")
					track_data, track_id, name = { _type = "ingame" }, "ingame_default", event
				elseif not self._menu_event_action or self._menu_event_action == "none" then
					module:log(5, __fn_name, "nothing defined, stopping")
					level_id, name = false, false
				end
			end
		end
	elseif track_id == false then
		module:log(5, __fn_name, "track id is false")
		if not self._current_sound_source or self._current_sound_source == "ingame" then
			Global.music_manager.source:stop()
		end
	end

	if name == nil and not level_id then
		-- fallback for menu sounds
		module:log(5, __fn_name, "name is nil, falling back to event")
		name = event
	end

	local mmg = Global.music_manager -- should exist
	local is_different_event = name and mmg.current_event ~= name
	if is_different_event then
		module:log(5, __fn_name, "is different event", name)
		mmg.current_event = name
		mmg.current_event_level = level_id
		mmg.current_event_stage = event
		mmg.current_track_id = track_id or "ingame_default"
	end

	if track_id and track_data and track_data._type ~= "ingame" then
		if not self._current_sound_source or self._current_sound_source == "ingame" then
			mmg.source:stop()
		end

		module:log(5, __fn_name, "do custom play", name, level_id, "custom")
		if self._music_player then
			module:log(5, __fn_name, "do custom play", name, level_id, "custom")
			self._music_player:play(self._tracks[track_id][event], force)
		else
			module:log(3, __fn_name, "no music player defined")
		end
	elseif is_different_event then
		module:log(5, __fn_name, "do ingame play", name, level_id, "ingame")

		-- should override?
		if track_id and track_id ~= "ingame_" .. (Global.level_data and Global.level_data.level_id or "") then
			-- somehow load package
			-- if track_data._requires_package then
				-- local required_package_ids = Idstring(track_data._requires_package)
				-- if PackageManager:has(required_package_ids, Idstring("bnk")) then
					-- if not PackageManager:loaded(required_package_ids) then
						-- PackageManager:load(required_package_ids)
					-- else
						-- module:log(4, __fn_name, "package already loaded:", track_data._requires_package)
					-- end
				-- else
					-- module:log(4, __fn_name, "does not have package", track_data._requires_package)
				-- end

				-- local level_package = "packages/level_hospital"
				-- if level_package and not PackageManager:loaded(level_package) then
					-- module:log(3, __fn_name, "loading package", level_package)
					-- PackageManager:load(level_package)
				-- else
					-- module:log(3, __fn_name, "not loading level package")
				-- end
			-- end

			if track_data and track_data[event] then
				name = track_data[event]
				module:log(5, __fn_name, "name override:", name)
			end
		else
			module:log(5, __fn_name, "no override", track_id, Global.level_data and Global.level_data.level_id)
		end

		if self._music_player and self._current_sound_source == "custom" then
			self._music_player:stop()
		end

		Global.music_manager.source:post_event(name)
		self._current_sound_source = "ingame"
	elseif not name then
		module:log(5, __fn_name, "no name")
		if not self._current_sound_source or self._current_sound_source == "ingame" then
			Global.music_manager.source:stop()
		elseif self._music_player then
			self._music_player:stop()
		end
		Global.music_manager.current_event = event
	else
		module:log(5, __fn_name, "event is not different and name is not false, so ignoring")
	end
end)

module:hook(20, MusicManager, "stop", function(self)
	Global.music_manager.source:stop()
	Global.music_manager.current_event = nil

	if self._music_player then
		-- external player can keep playing when loading levels
		if not self._loading_level then
			self._music_player:stop()
		end
	end
end)

module:hook(20, MusicManager, "set_flag_state", function(self, flag, state)
	SoundDevice:set_state(flag, state)

	if self._music_player then
		if flag == "wave_flag" then
			self._music_player:set_flag(flag, state)
		end
	end
end)

module:hook(20, MusicManager, "player", function(self)
	return self._music_player
end)

module:hook(20, MusicManager, "set_volume", function(self, percentage)
	Global.music_manager.volume = percentage
	SoundDevice:set_rtpc("option_music_volume", percentage)
	if self._music_player then
		self._music_player:set_volume(percentage)
	end
end)

module:hook(20, MusicManager, "set_voice_slot_active", function(self, peer, active)
	if peer:property("mp_mov_ignore") then
		return
	end

	if self._users_talking[peer:id()] ~= active then
		self._users_talking.N = self._users_talking.N + (active and 1 or -1)

		if self._mute_on_voice then
			if self._users_talking.N > 0 then
				if not self._original_volume then
					-- mute
					self._original_volume = Global.music_manager.volume
					self:set_volume(self._mute_on_voice)
				end
			else
				if self._original_volume then
					-- unmute
					self:set_volume(self._original_volume)
					self._original_volume = nil
				end
			end
		end
	end
end)

module:hook(20, MusicManager, "save", function(self, data)
	local mmg = Global.music_manager
	local state = {
		event = mmg.current_event,
		event_stage = mmg.current_event_stage,
		event_level = mmg.current_event_level
	}

	-- use default event for synced data
	local level_id = Global.level_data and Global.level_data.level_id
	local real_event = level_id and tweak_data.levels:get_music_event(state.event_stage or -1)
	if real_event then
		state.event = real_event
	end

	if module:current_log_level() >= 4 then
		module:log(4, "MusicManager", "saving data:", JSON:encode(state))
	end

	data.CoreMusicManager = state
end)

module:hook(20, MusicManager, "load", function(self, data)
	local __fn_name = "MusicManager:load"
	local state = data.CoreMusicManager

	if module:current_log_level() >= 4 then
		module:log(4, __fn_name, "data dump:")
		dump_table(4, state)
	end

	local current_level_id = Global.level_data and Global.level_data.level_id
	if state.event_stage then
		self:post_event(state.event_level or current_level_id, state.event_stage)
	elseif state.event then
		-- determine level and stage from event name
		local event_found = false
		for id, data in pairs(tweak_data.music) do
			for stage, name in pairs(data) do
				if name == state.event then
					-- just assume the current level
					self:post_event(current_level_id, stage)
					event_found = { id = id, stage = stage, event = name }
					break
				end
			end
			if event_found then
				if event_found.stage == "fake_assault" then
					-- assault music is usually used for fake_assault as well, so check which one is correct
					local music_td_stages = tweak_data.music[event_found.id]
					if music_td_stages.assault and music_td_stages.assault == event_found.event then
						if not data.group_ai or not data.group_ai._fake_assault_mode then
							event_found.stage = "assault"
						end
					end
				end
				break
			end
		end

		if module:current_log_level() >= 4 then
			module:log(4, __fn_name, "music event found:", JSON:encode(event_found), state.event_level or current_level_id)
		end

		-- try to play the standard event
		if not event_found then
			self:post_event(state.event_level or current_level_id, state.event, not Util:is_ingame_state())
		end
	end
end)