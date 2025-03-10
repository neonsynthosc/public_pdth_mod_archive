-- DorHUD by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local module = DorHUDMod:new("juke_box", { abbr = "JKBX", priority = -8,
	author = "Whurr + DorentuZ' + Milanesá™", version = "1.4", bundled = true, description = {
		english = "Allows you to change what music plays on each heist.",
		spanish = "Te permite cambiar la música que suena para cada atraco."
	}
})

module:add_config_option("bank_music")
module:add_config_option("heat_street_music")
module:add_config_option("apartment_music")
module:add_config_option("bridge_music")
module:add_config_option("diamond_heist_music")
module:add_config_option("slaughter_house_music")

module:hook_post_require("lib/tweak_data/levelstweakdata", "levelstweakdata")
module:register_include("modoptions", { type = "menu_options", lazy_load = true })
module:register_include("modlocalization")

return module