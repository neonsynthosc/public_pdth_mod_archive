
if not FPSCap_ModPath then
	io.stdout:write("[FPSCap] init.lua | Fatal Error: FPSCap_ModPath is not valid, aborting\r\n")
	io.stdout:flush()
	return
end

_G.FPSCap = _G.FPSCap or {
	Limit = 60
}

if FPSCap.SaveFile == nil then
	FPSCap.SaveFile = FPSCap_ModPath .. "setting.txt"
end

function FPSCap:Load()
	local f = io.open(self.SaveFile, "rb")
	if f ~= nil then
		self.Limit = f:read("*n") or self.Limit
		if self.Limit < 30 then
			self.Limit = 30
		end
		if self.Limit > 300 then
			self.Limit = 300
		end
		f:close()
	else
		-- File is missing, force a save now
		self:Save()
	end
end

function FPSCap:Save()
	local f = io.open(self.SaveFile, "wb+")
	if f ~= nil then
		f:write(tostring(self.Limit))
		f:close()
	end
end
