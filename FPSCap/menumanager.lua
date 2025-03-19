
local init_actual = MenuManager.init
function MenuManager:init(...)
	init_actual(self, ...)

	if FPSCap ~= nil and FPSCap.Limit ~= nil then
		self:fps_limit_changed(nil, nil, FPSCap.Limit)
	end
end

function MenuManager:fps_limit_changed(name, old_value, new_value)
	setup:set_fps_cap(new_value)
end

function MenuCallbackHandler:choice_fps_cap(item)
	setup:set_fps_cap(item:value())
	if FPSCap ~= nil then
		FPSCap.Limit = item:value()
		FPSCap:Save()
	end
end

-- Disclaimer: I am NOT to be held responsible should you somehow kill your computer, experience (power) bill shock, meet aliens,
-- and / or somehow encounter some unfortunate situation with the following new options. Your use of the frame rate limit options
-- are entirely at your own risk; if something breaks, that's not my fault. Consider yourself warned!

local limits = {30, 45, 60, 75, 90, 105, 120, 130, 144,
-- Insanity range...
150, 175, 200, 225, 250, 275, 300}

local modify_adv_video_actual = MenuOptionInitiator.modify_adv_video
function MenuOptionInitiator:modify_adv_video(node, ...)
	if node:item("choose_fps_cap") == nil then
		local nodedata = {
			type = "MenuItemMultiChoice",
		}
		for __, limit in ipairs(limits) do
			if type(limit) == "number" then
				table.insert(nodedata, {
					_meta = "option",
					text_id = tostring(limit),
					value = limit,
					localize = false
				})
			end
		end

		local params = {
			name = "choose_fps_cap",
			text_id = "menu_fps_limit",
			help_id = "menu_fps_limit_help",
			callback = "choice_fps_cap",
			-- This determines whether the item will be aligned to the right
--			filter = true,
			localize = "true"
		}
		local new_item = node:create_item(nodedata, params)
--		node:add_item(new_item)
		-- From MenuNode:add_item() (core/lib/managers/menu/coremenunode)
		new_item.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			new_item:set_callback_handler(node.callback_handler)
		end
		-- Determine where the item should be inserted
		local position = 8
		for index, item in ipairs(node._items) do
			if item:name() == "choose_color_grading" then
				position = index
				break
			end
		end
		table.insert(node._items, position, new_item)
	end
	if FPSCap ~= nil and FPSCap.Limit ~= nil then
		node:item("choose_fps_cap"):set_value(FPSCap.Limit)
	end

	return modify_adv_video_actual(self, node, ...)
end
