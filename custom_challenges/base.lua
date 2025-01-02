-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

-- Custom challenges for PAYDAY: The Heist.

local module = DorHUDMod:new("custom_challenges", {
	abbr = "CUC", dependencies = { "improved_stat_tracking", "peer_loadout", "scriman" },
	author = "dorentuz", version = "0.7.3", description = {
		english = "Custom challenges for PAYDAY: The Heist"
	},
	update = {
		id = "pdthchallenges", url = "https://www.dropbox.com/s/mzd56tgkk6fjot3/version.txt?dl=1",
		on_post_install = function(entry, success)
			-- remove old files
			if not success or not entry.module then
				return
			end
			
			local mod_path = entry.module:path() or string.format("%s%s/", DorHUD:root_path(), entry.module:id())
			local files = os.get_files(mod_path)
			if files then
				for _, path in pairs(files) do
					local dir, name, ext = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
					if string.is_nil_or_empty(dir) and ext == "lua" and name ~= "base.lua" then
						os.remove(mod_path .. name)
					end
				end
			end
		end
	}
})

if not DorHUD:is_production_build() then
	-- guard against older mod versions
	module:set_script_base_path("src", { conditions = "use_source_files exists" })
end

module:register_include("includes", true)

-- register module
return module