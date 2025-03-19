
local init_finalize_actual = Setup.init_finalize
function Setup:init_finalize(...)
	init_finalize_actual(self, ...)

	if FPSCap ~= nil and FPSCap.Limit ~= nil then
		FPSCap:Load()
		self._framerate_cap = FPSCap.Limit
		self:set_fps_cap(FPSCap.Limit)
	end
end

function Setup:set_fps_cap(value)
	self._framerate_cap = value
	Application:cap_framerate(value)
end
