local module = ... or D:module("test_place_mutator")

local GameSetup = module:hook_class("GameSetup")
module:post_hook(50, GameSetup, "init_finalize", function(self)
	for _, package in pairs({
		"levels/apartment/world",
		"levels/bank/world",
		"levels/bridge/world",
		"levels/diamondheist/world",
		"levels/l4d/world",
		"levels/secret_stash/world",
		"levels/slaughterhouse/world",
		"levels/street/world",
		"levels/suburbia/world",
	}) do
		if not PackageManager:loaded(package) then
			PackageManager:load(package)
		end
	end
end, true)

module:post_hook(50, GameSetup, "unload_packages", function(self)
	for _, package in pairs({
		"levels/apartment/world",
		"levels/bank/world",
		"levels/bridge/world",
		"levels/diamondheist/world",
		"levels/l4d/world",
		"levels/secret_stash/world",
		"levels/slaughterhouse/world",
		"levels/street/world",
		"levels/suburbia/world",
		"packages/level_slaughterhouse",
	}) do
		if PackageManager:loaded(package) then
			PackageManager:unload(package)
		end
	end
end, true)
