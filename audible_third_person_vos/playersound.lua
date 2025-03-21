if PlayerSound then
	PlayerSound._third_person_ids = {
		g90 = true,
		g50 = true,
		g51 = true,
		g70 = true,
		g71  = true,
		g40x_any = true,
		f02x_sin = true,
		f02x_plu = true,
		f03a_plu = true,
		f03a_sin = true,
		s05a_sin = true,
		s05b_sin = true,
		s09a = true,
		s09b = true,
		s09c = true,
		fwb_80 = true
	}

	function PlayerSound:get_sound_name_by_event_id(event_id)
		for i_event, event_name in pairs(self._event_list) do
			if i_event == event_id then
				return event_name
			end
		end
		return nil
	end
	
	
	--- I don't know why I made huskplayers share this function. Whyyyy? I mean, it works fine but why??
	local _PlayerSound_say = PlayerSound.say
	function PlayerSound:say(sound_name, sync)
		if type(sound_name) == "number" then
			local sync_sound_name = self:get_sound_name_by_event_id(sound_name)
			if not sync_sound_name then
				io.write("[PlayerSound:say] invalid event_id cannot be played "..sound_name.."\n")
				return
			end
			sound_name = sync_sound_name
		end
		local switch 
		if sync and not PlayerSound._event_id_transl_map[sound_name] then
			self._unit:network():send("sync_player_sound", sound_name, "nil")
		end
		local ss = self._unit:sound_source()
		if self._unit:base().is_local_player then
			switch = true
			local is_third = PlayerSound._third_person_ids[sound_name]
			ss:set_switch("int_ext", is_third and "third" or "first")
		end
		self._last_speech = _PlayerSound_say(self, sound_name, sync)		
		if switch then
			ss:set_switch("int_ext", "third")
		end
		return self._last_speech
	end


	function PlayerSound:sync_say(event_id)
		self:say(event_id, false)
	end
	
	
end