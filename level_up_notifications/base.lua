local module = DMod:new("level_up_notifications", {
	author = "dorentuz", version = "0.1", dependency = "hud"
})

local tc = {}

local function display_lvlup_notification(peer)
	-- remove callback id
	tc[peer:user_id()] = nil
	
	local rep, virt_rep = peer:level()
	virt_rep = peer:property("virtual_rep_level")
	if type(virt_rep) == "number" and virt_rep <= rep then
		virt_rep = nil
	end

	if (virt_rep or rep) <= 0 then
		return
	end

	Util:say_to_chat(string.format(
		"Player %s leveled up and now has %slevel %i!",
		peer:name(), (virt_rep and "(virtual) " or ""), virt_rep or rep
	), false, true)
end

local function on_peer_level_up(peer, level, old_level)
	-- delayed notification already queued
	if tc[peer:user_id()] then
		return
	end

	if level and not old_level then
		return
	end

	-- add a 1s timeout to deal with multiple level ups in a short time
	tc[peer:user_id()] = managers.delayed_callbacks:add_time_callback(
		display_lvlup_notification, 1, 1, false, peer
	)
end

module:hook("OnPeerAdded", "OnPeerAdded_ShowLevelUpNotification", function(peer, is_new)
	if peer:is_local_user() then
		return
	end

	peer:add_listener("OnPeerLevelChanged_ShowLevelUpNotification", "level", on_peer_level_up)
end)

module:hook("OnModuleLoaded", "OnModuleLoaded_ListenToHudModEvent", function(module)
	D:module("hud"):hook("OnNetworkDataRecv", "OnNetworkDataRecv_ShowLevelUpNotification", "ModEvent", function(peer, data_type, data)
		if data.event == "VirtualRep" then
			local new_virtual_level = tonumber(data.value) or 0
			if peer._virtual_level and peer._virtual_level < new_virtual_level then
				on_peer_level_up(peer)
			end
			peer._virtual_level = new_virtual_level
		end
	end)
end)

return module