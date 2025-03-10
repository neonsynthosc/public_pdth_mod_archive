function GameSetup:load_packages()
	Setup.load_packages(self)
		if not PackageManager:loaded("packages/game_base") then
		PackageManager:load("packages/game_base")
	end

	local level_package
		if not Global.level_data or not Global.level_data.level_id then
		level_package = "packages/level_debug"
	else
		local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
		level_package = lvl_tweak_data and lvl_tweak_data.package
	end

	if level_package and not PackageManager:loaded(level_package) then
		self._loaded_level_package = level_package
		PackageManager:load(level_package)
	end
end