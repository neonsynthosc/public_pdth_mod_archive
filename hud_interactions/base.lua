-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = DMod:new("hud_interactions", {
	abbr = "HIN", dependencies = { "hud" },
	disabled_by_default = true, bundled = true,
	author = "dorentuz", description = {
		english = "Addon to the HUD mod to show interactions for players with the same mod."
	}
})

module:hook_post_require("lib/managers/hudmanager", "hudmanager")
module:hook("OnNetworkDataRecv", 'OnNetworkDataRecv_HUDShowInteractions', { "interaction" }, function(peer, data_type, data)
	if not managers.criminals or not managers.hud then
		return
	end

	if type(data) == "table" and data.action ~= nil then
		local mugshot_id
		if peer:is_server() and data.criminal ~= nil then
			local criminal_data = managers.criminals:character_data_by_name(data.criminal)
			mugshot_id = criminal_data and criminal_data.mugshot_id
		else
			local peer_id = peer:id()
			for _, criminal_data in pairs(managers.criminals._characters) do
				if criminal_data.taken and peer_id == criminal_data.peer_id then
					mugshot_id = criminal_data.data.mugshot_id
					break
				end
			end
		end

		if mugshot_id then
			if data.action == "start" then
				managers.hud:start_mugshot_interaction(mugshot_id, data.timer or 3, data.unit)
			elseif data.action == "interrupt" then
				managers.hud:end_mugshot_interaction(mugshot_id, false, data.unit)
			elseif data.action == "end" then
				managers.hud:end_mugshot_interaction(mugshot_id, true, data.unit)
			end
		end
	end
end, true)

module:hook("OnPeerAdded", "OnPeerAdded_AddInteractionListener", function(peer)
	peer:add_callback(peer.SYNC_DONE_CALLBACK, function(peer)
		DNet:send_to_peer(peer, "ModEvent", { module = "hud", event = "EnableInteractionEvents" }, false, false)
	end)
end)

return module