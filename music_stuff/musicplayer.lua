-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = ... or D:module("music_stuff")
local MusicPlayer = module:hook_class("MusicPlayer", class)

local send_command = function(musicplayer, cmd, result_cb, ...)
	if result_cb ~= nil and type(result_cb) ~= "function" then
		error("Invalid result callback", 2)
	end

	-- this does not do anything
end

function MusicPlayer:init(currently_playing, command_function)
	self._currently_playing = currently_playing
	if type(command_function) == "function" then
		send_command = command_function
	end
end

function MusicPlayer:tracks()
	return self._tracks
end

function MusicPlayer:set_flag(flag, state)
	-- not handled
end

function MusicPlayer:set_volume(percentage, force)
	if self._currently_playing or force then
		send_command(self, "volume", false, percentage)
		self._volume_to_request = nil
	else
		self._volume_to_request = percentage
	end
end

function MusicPlayer:currently_playing()
	return self._currently_playing
end

function MusicPlayer:play(data, force)
	local __fn_name = "MusicPlayer:play"
	module:log(2, __fn_name, "play item:", JSON:encode(data))

	local track_path, cb_obj = data
	if type(data) == "table" then
		cb_obj = data.callback or data.cb or nil
		track_path = data.uri or data.url or data.path
	end

	if track_path then
		if not force and self._currently_playing == track_path then
			module:log(2, __fn_name, "is currently playing and stage is not forced => ignoring")
			return
		end

		-- request volume change
		if self._volume_to_request ~= nil then
			self:set_volume(self._volume_to_request, true)
		end

		-- play item
		module:log(3, __fn_name, "requesting track " .. track_path)
		send_command(self, "enable_loop")
		send_command(self, "play_track", false, track_path)

		-- (delayed) callback
		if cb_obj and managers.delayed_callbacks then
			if self._current_tcid then
				managers.delayed_callbacks:remove_time_callback(self._current_tcid)
				self._current_tcid = nil
			end

			local delay, cb
			if type(cb_obj) == "table" then
				delay = cb_obj.delay

				if cb_obj.callback then
					cb = cb_obj.callback
				elseif cb_obj.action then
					cb = function(track, stage, o)
						for _, action in ipairs(o.actions or { o.action }) do
							module:log(3, __fn_name, "requesting command=" .. action)
							send_command(self, "action", false, action)
						end
					end
				end
			end

			if cb then
				self._current_tcid = managers.delayed_callbacks:add_time_callback(function(data, o)
					cb(data, o)
					self._current_tcid = nil
				end, delay or 0, 1, false, data, cb_obj)
			end
		end
	elseif module:current_log_level() >= 4 then
		module:log(4, __fn_name, string.format("cannot play item '%s'. ignoring.", tostring(track_path)))
	end

	self._currently_playing = track_path
	Global.music_manager.mm_playing = track_path
end

function MusicPlayer:stop()
	if self._currently_playing then
		module:log(2, "MusicPlayer:stop", "requesting stop")
		send_command(self, "stop")
		self._currently_playing = nil
	else
		module:log(4, "MusicPlayer:stop", "not playing anything")
	end
end