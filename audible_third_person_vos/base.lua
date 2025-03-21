local module = DMod:new("third_person_lines", {
	abbr = "thirdvos",
	name = "Third Person Audible lines and sync-able vos.",
	priority = 10,
	author = "easternunit100",  
	version = "1.0",
	description = {
		english = "Makes you hear third person lines from your character. (Ex: First World Bank Heat Quote is only audible in third person)\n and makes any voice lines sync with other players."
	},
})

module:hook_post_require("lib/units/beings/player/playersound", "playersound")
local function _add_localization_string(data, language)
	for string, text in pairs(data) do
		local loc_data = {}
		loc_data[language] = text
		module:add_localization_string(string, loc_data)
	end
end
-- register module
return module