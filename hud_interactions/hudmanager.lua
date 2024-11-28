-- DAHM by DorentuZ` -- http://steamcommunity.com/id/dorentuz/
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local D = D
local module = ... or D:module("hud_interactions")

local SquareProgressPanel
local HUDManager = module:hook_class("HUDManager")

function HUDManager.mugshot_interaction_progress_reset_cb(panel)
	panel:set_border_color(panel._params.border_color)
end

function HUDManager.mugshot_interaction_progress_completed_cb(panel)
	panel:set_border_color(panel._params.progress_done_border_color)
end

local function value_iff_set(key, default)
	local v = D:conf(key)
	if v == nil then return default end
	return v
end

module:post_hook(HUDManager, "update_hud_settings", function(self)
	local var_cache = self._cached_conf_vars
	var_cache.show_ai_interactions = value_iff_set("hud_interactions_show_ai", true)
	var_cache.flash_mugshot_interactions = value_iff_set("hud_interactions_flash_completed", true)
	var_cache.mugshot_interaction_border_color = value_iff_set("hud_interactions_border_color", Color.white)
	var_cache.mugshot_interaction_done_border_color = value_iff_set("hud_interactions_done_border_color", Color(.9, .3, .8, .3))
end, false)

module:post_hook(HUDManager, "_add_mugshot", function(self, data, mugshot_data)
	local var_cache = self._cached_conf_vars
	local x, y, w, h = mugshot_data.mask:shape()
	local interact_progress = SquareProgressPanel:new(mugshot_data.panel, 3, {
		name = "interact_progress",
		visible = true,
		border_width = 1,
		border_color = var_cache.mugshot_interaction_border_color,
		progress_done_border_color = var_cache.mugshot_interaction_done_border_color,
		-- done_callback = self.mugshot_interaction_progress_completed_cb,
		-- reset_callback = self.mugshot_interaction_progress_reset_cb,
	})
	local interact_progress_shadow = SquareProgressPanel:new(mugshot_data.panel, 4, {
		name = "interact_progress_shadow",
		visible = true,
		border_width = 1,
		border_color = var_cache.mugshot_interaction_border_color:with_alpha(.33),
		progress_done_border_color = var_cache.mugshot_interaction_done_border_color:with_alpha(.4),
		-- done_callback = self.mugshot_interaction_progress_completed_cb,
		-- reset_callback = self.mugshot_interaction_progress_reset_cb,
	})

	mugshot_data.interact_progress = interact_progress
	mugshot_data.interact_progress_shadow = interact_progress_shadow
	interact_progress._border_colors = { var_cache.mugshot_interaction_border_color,  } -- for callbacks
	interact_progress:set_shape(x, y, w, h)
	interact_progress_shadow:set_shape(x + 1, y + 1, w - 2, h - 2)
end, false)

module:post_hook(50, HUDManager, "_layout_mugshots", function(self)
	local mugshots = self._hud.mugshots
	for i = #mugshots, 1, -1 do
		local mugshot_data = mugshots[i]
		if mugshot_data.interact_progress ~= nil then
			local x, y, w, h = mugshot_data.mask:shape()
			mugshot_data.interact_progress:set_shape(x, y, w, h)
			if mugshot_data.interact_progress_shadow then
				mugshot_data.interact_progress_shadow:set_shape(x + 1, y + 1, w - 2, h - 2)
			end
		end
	end
end, false)

local hudmanager = nil
function HUDManager._mugshot_interaction_updator(t, dt)
	local self = hudmanager
	local N, interactions_to_remove = 0
	for id, data in pairs(self._active_interactions) do
		data.timer = data.timer + dt
		if data.state == 1 then
			local progress = data.timer / data.total_time
			local mugshot_data = data.mugshot_data
			local progress_panels = { mugshot_data.interact_progress, mugshot_data.interact_progress_shadow }
			for _, panel in pairs(progress_panels) do
				panel:set_progress(progress)
			end
			N = N + 1
		elseif data.state == 2 or (data.state == 3 and data.timer >= 1.5) or (data.total_time + 3 < data.timer) then
			local mugshot_data = data.mugshot_data
			local progress_panels = { mugshot_data.interact_progress, mugshot_data.interact_progress_shadow }
			for _, panel in pairs(progress_panels) do
				panel:reset()
			end

			if not interactions_to_remove then
				interactions_to_remove = { id }
			else
				interactions_to_remove[#interactions_to_remove + 1] =  id
			end
		else
			if data.state == 3 then
				if self._cached_conf_vars.flash_mugshot_interactions ~= false then
					if data.timer >= .5 then
						local mugshot_data = data.mugshot_data
						local progress_panels = { mugshot_data.interact_progress, mugshot_data.interact_progress_shadow }
						if data.timer >= 1.0 then
							if data.flashed == 1 then
								for _, panel in pairs(progress_panels) do
									panel:set_visible(true)
								end
								data.flashed = 2
							end
						else
							if not data.flashed then
								for _, panel in pairs(progress_panels) do
									panel:set_visible(false)
								end
								data.flashed = 1
							end
						end
					end
				end
			end
			N = N + 1
		end
	end

	if interactions_to_remove then
		for _, id in pairs(interactions_to_remove) do
			self._active_interactions[id] = nil
		end
	end

	if N <= 0 then
		self:remove_updator("update_mugshot_interactions")
	end
end

module:hook(20, HUDManager, "start_mugshot_interaction", function(self, id, timer, target)
	local data = self:_get_mugshot_data(id)
	if not data or not timer then
		return
	end

	if (not data.peer_id or data.peer_id == 0) and self._cached_conf_vars.show_ai_interactions == false then
		return
	end

	if data.interact_progress ~= nil then
		data.interact_progress:reset()
		data.interact_progress:set_visible(true)
		if self._active_interactions == nil then
			self._active_interactions = {}
			hudmanager = self
		end
		self._active_interactions[id] = { state = 1, timer = 0, total_time = timer, mugshot_data = data, target = target }
		self:add_updator("update_mugshot_interactions", self._mugshot_interaction_updator)
	end
end, false)

module:hook(20, HUDManager, "end_mugshot_interaction", function(self, id, completed, target)
	local data = self:_get_mugshot_data(id)
	if not data then
		return
	end

	if data.interact_progress ~= nil and self._active_interactions ~= nil then
		local interaction_data = self._active_interactions[id]
		if interaction_data ~= nil then
			if completed then
				interaction_data.state = 3
				data.interact_progress:set_progress(1)
			else
				interaction_data.state = 2
			end
			interaction_data.timer = 0
		end
	end
end, false)

module:pre_hook(HUDManager, "_remove_mugshot", function(self, id)
	local data = self:_get_mugshot_data(id)
	if data and self._active_interactions ~= nil then
		if self._active_interactions[id] ~= nil then
			if table.size(self._active_interactions) == 0 then
				self:remove_updator("update_mugshot_interactions")
			end
			self._active_interactions[id] = nil
		end
	end
end, false)


SquareProgressPanel = module:hook_class("SquareProgressPanel", class)
SquareProgressPanel.type_name = "SquareProgressPanel"

function SquareProgressPanel:init(parent, layer, params)
	params = table.merge({
		border_width = 2,
		border_color = Color.white,
		border_alpha = 1
	}, params)

	local panel = parent:panel(table.merge({
		layer = layer
	}, params))

	self._params = params
	self._invert = params.invert
	self._callbacks = {}

	self._panel  = panel
	self._top_r  = panel:rect({})
	self._right  = panel:rect({})
	self._bottom = panel:rect({})
	self._left   = panel:rect({})
	self._top_l  = panel:rect({})

	self:set_border_color(params.border_color)
	if type(params.border_width) == "table" then
		self:set_border_width(unpack(params.border_width))
	else
		self:set_border_width(params.border_width)
	end
	self:reset()
	self:layout()

	-- callbacks are added at the end so they don't get called before they should
	local callbacks = self._callbacks
	callbacks.done  = params.done_callback or params.on_completed or nil
	callbacks.reset = params.reset_callback or params.on_reset or nil
end

function SquareProgressPanel:set_border_color(color)
	self._top_l:set_color(color)
	self._right:set_color(color)
	self._bottom:set_color(color)
	self._left:set_color(color)
	self._top_r:set_color(color)
end

function SquareProgressPanel:set_color(color)
	self._panel:set_color(color)
end

function SquareProgressPanel:set_alpha(alpha)
	self._panel:set_alpha(alpha)
end

function SquareProgressPanel:border_width()
	return unpack(self._border_widths)
end

function SquareProgressPanel:set_border_width(top, right, bottom, left)
	-- determine individual widths
	if right ~= nil then
		if bottom ~= nil then
			if left == nil then
				left = right
			end
		else
			bottom = top
		end
	else
		right, bottom, left = top, top, top
	end

	self._border_widths = { top, right, bottom, left }
	local pw, ph = self._panel:width(), self._panel:height()
	local pc = 2 * (pw + ph)

	-- draw borders clockwise: 0 -> w/2 -> h -> w -> h -> w/2 -> 1
	local stages = { 0 }
	stages[2] = (pw / 2) / pc
	stages[3] = stages[2] + (ph / pc)
	stages[4] = stages[3] + (pw / pc)
	stages[5] = stages[4] + (ph / pc)
	stages[6] = 1
	self._stages = stages
	self._stage = 1

	self:layout()
end

function SquareProgressPanel:layout()
	local border_widths = self._border_widths
	local pw, ph = self._panel:width(), self._panel:height()

	self._top_r:set_height(border_widths[1])
	self._top_r:set_x(math.floor(pw * .5))
	self._top_r:set_y(0)

	self._right:set_width(border_widths[2])
	self._right:set_x(pw - border_widths[2])
	self._right:set_y(border_widths[1])

	self._bottom:set_height(border_widths[3])
	self._bottom:set_x(0)
	self._bottom:set_y(ph - border_widths[3])

	self._left:set_width(border_widths[4])
	self._left:set_x(0)
	self._left:set_y(border_widths[1])

	self._top_l:set_height(border_widths[1])
	self._top_l:set_x(0)
	self._top_l:set_y(0)

	self:set_progress(self._progress)
end

function SquareProgressPanel:set_progress(v)
	v = math.clamp(v, 0, 1)
	self._progress = v

	if self._done then
		if v == 1 then
			if not self._ignore_done then
				return
			end
		else
			self._done = false
		end
	elseif v >= 1 then
		self._done = true
		if not self._ignore_done then
			if self._callbacks.done then
				self._callbacks.done(self)
			end
		end
	-- elseif v >= 0.99999999 then
		-- print(string.format("%.20f", v))
	end

	if self._invert then
		v = 1 - v
	end

	local panel = self._panel
	local stages, stage = self._stages, self._stage
	local border_widths = self._border_widths

	-- check if current stage is still valid
	if v < stages[stage] then
		stage = self:_determine_stage()
	end

	local pw, ph = panel:width(), panel:height()
	while v > stages[stage + 1] do
		if stage == 1 then
			self._top_r:set_width(math.ceil(pw * .5))
		elseif stage == 2 then
			self._right:set_height(ph - border_widths[1] - border_widths[3])
		elseif stage == 3 then
			self._bottom:set_width(pw)
			self._bottom:set_x(0)
		elseif stage == 4 then
			self._left:set_height(ph - border_widths[1] - border_widths[3])
			self._left:set_y(border_widths[1])
		elseif stage == 5 then
			self._top_l:set_width(math.ceil(pw * .5))
		end
		stage = stage + 1
	end

	self._stage = stage
	local low = stages[stage]
	local high = stages[stage + 1]
	local p = (v - low) / (high - low)

	if stage == 1 then
		self._top_r:set_width(pw * .5 * p)
	elseif stage == 2 then
		local h = (ph - border_widths[1] - border_widths[3]) * p
		self._right:set_height(h)
	elseif stage == 3 then
		local w = pw * p
		self._bottom:set_width(w)
		self._bottom:set_x(pw - w)
	elseif stage == 4 then
		local max_h = (ph - border_widths[1] - border_widths[3])
		local h = max_h * p
		self._left:set_height(h)
		self._left:set_y(border_widths[1] + max_h - h)
	elseif stage == 5 then
		self._top_l:set_width(pw * .5 * p)
	end
end

function SquareProgressPanel:_determine_stage()
	local stages, stage, actual_stage = self._stages, self._stage, 1
	local progress = self._progress

	if self._invert then
		progress = (1 - progress)
	end

	for i = 1, #stages - 1 do
		if progress < stages[i + 1] then
			actual_stage = i
			break
		end
	end

	if stage > actual_stage then
		for i = stage, actual_stage + 1, -1 do
			if i == 1 then
				self._top_r:set_width(0)
			elseif i == 2 then
				self._right:set_height(0)
			elseif i == 3 then
				self._bottom:set_width(0)
			elseif i == 4 then
				self._left:set_height(0)
			elseif i == 5 then
				self._top_l:set_width(0)
			end
		end
		self._stage = actual_stage
	end
	return actual_stage
end

function SquareProgressPanel:inverted()
	return self._inverted
end

function SquareProgressPanel:set_inverted(v)
	self._ignore_done = (self._invert ~= v)
	self._invert = v
	self:set_progress(self._progress)
	self._ignore_done = false
end

function SquareProgressPanel:invert()
	self:set_inverted(not self._invert)
end

function SquareProgressPanel:reset()
	if self._callbacks.reset then
		self._callbacks.reset(self)
	end

	self._done = false
	self._progress = 0

	if self._invert then
		local panel = self._panel
		local pw, ph = panel:width(), panel:height()
		local border_widths = self._border_widths
		self._top_r:set_width(math.ceil(pw / 2))
		self._right:set_height(ph - border_widths[1] - border_widths[3])
		self._bottom:set_width(pw)
		self._bottom:set_x(0)
		self._left:set_height(ph - border_widths[1] - border_widths[3])
		self._left:set_y(border_widths[1])
		self._top_l:set_width(math.ceil(pw / 2))
		self._stage = 5
	else
		self._top_r:set_width(0)
		self._right:set_height(0)
		self._bottom:set_width(0)
		self._left:set_height(0)
		self._top_l:set_width(0)
		self._stage = 1
	end
end

function SquareProgressPanel:progress()
	local r = self._progress or 0
	if self._invert then
		r = 1 - r
	end
	return r
end

function SquareProgressPanel:set_size(w, h)
	self._panel:set_size(w, h)
	self:set_border_width(unpack(self._border_widths))
end

function SquareProgressPanel:set_shape(x, y, w, h)
	self._panel:set_x(x)
	self._panel:set_y(y)
	self:set_size(w, h)
end

function SquareProgressPanel:panel()
	return self._panel
end

function SquareProgressPanel:children()
	-- should fix this
	return self._panel:children()
end

local functions_to_forward = {
	"x", "y", "w", "h", "set_x", "set_y", "set_w", "set_h", "center", "set_center", "set_center_x", "set_center_y",
	"righttop", "rightbottom", "lefttop", "leftbottom", "set_righttop", "set_rightbottom", "set_lefttop", "set_leftbottom",
	"left", "right", "top", "bottom", "set_left", "set_right", "set_top", "set_bottom",
	"inside", "outside", "animate", "stop", "move", "visible", "set_visible", "show", "hide",
	"set_layer", "layer", "after", "alpha", "num_children", "gui", "name", "alive", "parent", "remove",
	"mouse_press", "mouse_release", "mouse_click", "mouse_double_click", "mouse_enter", "mouse_exit",
	"key_press", "key_click", "button_press", "button_release",
}

for _, name in pairs(functions_to_forward) do
	SquareProgressPanel[name] = function(self, ...)
		return self._panel[name](self._panel, ...)
	end
end